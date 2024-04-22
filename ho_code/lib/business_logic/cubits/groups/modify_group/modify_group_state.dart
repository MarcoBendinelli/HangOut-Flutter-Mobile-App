part of 'modify_group_cubit.dart';

enum ModifyGroupStatus { initial, loading, success, error }

class ModifyGroupState extends Equatable {
  final ModifyGroupStatus status;

  const ModifyGroupState({this.status = ModifyGroupStatus.initial});

  @override
  List<Object> get props => [status];

  ModifyGroupState copyWith({
    required ModifyGroupStatus status,
  }) {
    return ModifyGroupState(
      status: status,
    );
  }
}
