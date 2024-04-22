import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';

part 'chat_event.dart';

part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatLoading()) {
    on<LoadGroupChat>(_onLoadGroupChat);
    on<LoadEventChat>(_onLoadEventChat);
  }

  Future<void> _onLoadGroupChat(
    LoadGroupChat event,
    Emitter<ChatState> emit,
  ) async {
    await emit.forEach(
      _chatRepository.getTheChatOfTheGroupWithId(groupId: event.groupId),
      onData: (List<Message> messagesData) =>
          ChatLoaded(messages: messagesData),
      onError: (Object error, StackTrace stackTrace) =>
          ChatError(error: error, stackTrace: stackTrace),
    );
  }

  Future<void> _onLoadEventChat(
    LoadEventChat event,
    Emitter<ChatState> emit,
  ) async {
    await emit.forEach(
      _chatRepository.getTheChatOfTheEventWithId(eventId: event.eventId),
      onData: (List<Message> messagesData) =>
          ChatLoaded(messages: messagesData),
      onError: (Object error, StackTrace stackTrace) =>
          ChatError(error: error, stackTrace: stackTrace),
    );
  }
}
