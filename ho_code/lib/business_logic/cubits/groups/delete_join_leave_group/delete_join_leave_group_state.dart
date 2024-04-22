part of 'delete_join_leave_group_cubit.dart';

enum DeleteJoinLeaveGroupStatus { initial, loading, success, error }

class DeleteJoinLeaveGroupState extends Equatable {
  final DeleteJoinLeaveGroupStatus status;

  const DeleteJoinLeaveGroupState(
      {this.status = DeleteJoinLeaveGroupStatus.initial});

  @override
  List<Object> get props => [status];

  DeleteJoinLeaveGroupState copyWith({
    required DeleteJoinLeaveGroupStatus status,
  }) {
    return DeleteJoinLeaveGroupState(
      status: status,
    );
  }
}
