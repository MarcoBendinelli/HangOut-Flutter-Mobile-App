import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/chat/chat_bloc.dart';
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockMessage extends Mock implements Message {}

void main() {
  group('chat_bloc', () {
    final messageMock = MockMessage();
    final Error error = Error();
    final List<Message> testMessages = [messageMock];
    final Stream<List<Message>> testMessagesStreamEvent = Stream.value(testMessages);
    final Stream<List<Message>> testMessagesStreamGroup = Stream.value(testMessages);
    final Stream<List<Message>> testMessagesStreamerrorEvent = Stream.error(error);
    final Stream<List<Message>> testMessagesStreamerrorGroup = Stream.error(error);
    const String eventId = "eventId";
    const String groupId = "groupId";
    late ChatRepository chatRepository;
    setUp(() {
      chatRepository = MockChatRepository();
    });
    test('initial state is GroupsLoading', () {
      expect(
        ChatBloc(chatRepository: chatRepository).state,
        ChatLoading(),
      );
    });

    blocTest<ChatBloc, ChatState>(
      'get event chat successfuly',
      setUp: () => when(
              () => chatRepository.getTheChatOfTheEventWithId(eventId: eventId))
          .thenAnswer((_) => testMessagesStreamEvent),
      build: () => ChatBloc(
        chatRepository: chatRepository,
      ),
      act: (bloc) => bloc.add(const LoadEventChat(eventId: eventId)),
      expect: () => [
        ChatLoaded(messages: testMessages),
      ],
      verify: (_) {
        verify(() =>
                chatRepository.getTheChatOfTheEventWithId(eventId: eventId))
            .called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'get event chat with error',
      setUp: () => when(
              () => chatRepository.getTheChatOfTheEventWithId(eventId: eventId))
          .thenAnswer((_) => testMessagesStreamerrorEvent),
      build: () => ChatBloc(
        chatRepository: chatRepository,
      ),
      act: (bloc) => bloc.add(const LoadEventChat(eventId: eventId)),
      expect: () => [ChatError(error: error, stackTrace: StackTrace.current)],
      verify: (_) {
        verify(() =>
                chatRepository.getTheChatOfTheEventWithId(eventId: eventId))
            .called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'get group chat successfuly',
      setUp: () => when(
              () => chatRepository.getTheChatOfTheGroupWithId(groupId: groupId))
          .thenAnswer((_) => testMessagesStreamGroup),
      build: () => ChatBloc(
        chatRepository: chatRepository,
      ),
      act: (bloc) => bloc.add(const LoadGroupChat(groupId: groupId)),
      expect: () => [
        ChatLoaded(messages: testMessages),
      ],
      verify: (_) {
        verify(() =>
                chatRepository.getTheChatOfTheGroupWithId(groupId: groupId))
            .called(1);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'get group chat with error',
      setUp: () => when(
              () => chatRepository.getTheChatOfTheGroupWithId(groupId: groupId))
          .thenAnswer((_) => testMessagesStreamerrorGroup),
      build: () => ChatBloc(
        chatRepository: chatRepository,
      ),
      act: (bloc) => bloc.add(const LoadGroupChat(groupId: groupId)),
      expect: () => [
        ChatError(error: error, stackTrace: StackTrace.current),
      ],
      verify: (_) {
        verify(() =>
                chatRepository.getTheChatOfTheGroupWithId(groupId: groupId))
            .called(1);
      },
    );
  });
}
