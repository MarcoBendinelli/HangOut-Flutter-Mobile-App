part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}

class LoadUser extends UserEvent {
  final String userId;

  const LoadUser({required this.userId});

  @override
  List<Object> get props => [userId];
}
