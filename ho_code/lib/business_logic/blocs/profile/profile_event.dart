part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class LoadGroupsInCommon extends ProfileEvent {
  final String firstId;
  final String secondId;

  const LoadGroupsInCommon({required this.firstId, required this.secondId});

  @override
  List<Object> get props => [firstId, secondId];
}
