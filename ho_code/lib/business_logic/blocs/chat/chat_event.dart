part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

class LoadGroupChat extends ChatEvent {
  final String groupId;

  const LoadGroupChat({required this.groupId});
  @override
  List<Object> get props => [groupId];
}

class LoadEventChat extends ChatEvent {
  final String eventId;

  const LoadEventChat({required this.eventId});
  @override
  List<Object> get props => [eventId];
}
