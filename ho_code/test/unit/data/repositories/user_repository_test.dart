import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../utils.dart';

void main() {
  group('UserRepository', () {
    test("getUserData", () async {
      ///intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();

      final UserRepository userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      ///end of initialization
      ///test getting first user
      var user = await userRepository.getUserData("user1Id");
      expect(user.id, "user1Id");
      expect(user.name, "user1");
      expect(user.description, "user1 description");
      expect(user.email, "user1@mail.com");
      expect(user.photo, "");
      expect(user.interests, ["food", "party"]);

      ///test getting second user
      user = await userRepository.getUserData("user2Id");
      expect(user.id, "user2Id");
      expect(user.name, "user2");
      expect(user.description, "user2 description");
      expect(user.email, "user2@mail.com");
      expect(user.photo, "");
      expect(user.interests, ["food", "sport"]);
    });

    test("modify User - no nickname - no photo", () async {
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();

      final UserRepository userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      await userRepository.modifyUser(
          user: const UserData(
              id: "user1Id",
              name: "name",
              email: "NEWemail",
              description: "NEWdescription",
              photo: "photo",
              interests: [],
              notificationsPush: true,
              notificationsGroupChat: true,
              notificationsEventChat: true,
              notificationsJoinGroup: true,
              notificationsInviteEvent: true,
              notificationsPublicEvent: true,
              notificationsPublicGroup: true),
          profileImage: null,
          isNicknameModified: false);

      UserData user = await userRepository.getUserData("user1Id");

      expect(user.id, "user1Id");
      expect(user.name, "name");
      expect(user.email, "NEWemail");
      expect(user.description, "NEWdescription");
    });

    test("modify User - yes nickname", () async {
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();

      final UserRepository userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      final ChatRepository chatRepository = ChatRepository(
        firebaseFirestore: firebaseFirestore,
      );

      chatRepository.sendTextMessageInTheGroup(
          message: TextMessage(
              text: "text",
              timeStamp: 123,
              dateHour: "dateHour",
              senderId: "user1Id",
              senderNickname: "name",
              senderPhoto: "photo"),
          groupId: "groupXId");

      await userRepository.modifyUser(
          user: const UserData(
              id: "user1Id",
              name: "NEWname",
              email: "NEWemail",
              description: "NEWdescription",
              photo: "photo",
              interests: [],
              notificationsPush: true,
              notificationsGroupChat: true,
              notificationsEventChat: true,
              notificationsJoinGroup: true,
              notificationsInviteEvent: true,
              notificationsPublicEvent: true,
              notificationsPublicGroup: true),
          profileImage: null,
          isNicknameModified: true);

      UserData user = await userRepository.getUserData("user1Id");
      var chatStream =
          chatRepository.getTheChatOfTheGroupWithId(groupId: "groupXId");
      var chat = await chatStream.first;

      expect(user.id, "user1Id");
      expect(user.name, "NEWname");
      expect(user.email, "NEWemail");
      expect(user.description, "NEWdescription");

      expect(chat.first.senderId, "user1Id");
      expect(chat.first.senderNickname, "NEWname");
    });

    test("modify User - yes photo", () async {
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();

      final UserRepository userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      final ChatRepository chatRepository = ChatRepository(
        firebaseFirestore: firebaseFirestore,
      );

      chatRepository.sendTextMessageInTheGroup(
          message: TextMessage(
              text: "text",
              timeStamp: 123,
              dateHour: "dateHour",
              senderId: "user1Id",
              senderNickname: "name",
              senderPhoto: "photo"),
          groupId: "groupXId");

      await userRepository.modifyUser(
          user: const UserData(
              id: "user1Id",
              name: "name",
              email: "NEWemail",
              description: "NEWdescription",
              photo: "photo",
              interests: [],
              notificationsPush: true,
              notificationsGroupChat: true,
              notificationsEventChat: true,
              notificationsJoinGroup: true,
              notificationsInviteEvent: true,
              notificationsPublicEvent: true,
              notificationsPublicGroup: true),
          profileImage: XFile("test_resources/example.jpg"),
          isNicknameModified: false);

      UserData user = await userRepository.getUserData("user1Id");
      var chatStream =
          chatRepository.getTheChatOfTheGroupWithId(groupId: "groupXId");
      var chat = await chatStream.first;

      expect(user.id, "user1Id");
      expect(user.name, "name");
      expect(user.email, "NEWemail");
      expect(user.description, "NEWdescription");

      expect(chat.first.senderId, "user1Id");
      expect(chat.first.senderNickname, "name");
      expect(chat.first.senderPhoto != "", true);
    });

    test("modify User - yes nickname - yes photo", () async {
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();

      final UserRepository userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      final ChatRepository chatRepository = ChatRepository(
        firebaseFirestore: firebaseFirestore,
      );

      chatRepository.sendTextMessageInTheGroup(
          message: TextMessage(
              text: "text",
              timeStamp: 123,
              dateHour: "dateHour",
              senderId: "user1Id",
              senderNickname: "name",
              senderPhoto: "photo"),
          groupId: "groupXId");

      await userRepository.modifyUser(
          user: const UserData(
              id: "user1Id",
              name: "newName",
              email: "NEWemail",
              description: "NEWdescription",
              photo: "photo",
              interests: [],
              notificationsPush: true,
              notificationsGroupChat: true,
              notificationsEventChat: true,
              notificationsJoinGroup: true,
              notificationsInviteEvent: true,
              notificationsPublicEvent: true,
              notificationsPublicGroup: true),
          profileImage: XFile("test_resources/example.jpg"),
          isNicknameModified: true);

      UserData user = await userRepository.getUserData("user1Id");
      var chatStream =
          chatRepository.getTheChatOfTheGroupWithId(groupId: "groupXId");
      var chat = await chatStream.first;

      expect(user.id, "user1Id");
      expect(user.name, "newName");
      expect(user.email, "NEWemail");
      expect(user.description, "NEWdescription");

      expect(chat.first.senderId, "user1Id");
      expect(chat.first.senderNickname, "newName");
      expect(chat.first.senderPhoto != "", true);
    });

    test("get interested users to notify", () async {
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();

      final UserRepository userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      List<String> userIds = await userRepository.getInterestedUsersToNotify(
          newGroupEventInterests: ["samba"]);

      expect(userIds.isEmpty, true);

      List<String> ids = await userRepository.getInterestedUsersToNotify(
          newGroupEventInterests: ["party"]);

      expect(ids.isEmpty, false);
    });

    test("getUserDataStream", () async {
      ///intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();

      final UserRepository userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      ///end of initialization
      ///test getting first user
      var userStream = userRepository.getUserDataStream("user1Id");
      var user = await userStream.first;
      expect(user.id, "user1Id");
      expect(user.name, "user1");
      expect(user.description, "user1 description");
      expect(user.email, "user1@mail.com");
      expect(user.photo, "");
      expect(user.interests, ["food", "party"]);

      ///test getting second user
      userStream = userRepository.getUserDataStream("user2Id");
      user = await userStream.first;
      expect(user.id, "user2Id");
      expect(user.name, "user2");
      expect(user.description, "user2 description");
      expect(user.email, "user2@mail.com");
      expect(user.photo, "");
      expect(user.interests, ["food", "sport"]);
    });

    test("getAllUsers", () async {
      ///intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();

      final UserRepository userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      ///end of initialization
      var userStream = userRepository.getAllUsers();
      await expectLater(userStream, emits(predicate<List<UserData>>((list) {
        return list.isNotEmpty &&
            list.length == 3 &&
            list.first.id == "user1Id" &&
            list[1].id == "user2Id";
      })));
    });
    test("getTheseUsers", () async {
      ///intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();

      final UserRepository userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      ///end of initialization
      ///Test getting zero users
      var userStream = userRepository.getTheseUsers([]);
      var userList = await userStream.first;
      expect(true, userList.isEmpty);

      ///test getting first user
      userStream = userRepository.getTheseUsers(["user1Id"]);
      userList = await userStream.first;
      expect(1, userList.length);
      var user = userList[0];
      expect(user.id, "user1Id");

      ///test getting both users
      userStream = userRepository.getTheseUsers(["user1Id", "user2Id"]);
      userList = await userStream.first;
      expect(2, userList.length);

      expect(userList[0].id, "user1Id");
      expect(userList[1].id, "user2Id");
    });
  });
}
