import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/cubits/events/add_event/add_event_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/events/delete_join_leave_event/delete_join_leave_event_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/events/modify_event/modify_event_cubit.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockEventsRepository extends Mock implements MyEventsRepository {}

class MockEvent extends Mock implements Event {}

class MockUserData extends Mock implements UserData {}

class MockXFile extends Mock implements XFile {}

class MockGeoPoint extends Mock implements GeoPoint {}

class MockTimestamp extends Mock implements Timestamp {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockEvent());
  });
  group("Events cubits", () {
    //for event
    final MockUserData creator = MockUserData();
    const String name = "eventName";
    final MockGeoPoint location = MockGeoPoint();
    const String description = "eventDescription";
    const String category = "category";
    final MockTimestamp date = MockTimestamp();
    final MockXFile image = MockXFile();
    const int numParticipants = 1;
    const bool private = true;
    const String locationName = "locationName";
    const String id = "";
    const String photo = "";

    late MyEventsRepository myEventsRepository;
    setUp(() {
      when(() => creator.id).thenReturn("id");
      myEventsRepository = MockEventsRepository();
    });

    group('add_event_cubit', () {
      test('initial state is initial', () {
        expect(AddEventCubit(eventsRepository: myEventsRepository).state.status,
            AddEventStatus.initial);
      });

      blocTest<AddEventCubit, AddEventState>(
        'emits [success] when [MyEventsRepository] saves event successfully',
        setUp: () {
          when(
            () => myEventsRepository.saveNewEvent(
                event: any(named: "event"), creator: creator, imageFile: image),
          ).thenAnswer((_) async {
            return "";
          });
        },
        build: () => AddEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.addEvent(
          eventCreator: creator,
          eventName: name,
          location: location,
          eventDescription: description,
          category: category,
          date: date,
          image: image,
          numParticipants: numParticipants,
          private: private,
          locationName: locationName,
        ),
        expect: () => [
          const AddEventState(status: AddEventStatus.loading),
          const AddEventState(status: AddEventStatus.success),
        ],
      );

      blocTest<AddEventCubit, AddEventState>(
        'emits [error] when [MyEventsRepository] generate error while saving event',
        setUp: () {
          when(
            () => myEventsRepository.saveNewEvent(
                event: any(named: "event"), creator: creator, imageFile: image),
          ).thenThrow(Error());
        },
        build: () => AddEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.addEvent(
          eventCreator: creator,
          eventName: name,
          location: location,
          eventDescription: description,
          category: category,
          date: date,
          image: image,
          numParticipants: numParticipants,
          private: private,
          locationName: locationName,
        ),
        expect: () => [
          const AddEventState(status: AddEventStatus.loading),
          const AddEventState(status: AddEventStatus.error),
        ],
      );
    });

    group('delete_join_leave_event_cubit', () {
      final UserData user = MockUserData();
      const String eventId = "eventId";
      test('initial state is initial', () {
        expect(
            DeleteJoinLeaveEventCubit(eventsRepository: myEventsRepository)
                .state
                .status,
            DeleteJoinLeaveEventStatus.initial);
      });

      blocTest<DeleteJoinLeaveEventCubit, DeleteJoinLeaveEventState>(
        'emits [success] when [MyEventsRepository] join event successfully',
        setUp: () {
          when(
            () =>
                myEventsRepository.addEventToUser(user: user, eventId: eventId),
          ).thenAnswer((_) async {});
        },
        build: () =>
            DeleteJoinLeaveEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.joinEvent(user: user, eventId: eventId),
        expect: () => [
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.loading),
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.success),
        ],
      );

      blocTest<DeleteJoinLeaveEventCubit, DeleteJoinLeaveEventState>(
        'emits [success] when [MyEventsRepository] join event successfully',
        setUp: () {
          when(
            () =>
                myEventsRepository.addEventToUser(user: user, eventId: eventId),
          ).thenThrow(Error());
        },
        build: () =>
            DeleteJoinLeaveEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.joinEvent(user: user, eventId: eventId),
        expect: () => [
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.loading),
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.error),
        ],
      );

      blocTest<DeleteJoinLeaveEventCubit, DeleteJoinLeaveEventState>(
        'emits [success] when [MyEventsRepository] leave event successfully',
        setUp: () {
          when(
            () => myEventsRepository.removeEventfromUser(
                user: user, eventId: eventId),
          ).thenAnswer((_) async {});
        },
        build: () =>
            DeleteJoinLeaveEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.leaveEvent(user: user, eventId: eventId),
        expect: () => [
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.loading),
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.success),
        ],
      );

      blocTest<DeleteJoinLeaveEventCubit, DeleteJoinLeaveEventState>(
        'emits [success] when [MyEventsRepository] leave event successfully',
        setUp: () {
          when(
            () => myEventsRepository.removeEventfromUser(
                user: user, eventId: eventId),
          ).thenThrow(Error());
        },
        build: () =>
            DeleteJoinLeaveEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.leaveEvent(user: user, eventId: eventId),
        expect: () => [
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.loading),
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.error),
        ],
      );

      blocTest<DeleteJoinLeaveEventCubit, DeleteJoinLeaveEventState>(
        'emits [success] when [MyEventsRepository] delete event successfully',
        setUp: () {
          when(
            () => myEventsRepository.deleteSingleEvent(eventId: eventId),
          ).thenAnswer((_) async {});
        },
        build: () =>
            DeleteJoinLeaveEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.deleteEvent(eventId: eventId),
        expect: () => [
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.loading),
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.success),
        ],
      );

      blocTest<DeleteJoinLeaveEventCubit, DeleteJoinLeaveEventState>(
        'emits [success] when [MyEventsRepository] join event successfully',
        setUp: () {
          when(
            () => myEventsRepository.deleteSingleEvent(eventId: eventId),
          ).thenThrow(Error());
        },
        build: () =>
            DeleteJoinLeaveEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.deleteEvent(eventId: eventId),
        expect: () => [
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.loading),
          const DeleteJoinLeaveEventState(
              status: DeleteJoinLeaveEventStatus.error),
        ],
      );
    });

    group('modify_event_cubit', () {
      // const String eventId = "eventId";
      test('initial state is initial', () {
        expect(
            ModifyEventCubit(eventsRepository: myEventsRepository).state.status,
            ModifyEventSatus.initial);
      });

      blocTest<ModifyEventCubit, ModifyEventState>(
        'emits [success] when [MyEventsRepository] modify event successfully',
        setUp: () {
          when(() => myEventsRepository.modifyEvent(
              event: any(named: "event"),
              imageFile: image)).thenAnswer((_) async {});
        },
        build: () => ModifyEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.modifyEvent(
          eventId: id,
          eventName: name,
          location: location,
          eventDescription: description,
          category: category,
          date: date,
          image: image,
          private: private,
          locationName: locationName,
          oldPhoto: photo,
        ),
        expect: () => [
          const ModifyEventState(status: ModifyEventSatus.loading),
          const ModifyEventState(status: ModifyEventSatus.success),
        ],
      );

      blocTest<ModifyEventCubit, ModifyEventState>(
        'emits [success] when [MyEventsRepository] modify event successfully',
        setUp: () {
          when(
            () => myEventsRepository.modifyEvent(
                event: any(named: "event"), imageFile: image),
          ).thenThrow(Error());
        },
        build: () => ModifyEventCubit(eventsRepository: myEventsRepository),
        act: (cubit) => cubit.modifyEvent(
          eventId: id,
          eventName: name,
          location: location,
          eventDescription: description,
          category: category,
          date: date,
          image: image,
          private: private,
          locationName: locationName,
          oldPhoto: photo,
        ),
        expect: () => [
          const ModifyEventState(status: ModifyEventSatus.loading),
          const ModifyEventState(status: ModifyEventSatus.error),
        ],
      );
    });
  });
}
