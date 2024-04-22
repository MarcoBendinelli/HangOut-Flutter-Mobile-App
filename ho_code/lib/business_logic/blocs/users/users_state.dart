part of 'users_bloc.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object> get props => [];
}

class UsersLoading extends UsersState {}

class UsersError extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserData> users;

  const UsersLoaded({this.users = const <UserData>[]});

  @override
  List<Object> get props => [users];
}
