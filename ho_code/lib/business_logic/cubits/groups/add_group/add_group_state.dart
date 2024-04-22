part of 'add_group_cubit.dart';

enum AddGroupStatus { initial, loading, success, error }

class AddGroupState extends Equatable {
  final AddGroupStatus status;

  const AddGroupState({this.status = AddGroupStatus.initial});

  @override
  List<Object> get props => [status];

  AddGroupState copyWith({
    required AddGroupStatus status,
  }) {
    return AddGroupState(
      status: status,
    );
  }
}
