import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';

import '../../../../data/models/message.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;

  ChatCubit({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatState());

  Future<void> newGroupTextMessage({
    required TextMessage message,
    required String groupId,
  }) async {
    emit(state.copyWith(status: ChatStatus.loading));
    await _chatRepository.sendTextMessageInTheGroup(
        message: message, groupId: groupId);
    emit(state.copyWith(status: ChatStatus.success));
  }

  Future<void> newEventTextMessage({
    required TextMessage message,
    required String eventId,
  }) async {
    emit(state.copyWith(status: ChatStatus.loading));
    await _chatRepository.sendTextMessageInTheEvent(
        message: message, eventId: eventId);
    emit(state.copyWith(status: ChatStatus.success));
  }
}
