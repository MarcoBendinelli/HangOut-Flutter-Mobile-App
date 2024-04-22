part of 'add_event_cubit.dart';

enum AddEventStatus { initial, loading, success, error }

class AddEventState extends Equatable {
  final AddEventStatus status;
  const AddEventState({this.status = AddEventStatus.initial});

  @override
  List<Object> get props => [status];

  AddEventState copyWith({
    required AddEventStatus status,
  }) {
    return AddEventState(
      status: status,
    );
  }
}
