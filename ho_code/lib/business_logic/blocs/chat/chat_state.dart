part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final Object error;
  final StackTrace stackTrace;

  const ChatError({required this.error, required this.stackTrace});
}

class ChatLoaded extends ChatState {
  final List<Message> messages;

  const ChatLoaded({this.messages = const <Message>[]});

  @override
  List<Object> get props => [messages];
}
