import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:image_picker/image_picker.dart';

part 'modify_event_state.dart';

class ModifyEventCubit extends Cubit<ModifyEventState> {
  final MyEventsRepository _eventsRepository;
  ModifyEventCubit({required MyEventsRepository eventsRepository})
      : _eventsRepository = eventsRepository,
        super(const ModifyEventState());
  Future<void> modifyEvent({
    required String eventId,
    required String eventName,
    required String eventDescription,
    required String category,
    required Timestamp date,
    required String oldPhoto,
    XFile? image,
    required bool private,
    required GeoPoint location,
    required String locationName,
  }) async {
    emit(state.copyWith(status: ModifyEventSatus.loading));
    try {
      await _eventsRepository.modifyEvent(
        event: Event(
          id: eventId,
          name: eventName,
          description: eventDescription,
          category: category,
          private: private,
          date: date,
          photo: oldPhoto,
          location: location,
          locationName: locationName,
        ),
        imageFile: image,
      );
      emit(state.copyWith(status: ModifyEventSatus.success));
    } catch (_) {
      emit(state.copyWith(status: ModifyEventSatus.error));
    }
  }
}
