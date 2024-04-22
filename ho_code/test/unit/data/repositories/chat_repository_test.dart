import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../utils.dart';

void main() {
  group("chatRepository", () {
    test("GetTheChatOfTheGroupWithId", () async {
      ///intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final ChatRepository chatRepository = ChatRepository(
        firebaseFirestore: firebaseFirestore,
      );

      ///end of initialization
      ///check that messages are empty on initial group with no message
      var messagesStream =
          chatRepository.getTheChatOfTheGroupWithId(groupId: "group1Id");
      var messagesList = await messagesStream.first;
      expect(true, messagesList.isEmpty);

      ///send message to that group
      final date = Timestamp.fromDate(DateTime(2022, 10, 30, 18, 30));
      await chatRepository.sendTextMessageInTheGroup(
        message: TextMessage(
          text: "test message",
          timeStamp: date.microsecondsSinceEpoch,
          dateHour: "DateHour",
          senderId: "user1Id",
          senderNickname: "user1",
          senderPhoto: "",
        ),
        groupId: "group1Id",
      );

      ///check that now there is a message a that it is the wanted message
      messagesStream =
          chatRepository.getTheChatOfTheGroupWithId(groupId: "group1Id");
      messagesList = await messagesStream.first;
      var castedList = messagesList.cast<TextMessage>();
      expect(messagesList.length, 1);
      expect(castedList[0].text, "test message");

      ///check that messages are empty on another group
      messagesStream =
          chatRepository.getTheChatOfTheGroupWithId(groupId: "group2Id");
      messagesList = await messagesStream.first;
      expect(true, messagesList.isEmpty);
    });

    test("GetTheChatOfTheEventWithId", () async {
      ///initialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final ChatRepository chatRepository = ChatRepository(
        firebaseFirestore: firebaseFirestore,
      );

      ///end of initialization
      ///check that messages are empty on initial event with no message
      var messagesStream =
          chatRepository.getTheChatOfTheEventWithId(eventId: "event1Id");
      var messagesList = await messagesStream.first;
      expect(true, messagesList.isEmpty);

      ///send message to that event
      final date = Timestamp.fromDate(DateTime(2022, 10, 30, 18, 30));
      await chatRepository.sendTextMessageInTheEvent(
        message: TextMessage(
          text: "test message",
          timeStamp: date.microsecondsSinceEpoch,
          dateHour: "DateHour",
          senderId: "user1Id",
          senderNickname: "user1",
          senderPhoto: "",
        ),
        eventId: "event1Id",
      );

      ///check that now there is a message and that it is the wanted message
      messagesStream =
          chatRepository.getTheChatOfTheEventWithId(eventId: "event1Id");
      messagesList = await messagesStream.first;
      var castedList = messagesList.cast<TextMessage>();
      expect(messagesList.length, 1);
      expect(castedList[0].text, "test message");

      ///check that messages are empty on another event with no message
      messagesStream =
          chatRepository.getTheChatOfTheEventWithId(eventId: "event2Id");
      messagesList = await messagesStream.first;
      expect(true, messagesList.isEmpty);
    });

    test("delete event with chat", () async {
      ///initialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();
      final ChatRepository chatRepository = ChatRepository(
        firebaseFirestore: firebaseFirestore,
      );
      final MyEventsRepository myEventsRepository = MyEventsRepository(
        firebaseFirestore: firebaseFirestore,
        firebaseStorage: firebaseStorage,
      );

      ///end of initialization
      ///check that messages are empty on initial event with no message
      var messagesStream =
          chatRepository.getTheChatOfTheEventWithId(eventId: "event1Id");
      var messagesList = await messagesStream.first;
      expect(true, messagesList.isEmpty);

      ///send message to that event
      final date = Timestamp.fromDate(DateTime(2022, 10, 30, 18, 30));
      await chatRepository.sendTextMessageInTheEvent(
        message: TextMessage(
          text: "test message",
          timeStamp: date.microsecondsSinceEpoch,
          dateHour: "DateHour",
          senderId: "user1Id",
          senderNickname: "user1",
          senderPhoto: "",
        ),
        eventId: "event1Id",
      );

      ///check that now there is a message and that it is the wanted message
      messagesStream =
          chatRepository.getTheChatOfTheEventWithId(eventId: "event1Id");
      messagesList = await messagesStream.first;
      var castedList = messagesList.cast<TextMessage>();
      expect(messagesList.length, 1);
      expect(castedList[0].text, "test message");

      ///modify event to insert image
      myEventsRepository.modifyEvent(
          event: Event(
              category: "sport",
              date: date,
              private: true,
              id: "event1Id",
              name: "name",
              description: "description",
              location: const GeoPoint(0, 0),
              locationName: "locationName"),
          imageFile: XFile("test_resources/example.jpg"));

      ///now delete event with both chat and image
      myEventsRepository.deleteSingleEvent(eventId: "event1Id");
    });

    test("delete group with chat", () async {
      ///initialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();
      final ChatRepository chatRepository = ChatRepository(
        firebaseFirestore: firebaseFirestore,
      );
      final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
        firebaseFirestore: firebaseFirestore,
        firebaseStorage: firebaseStorage,
      );

      ///end of initialization
      ///check that messages are empty on initial event with no message
      var messagesStream =
          chatRepository.getTheChatOfTheGroupWithId(groupId: "group1Id");
      var messagesList = await messagesStream.first;
      expect(true, messagesList.isEmpty);

      ///send message to that event
      final date = Timestamp.fromDate(DateTime(2022, 10, 30, 18, 30));
      await chatRepository.sendTextMessageInTheGroup(
        message: TextMessage(
          text: "test message",
          timeStamp: date.microsecondsSinceEpoch,
          dateHour: "DateHour",
          senderId: "user1Id",
          senderNickname: "user1",
          senderPhoto: "",
        ),
        groupId: "group1Id",
      );

      ///check that now there is a message and that it is the wanted message
      messagesStream =
          chatRepository.getTheChatOfTheGroupWithId(groupId: "group1Id");
      messagesList = await messagesStream.first;
      var castedList = messagesList.cast<TextMessage>();
      expect(messagesList.length, 1);
      expect(castedList[0].text, "test message");

      ///modify group to insert image
      myGroupsRepository.modifyGroup(
        group: Group(
          id: "group1Id",
          name: "group1",
          creatorId: "user1Id",
          caption: "caption",
          isPrivate: true,
          interests: [],
        ),
        imageFile: XFile("test_resources/example.jpg"),
        newMembers: [],
        creatorId: "user1Id",
      );

      ///delete group with image and chat
      myGroupsRepository.deleteGroupWithId(groupId: "group1Id");
    });
  });
}
