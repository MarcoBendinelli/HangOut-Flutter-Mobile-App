part of 'user_bloc.dart';

class UserState extends Equatable {
  final UserData user;
  const UserState({this.user = UserData.empty});

  @override
  List<Object> get props => [];
}

// class UserInitial extends UserState {}
class UserLoading extends UserState {}

class UserLoadingError extends UserState {}

class UserLoaded extends UserState {
  // final UserData user;
  const UserLoaded({required UserData user}):super(user: user);
  @override
  List<Object> get props => [user];
}
