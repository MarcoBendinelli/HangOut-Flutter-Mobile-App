import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/cubits/chat/chat_cubit.dart';
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockMessage extends Mock implements TextMessage {}

void main() {
  group('chat_cubit', () {
    late ChatRepository chatRepository;
    final TextMessage message = MockMessage();
    const String id = "id";
    setUp(() {
      chatRepository = MockChatRepository();
    });
    test('initial state is initial', () {
      expect(ChatCubit(chatRepository: chatRepository).state.status,
          ChatStatus.initial);
    });
    blocTest<ChatCubit, ChatState>(
      'emits [success] when add [newEventTextMessage] is with success',
      setUp: () => when(() => chatRepository.sendTextMessageInTheEvent(
          message: message, eventId: id)).thenAnswer((_) async => {}),
      build: () => ChatCubit(chatRepository: chatRepository),
      act: (cubit) => cubit.newEventTextMessage(message: message, eventId: id),
      expect: () => const <ChatState>[
        ChatState(status: ChatStatus.loading),
        ChatState(status: ChatStatus.success),
      ],
    );
    blocTest<ChatCubit, ChatState>(
      'emits [success] when add [newGroupTextMessage] is with success',
      setUp: () => when(() => chatRepository.sendTextMessageInTheGroup(
          message: message, groupId: id)).thenAnswer((_) async => {}),
      build: () => ChatCubit(chatRepository: chatRepository),
      act: (cubit) => cubit.newGroupTextMessage(message: message, groupId: id),
      expect: () => const <ChatState>[
        ChatState(status: ChatStatus.loading),
        ChatState(status: ChatStatus.success),
      ],
    );
     
  });
}
