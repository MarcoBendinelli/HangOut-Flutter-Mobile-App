import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:image_picker/image_picker.dart';

part 'add_event_state.dart';

class AddEventCubit extends Cubit<AddEventState> {
  final MyEventsRepository _eventsRepository;

  AddEventCubit({required MyEventsRepository eventsRepository})
      : _eventsRepository = eventsRepository,
        super(const AddEventState());

  Future<String> addEvent({
    required UserData eventCreator,
    required String eventName,
    required GeoPoint location,
    required String eventDescription,
    required String category,
    required Timestamp date,
    required XFile? image,
    required int numParticipants,
    required bool private,
    required String locationName,
  }) async {
    emit(state.copyWith(status: AddEventStatus.loading));
    try {
      String eventId = await _eventsRepository.saveNewEvent(
        event: Event(
          id: "",
          name: eventName,
          photo: "",
          description: eventDescription,
          creatorId: eventCreator.id,
          category: category,
          numParticipants: numParticipants,
          private: private,
          date: date,
          location: location,
          locationName: locationName,
        ),
        creator: eventCreator,
        imageFile: image,
      );
      emit(state.copyWith(status: AddEventStatus.success));
      return eventId;
    } catch (_) {
      emit(state.copyWith(status: AddEventStatus.error));
      return "";
    }
  }
}
