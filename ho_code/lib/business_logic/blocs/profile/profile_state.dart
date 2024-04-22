part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class CommonGroupsLoading extends ProfileState {}

class CommonGroupsError extends ProfileState {}

class CommonGroupsLoaded extends ProfileState {
  final List<Group> groups;

  const CommonGroupsLoaded({required this.groups});

  @override
  List<Object> get props => [groups];
}
