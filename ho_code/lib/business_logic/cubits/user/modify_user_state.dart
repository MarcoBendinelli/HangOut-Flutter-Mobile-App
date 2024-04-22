part of 'modify_user_cubit.dart';

enum ModifyUserStatus { initial, loading, success, error }

class ModifyUserState extends Equatable {
  final ModifyUserStatus status;
  final UserData userUpdated;

  const ModifyUserState(
      {this.status = ModifyUserStatus.initial,
      this.userUpdated = UserData.empty});

  @override
  List<Object> get props => [status];

  ModifyUserState copyWith(
      {required ModifyUserStatus status, required UserData userUpdated}) {
    return ModifyUserState(status: status, userUpdated: userUpdated);
  }
}
