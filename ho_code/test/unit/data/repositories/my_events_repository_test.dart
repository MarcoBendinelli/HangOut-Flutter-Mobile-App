import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../utils.dart';

void main() {
  group('MyEventsRepository', () {
    group("getParticipantsToEvent", () {
      test('getParticipantsToEvent returns a list of OtherUsers', () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        // Add a fake user with an event ID to the Firestore instance.
        final userRef = fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id);
        await userRef.set({
          'id': EventsRepositoryUtils.matteo.id,
          'name': EventsRepositoryUtils.matteo.name,
          'photo': EventsRepositoryUtils.matteo.photo,
          'description': EventsRepositoryUtils.matteo.description,
          'interests': EventsRepositoryUtils.matteo.interests,
          'events': [EventsRepositoryUtils.foodEvent.id]
        });

        final participants = myEventsRepository
            .getParticipantsToEvent(EventsRepositoryUtils.foodEvent.id);

        expect(participants, emits([isInstanceOf<OtherUser>()]));
      });
      test(
          'getParticipantsToEvent returns a list of OtherUser with the correct user ID',
          () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        // Add a fake user with an event ID to the Firestore instance.
        final userRef = fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id);
        await userRef.set({
          'id': EventsRepositoryUtils.matteo.id,
          'name': EventsRepositoryUtils.matteo.name,
          'photo': EventsRepositoryUtils.matteo.photo,
          'description': EventsRepositoryUtils.matteo.description,
          'interests': EventsRepositoryUtils.matteo.interests,
          'events': [EventsRepositoryUtils.foodEvent.id]
        });

        final participants = myEventsRepository
            .getParticipantsToEvent(EventsRepositoryUtils.foodEvent.id);

        await expectLater(participants,
            emits(predicate<List<OtherUser>>((list) {
          return list.isNotEmpty &&
              list.first.id == EventsRepositoryUtils.matteo.id;
        })));
      });
      test(
          'getParticipantsToEvent returns a list of OtherUser with multiple users',
          () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        // Add two fake users with the event ID to the Firestore instance.
        final user1Ref = fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id);
        await user1Ref.set({
          'id': EventsRepositoryUtils.matteo.id,
          'name': EventsRepositoryUtils.matteo.name,
          'photo': EventsRepositoryUtils.matteo.photo,
          'description': EventsRepositoryUtils.matteo.description,
          'interests': EventsRepositoryUtils.matteo.interests,
          'events': [EventsRepositoryUtils.foodEvent.id]
        });
        final user2Ref = fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.marco.id);
        await user2Ref.set({
          'id': EventsRepositoryUtils.marco.id,
          'name': EventsRepositoryUtils.marco.name,
          'photo': EventsRepositoryUtils.marco.photo,
          'description': EventsRepositoryUtils.marco.description,
          'interests': EventsRepositoryUtils.marco.interests,
          'events': [EventsRepositoryUtils.foodEvent.id]
        });
        final user3Ref = fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.andrea.id);
        await user3Ref.set(EventsRepositoryUtils.andrea.toMap());

        final participants = myEventsRepository
            .getParticipantsToEvent(EventsRepositoryUtils.foodEvent.id);

        await expectLater(participants,
            emits(predicate<List<OtherUser>>((list) {
          return list.length == 2 &&
              list.any((user) => user.id == EventsRepositoryUtils.matteo.id) &&
              list.any((user) => user.id == EventsRepositoryUtils.marco.id);
        })));
      });
    });
    group("addEventToUser and removeEventfromUser", () {
      test("""addEventToUser adds the correct event to the correct user
      removeEventfromUser removes the correct event from the correct user""",
          () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        // Add a fake user with an event ID to the Firestore instance.
        final userRef = fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id);
        await userRef.set(EventsRepositoryUtils.matteo.toMap());

        final eventRef = fakeFirestore
            .collection('events')
            .doc(EventsRepositoryUtils.foodEvent.id);
        await eventRef.set(EventsRepositoryUtils.foodEvent.toMap());

        await myEventsRepository.addEventToUser(
            user: EventsRepositoryUtils.matteo,
            eventId: EventsRepositoryUtils.foodEvent.id);

        final participants = myEventsRepository
            .getParticipantsToEvent(EventsRepositoryUtils.foodEvent.id);

        await expectLater(participants,
            emits(predicate<List<OtherUser>>((list) {
          return list.isNotEmpty &&
              list.length == 1 &&
              list.first.id == EventsRepositoryUtils.matteo.id;
        })));

        await myEventsRepository.removeEventfromUser(
            user: EventsRepositoryUtils.matteo,
            eventId: EventsRepositoryUtils.foodEvent.id);
        await expectLater(participants,
            emits(predicate<List<OtherUser>>((list) {
          return list.isEmpty;
        })));
      });
    });
    group("saveNewEvent", () {
      test("saveNewEvent saves only to the correct user", () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);

        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id)
            .set(EventsRepositoryUtils.matteo.toMap());
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.marco.id)
            .set(EventsRepositoryUtils.marco.toMap());

        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.foodEvent,
          creator: EventsRepositoryUtils.matteo,
        );

        final matteoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.matteo.id);

        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isNotEmpty &&
              list.length == 1 &&
              list.first.name == EventsRepositoryUtils.foodEvent.name &&
              list.first.description ==
                  EventsRepositoryUtils.foodEvent.description &&
              list.first.date == EventsRepositoryUtils.foodEvent.date &&
              list.first.creatorId ==
                  EventsRepositoryUtils.foodEvent.creatorId &&
              list.first.private == EventsRepositoryUtils.foodEvent.private &&
              list.first.numParticipants == 1 &&
              list.first.location == EventsRepositoryUtils.foodEvent.location &&
              list.first.locationName ==
                  EventsRepositoryUtils.foodEvent.locationName;
        })));
        final marcoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.marco.id);

        await expectLater(marcoEvents, emits(predicate<List<Event>>((list) {
          return list.isEmpty;
        })));
      });

      test("saveNewEvent works with event with photo", () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id)
            .set(EventsRepositoryUtils.matteo.toMap());
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.marco.id)
            .set(EventsRepositoryUtils.marco.toMap());

        await myEventsRepository.saveNewEvent(
            event: EventsRepositoryUtils.foodEvent,
            creator: EventsRepositoryUtils.matteo,
            imageFile: XFile("test_resources/example.jpg"));

        final matteoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.matteo.id);

        ///check that a url is generated and saved for the new event photo
        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isNotEmpty && list.length == 1 && list.first.photo != "";
        })));
      });
    });
    group("modifyEvent", () {
      test("modify event modify the correct event with the new info", () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id)
            .set(EventsRepositoryUtils.matteo.toMap());

        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.foodEvent,
          creator: EventsRepositoryUtils.matteo,
        );

        final matteoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.matteo.id);

        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isNotEmpty && list.length == 1;
        })));

        final firstElement = await matteoEvents.first;
        final id = firstElement[0].id;
        var event = await myEventsRepository.getEventWithId(id);

        ///check that returned event is correct
        await expectLater(event, emits(predicate<Event>((event) {
          return event.category == EventsRepositoryUtils.foodEvent.category &&
              event.id == id &&
              event.name == EventsRepositoryUtils.foodEvent.name &&
              event.private == EventsRepositoryUtils.foodEvent.private &&
              event.description ==
                  EventsRepositoryUtils.foodEvent.description &&
              event.location == EventsRepositoryUtils.foodEvent.location &&
              event.date == EventsRepositoryUtils.foodEvent.date &&
              event.creatorId == EventsRepositoryUtils.foodEvent.creatorId &&
              event.locationName ==
                  EventsRepositoryUtils.foodEvent.locationName;
        })));

        ///modify event
        await myEventsRepository.modifyEvent(
            event: Event(
          category: "music",
          date: EventsRepositoryUtils.foodEvent.date,
          private: false,
          id: id,
          name: "newName",
          description: "newDescription",
          location: const GeoPoint(2, 2),
          locationName: "newLocationName",
        ));

        ///check that event has been modified as expected
        event = await myEventsRepository.getEventWithId(id);
        await expectLater(event, emits(predicate<Event>((event) {
          return event.category == "music" &&
              event.id == id &&
              event.name == "newName" &&
              event.category == "music" &&
              event.private == false &&
              event.description == "newDescription" &&
              event.location == const GeoPoint(2, 2) &&
              event.creatorId == EventsRepositoryUtils.foodEvent.creatorId &&
              event.date == EventsRepositoryUtils.foodEvent.date &&
              event.locationName == "newLocationName";
        })));
      });

      test("modify event can modify the photo", () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id)
            .set(EventsRepositoryUtils.matteo.toMap());

        await myEventsRepository.saveNewEvent(
            event: EventsRepositoryUtils.foodEvent,
            creator: EventsRepositoryUtils.matteo,
            imageFile: XFile("test_resources/example.jpg"));

        final matteoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.matteo.id);

        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isNotEmpty && list.length == 1;
        })));

        final firstElement = await matteoEvents.first;
        final String id = firstElement[0].id;
        final String oldPhoto = firstElement[0].photo!;
        var event = await myEventsRepository.getEventWithId(id);

        ///check that returned event is correct
        await expectLater(event, emits(predicate<Event>((event) {
          return event.category == EventsRepositoryUtils.foodEvent.category &&
              event.id == id &&
              event.name == EventsRepositoryUtils.foodEvent.name &&
              event.private == EventsRepositoryUtils.foodEvent.private &&
              event.description ==
                  EventsRepositoryUtils.foodEvent.description &&
              event.location == EventsRepositoryUtils.foodEvent.location &&
              event.date == EventsRepositoryUtils.foodEvent.date &&
              event.creatorId == EventsRepositoryUtils.foodEvent.creatorId &&
              event.photo == oldPhoto &&
              event.locationName ==
                  EventsRepositoryUtils.foodEvent.locationName;
        })));

        ///modify event
        await myEventsRepository.modifyEvent(
            event: Event(
              category: "music",
              date: EventsRepositoryUtils.foodEvent.date,
              private: false,
              id: id,
              name: "newName",
              description: "newDescription",
              location: const GeoPoint(2, 2),
              locationName: "newLocationName",
            ),
            imageFile: XFile("test_resources/example.jpg"));

        ///check that modified event has changed image
        event = await myEventsRepository.getEventWithId(id);
        await expectLater(event, emits(predicate<Event>((event) {
          return event.category == "music" &&
              event.id == id &&
              event.photo == oldPhoto;
        })));
      });
    });
    group("deleteEvent", () {
      test("deleteEvent deletes for all members", () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();
        final NotificationsRepository notificationsRepository =
            NotificationsRepository(firebaseFirestore: fakeFirestore);

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id)
            .set(EventsRepositoryUtils.matteo.toMap());
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.marco.id)
            .set(EventsRepositoryUtils.marco.toMap());

        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.foodEvent,
          creator: EventsRepositoryUtils.matteo,
        );

        var matteoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.matteo.id);

        await notificationsRepository.addNewNotification(
            notification: OurNotification(
                public: false,
                notificationId: '',
                userIds: ["marcoId"],
                thingToOpenId: "foodEventId",
                thingToNotifyName: "thingToNotifyName",
                sourceName: "sourceName",
                dateHour: "dateHour",
                timestamp: 123,
                chatMessage: "chatMessage",
                eventCategory: "eventCategory"));

        final firstElement = await matteoEvents.first;
        final id = firstElement[0].id;

        ///join event with marco
        await myEventsRepository.addEventToUser(
            user: EventsRepositoryUtils.marco, eventId: id);

        ///check that 2 people will attend the event
        var event = await myEventsRepository.getEventWithId(id);
        await expectLater(event, emits(predicate<Event>((event) {
          return event.category == EventsRepositoryUtils.foodEvent.category &&
              event.id == id &&
              event.numParticipants == 2 &&
              event.creatorId == EventsRepositoryUtils.foodEvent.creatorId;
        })));

        ///delete event
        await myEventsRepository.deleteSingleEvent(eventId: id);

        ///check that both users have 0 events
        matteoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.matteo.id);

        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isEmpty;
        })));
        final marcoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.marco.id);

        await expectLater(marcoEvents, emits(predicate<List<Event>>((list) {
          return list.isEmpty;
        })));
      });
    });
    group("removeEvent", () {
      test("removeEvent removes for only the correct user", () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id)
            .set(EventsRepositoryUtils.matteo.toMap());
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.marco.id)
            .set(EventsRepositoryUtils.marco.toMap());

        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.foodEvent,
          creator: EventsRepositoryUtils.matteo,
        );

        var matteoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.matteo.id);

        final firstElement = await matteoEvents.first;
        final id = firstElement[0].id;

        ///join event with marco
        await myEventsRepository.addEventToUser(
            user: EventsRepositoryUtils.marco, eventId: id);

        ///check that 2 people will attend the event
        var event = await myEventsRepository.getEventWithId(id);
        await expectLater(event, emits(predicate<Event>((event) {
          return event.category == EventsRepositoryUtils.foodEvent.category &&
              event.id == id &&
              event.numParticipants == 2 &&
              event.creatorId == EventsRepositoryUtils.foodEvent.creatorId;
        })));

        ///marco leaves the event
        await myEventsRepository.removeEventfromUser(
            user: EventsRepositoryUtils.marco, eventId: id);

        ///check that matteo has 1 event and marco has zero
        matteoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.matteo.id);

        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isNotEmpty && list.length == 1;
        })));
        final marcoEvents = await myEventsRepository
            .getEventsOfUser(EventsRepositoryUtils.marco.id);

        await expectLater(marcoEvents, emits(predicate<List<Event>>((list) {
          return list.isEmpty;
        })));

        ///check that event has 1 participant
        event = await myEventsRepository.getEventWithId(id);

        ///check that returned event is correct
        await expectLater(event, emits(predicate<Event>((event) {
          return event.numParticipants == 1;
        })));
      });
    });
    group("getNonPartecipatingEventOfUser", () {
      test(
          "getNonPartecipatingEventOfUser return all and only the events where the user is not in",
          () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id)
            .set(EventsRepositoryUtils.matteo.toMap());
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.marco.id)
            .set(EventsRepositoryUtils.marco.toMap());

        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.foodEvent,
          creator: EventsRepositoryUtils.matteo,
        );
        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.musicEvent,
          creator: EventsRepositoryUtils.matteo,
        );
        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.sportEvent,
          creator: EventsRepositoryUtils.marco,
        );

        ///check that only the event not joined by matteo is returned
        var matteoEvents = await myEventsRepository
            .getNonParticipatingEventsOfUser(
                EventsRepositoryUtils.matteo.id, ["food", "music", "sport"]);
        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isNotEmpty &&
              list.length == 1 &&
              list.first.name == EventsRepositoryUtils.sportEvent.name;
        })));

        ///check that both events not joined by marco are returned and are in date order
        var marcoEvents = await myEventsRepository
            .getNonParticipatingEventsOfUser(
                EventsRepositoryUtils.marco.id, ["food", "music", "sport"]);
        await expectLater(marcoEvents, emits(predicate<List<Event>>((list) {
          return list.isNotEmpty &&
              list.length == 2 &&
              list.first.name == EventsRepositoryUtils.musicEvent.name &&
              list[1].name == EventsRepositoryUtils.foodEvent.name;
        })));
      });
      test("getNonPartecipatingEventOfUser can be filtered by single category",
          () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id)
            .set(EventsRepositoryUtils.matteo.toMap());
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.marco.id)
            .set(EventsRepositoryUtils.marco.toMap());

        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.foodEvent,
          creator: EventsRepositoryUtils.matteo,
        );
        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.musicEvent,
          creator: EventsRepositoryUtils.matteo,
        );
        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.sportEvent,
          creator: EventsRepositoryUtils.marco,
        );

        ///check that only the event not joined by matteo is returned
        var matteoEvents = await myEventsRepository
            .getNonParticipatingEventsOfUser(
                EventsRepositoryUtils.matteo.id, ["food", "music", "sport"]);
        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isNotEmpty &&
              list.length == 1 &&
              list.first.name == EventsRepositoryUtils.sportEvent.name;
        })));

        ///check that filtering without its category will result in empty list
        matteoEvents = await myEventsRepository.getNonParticipatingEventsOfUser(
            EventsRepositoryUtils.matteo.id, ["food", "music"]);
        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isEmpty;
        })));

        ///check that asking for no category return empty list
        matteoEvents = await myEventsRepository.getNonParticipatingEventsOfUser(
            EventsRepositoryUtils.matteo.id, []);
        await expectLater(matteoEvents, emits(predicate<List<Event>>((list) {
          return list.isEmpty;
        })));
      });

      test(
          "getNonPartecipatingEventOfUser can be filtered by multiple category",
          () async {
        late MyEventsRepository myEventsRepository;
        late FakeFirebaseFirestore fakeFirestore = FakeFirebaseFirestore();
        final FirebaseStorage fakeStorage = MockFirebaseStorage();

        myEventsRepository = MyEventsRepository(
            firebaseFirestore: fakeFirestore, firebaseStorage: fakeStorage);
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.matteo.id)
            .set(EventsRepositoryUtils.matteo.toMap());
        await fakeFirestore
            .collection('users')
            .doc(EventsRepositoryUtils.marco.id)
            .set({
          "id": EventsRepositoryUtils.marco.id,
          "name": EventsRepositoryUtils.marco.name,
          "email": EventsRepositoryUtils.marco.email,
          "description": EventsRepositoryUtils.marco.interests,
          "photo": EventsRepositoryUtils.marco.photo,
          "interests": EventsRepositoryUtils.marco.interests,
          "events": [],
        });

        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.foodEvent,
          creator: EventsRepositoryUtils.matteo,
        );
        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.musicEvent,
          creator: EventsRepositoryUtils.matteo,
        );
        await myEventsRepository.saveNewEvent(
          event: EventsRepositoryUtils.sportEvent,
          creator: EventsRepositoryUtils.matteo,
        );

        ///check that only the 2 event with category in filter are returned
        var marcoEvents = await myEventsRepository
            .getNonParticipatingEventsOfUser(
                EventsRepositoryUtils.marco.id, ["food", "music"]);
        await expectLater(marcoEvents, emits(predicate<List<Event>>((list) {
          return list.isNotEmpty &&
              list.length == 2 &&
              list.first.name == EventsRepositoryUtils.musicEvent.name &&
              list[1].name == EventsRepositoryUtils.foodEvent.name;
        })));
      });
    });
  });
}
