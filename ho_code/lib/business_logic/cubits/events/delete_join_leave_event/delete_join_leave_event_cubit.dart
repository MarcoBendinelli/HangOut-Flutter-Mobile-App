import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';

part 'delete_join_leave_event_state.dart';

class DeleteJoinLeaveEventCubit extends Cubit<DeleteJoinLeaveEventState> {
  final MyEventsRepository _eventsRepository;

  DeleteJoinLeaveEventCubit({required MyEventsRepository eventsRepository})
      : _eventsRepository = eventsRepository,
        super(const DeleteJoinLeaveEventState());

  Future<void> joinEvent({
    required UserData user,
    required String eventId,
  }) async {
    emit(state.copyWith(status: DeleteJoinLeaveEventStatus.loading));
    try {
      await _eventsRepository.addEventToUser(user: user, eventId: eventId);
      emit(state.copyWith(status: DeleteJoinLeaveEventStatus.success));
    } catch (_) {
      emit(state.copyWith(status: DeleteJoinLeaveEventStatus.error));
    }
  }

  Future<void> leaveEvent({
    required UserData user,
    required String eventId,
  }) async {
    emit(state.copyWith(status: DeleteJoinLeaveEventStatus.loading));
    try {
      await _eventsRepository.removeEventfromUser(user: user, eventId: eventId);
      emit(state.copyWith(status: DeleteJoinLeaveEventStatus.success));
    } catch (_) {
      emit(state.copyWith(status: DeleteJoinLeaveEventStatus.error));
    }
  }

  Future<void> deleteEvent({
    required String eventId,
  }) async {
    emit(state.copyWith(status: DeleteJoinLeaveEventStatus.loading));
    try {
      await _eventsRepository.deleteSingleEvent(eventId: eventId);
      emit(state.copyWith(status: DeleteJoinLeaveEventStatus.success));
    } catch (_) {
      emit(state.copyWith(status: DeleteJoinLeaveEventStatus.error));
    }
  }
}
