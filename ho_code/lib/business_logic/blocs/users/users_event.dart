part of 'users_bloc.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();
}

class LoadUsers extends UsersEvent {
  const LoadUsers();

  @override
  List<Object> get props => [];
}
