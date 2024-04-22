part of 'modify_event_cubit.dart';

enum ModifyEventSatus { initial, loading, success, error }

class ModifyEventState extends Equatable {
  final ModifyEventSatus status;
  const ModifyEventState({this.status = ModifyEventSatus.initial});

  @override
  List<Object> get props => [status];

  ModifyEventState copyWith({
    required ModifyEventSatus status,
  }) {
    return ModifyEventState(
      status: status,
    );
  }
}
