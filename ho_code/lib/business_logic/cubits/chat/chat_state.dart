part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, success, error }

class ChatState extends Equatable {
  final ChatStatus status;

  const ChatState({this.status = ChatStatus.initial});

  @override
  List<Object> get props => [status];

  ChatState copyWith({
    required ChatStatus status,
  }) {
    return ChatState(
      status: status,
    );
  }
}
