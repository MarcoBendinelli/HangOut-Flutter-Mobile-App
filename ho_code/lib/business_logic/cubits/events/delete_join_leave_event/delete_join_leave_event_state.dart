part of 'delete_join_leave_event_cubit.dart';

enum DeleteJoinLeaveEventStatus { initial, loading, success, error }

class DeleteJoinLeaveEventState extends Equatable {
  final DeleteJoinLeaveEventStatus status;
  const DeleteJoinLeaveEventState(
      {this.status = DeleteJoinLeaveEventStatus.initial});

  @override
  List<Object> get props => [status];

  DeleteJoinLeaveEventState copyWith({
    required DeleteJoinLeaveEventStatus status,
  }) {
    return DeleteJoinLeaveEventState(
      status: status,
    );
  }
}
