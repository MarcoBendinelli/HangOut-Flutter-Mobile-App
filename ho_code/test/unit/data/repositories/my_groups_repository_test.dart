import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../utils.dart';

void main() {
  group("MyGroupsRepository", () {
    test("getGroupsOfUser", () async {
      ///intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();
      final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      ///end of initialization

      ///returns an empty list if the user has no group
      var groups = await myGroupsRepository.getGroupsOfUser("user1Id");
      await expectLater(groups, emits(predicate<List<Group>>((list) {
        return list.isEmpty;
      })));

      ///joins a group and now a list with the joined group is returned
      await myGroupsRepository.joinGroup(
          user: RepositoryUtils.otherUser1, groupId: "group1Id");
      groups = await myGroupsRepository.getGroupsOfUser("user1Id");
      await expectLater(groups, emits(predicate<List<Group>>((list) {
        return list.isNotEmpty &&
            list.first.id == "group1Id" &&
            list.first.members!.length == 1 &&
            list.first.members![0] == "user1Id";
      })));

      ///joins another group and now the 2 groups are returned
      await myGroupsRepository.joinGroup(
          user: RepositoryUtils.otherUser1, groupId: "group2Id");
      groups = await myGroupsRepository.getGroupsOfUser("user1Id");
      await expectLater(groups, emits(predicate<List<Group>>((list) {
        return list.isNotEmpty &&
            list.length == 2 &&
            list.first.id == "group1Id" &&
            list[1].id == "group2Id";
      })));
    });

    group("getNonParticipatingGroupsOfUser", () {
      test("getNonParticipatingGroupsOfUser", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization

        ///returns a list with the 2 groups the user is not part of
        var groups = await myGroupsRepository
            .getNonParticipatingGroupOfUser("user1Id", ["food", "party"]);
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty && list.length == 2;
        })));

        ///joins a group and now a list the list has only the non joined group
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group1Id");
        groups = await myGroupsRepository
            .getNonParticipatingGroupOfUser("user1Id", ["food", "party"]);
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty && list.first.id == "group2Id";
        })));

        ///joins the second group and list is now empty
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group2Id");
        groups = await myGroupsRepository
            .getNonParticipatingGroupOfUser("user1Id", ["food", "party"]);
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isEmpty;
        })));

        ///for another user the list is still composed of both the groups
        groups = await myGroupsRepository
            .getNonParticipatingGroupOfUser("user2Id", ["food", "party"]);
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty && list.length == 2;
        })));
      });
      test("getNonParticipatingGroupsOfUser with filters", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization

        ///returns a list with the 1 groups that match the interest
        var groups = await myGroupsRepository
            .getNonParticipatingGroupOfUser("user1Id", ["party"]);
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty && list.first.id == "group2Id";
        })));

        ///joins the group and now the list filtered is empty
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group2Id");
        groups = await myGroupsRepository
            .getNonParticipatingGroupOfUser("user1Id", ["party"]);
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isEmpty;
        })));

        ///for another user the list is still composed of both the groups
        groups = await myGroupsRepository
            .getNonParticipatingGroupOfUser("user2Id", ["food", "party"]);
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty && list.length == 2;
        })));
      });
      test("getNonParticipatingGroupsOfUser with no filter selected", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization

        ///returns a empty list if no interest is selected
        var groups = await myGroupsRepository
            .getNonParticipatingGroupOfUser("user1Id", []);
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isEmpty;
        })));
      });
    });

    test("joinGroup", () async {
      ///intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();
      final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      ///end of initialization
      Stream<Group> groupStream =
          await myGroupsRepository.getGroupWithId("group1Id");
      Group group = await groupStream.first;
      expect([], group.members);
      expect(0, group.numParticipants);
      await myGroupsRepository.joinGroup(
          user: RepositoryUtils.otherUser1, groupId: "group1Id");
      groupStream = await myGroupsRepository.getGroupWithId("group1Id");
      group = await groupStream.first;
      expect(["user1Id"], group.members);
      expect(1, group.numParticipants);
      var groupsStream = await myGroupsRepository.getGroupsOfUser("user1Id");
      await expectLater(groupsStream, emits(predicate<List<Group>>((list) {
        return list.isNotEmpty &&
            list.length == 1 &&
            list.first.id == "group1Id";
      })));
    });

    group("leaveGroup", () {
      test("leaveGroup", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);
        final NotificationsRepository notificationsRepository =
            NotificationsRepository(firebaseFirestore: firebaseFirestore);

        ///end of initialization
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group1Id");
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group2Id");
        await notificationsRepository.addNewNotification(
            notification: OurNotification(
                public: false,
                notificationId: '',
                userIds: ["user1Id"],
                thingToOpenId: "group1Id",
                thingToNotifyName: "thingToNotifyName",
                sourceName: "sourceName",
                dateHour: "dateHour",
                timestamp: 123,
                chatMessage: "chatMessage",
                eventCategory: "eventCategory"));

        ///user starts with 2 groups
        var groupsStream = await myGroupsRepository.getGroupsOfUser("user1Id");
        await expectLater(groupsStream, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty && list.length == 2;
        })));

        ///remove one and user has only the other left
        await myGroupsRepository.leaveGroup(
            groupId: "group1Id", userId: "user1Id");
        await expectLater(groupsStream, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty &&
              list.length == 1 &&
              list.first.id == "group2Id";
        })));

        ///remove also the second and user has now 0 groups
        await myGroupsRepository.leaveGroup(
            groupId: "group2Id", userId: "user1Id");
        await expectLater(groupsStream, emits(predicate<List<Group>>((list) {
          return list.isEmpty;
        })));
      });
      test("leaveGroup doesn't affect other users", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization
        ///Both users join both groups
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group1Id");
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group2Id");
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser2, groupId: "group1Id");
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser2, groupId: "group2Id");

        ///remove one user from both groups
        await myGroupsRepository.leaveGroup(
            groupId: "group1Id", userId: "user1Id");

        ///remove also the second and user has now 0 groups
        await myGroupsRepository.leaveGroup(
            groupId: "group2Id", userId: "user1Id");

        ///the other user is not modified
        var groupsStream = await myGroupsRepository.getGroupsOfUser("user2Id");
        await expectLater(groupsStream, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty && list.length == 2;
        })));
      });
    });

    group("deleteGroup", () {
      test("with single members", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group1Id");
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group2Id");
        var groups = await myGroupsRepository.getGroupsOfUser("user1Id");
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty && list.length == 2;
        })));

        ///delete one group and check that only the second remains
        await myGroupsRepository.deleteGroupWithId(groupId: "group1Id");
        groups = await myGroupsRepository.getGroupsOfUser("user1Id");
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty &&
              list.length == 1 &&
              list.first.id == "group2Id";
        })));

        ///delete the second and check that user has no more groups
        await myGroupsRepository.deleteGroupWithId(groupId: "group2Id");
        groups = await myGroupsRepository.getGroupsOfUser("user1Id");
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isEmpty;
        })));
      });
      test("with multiple members", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization
        ///Both users join both groups
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group1Id");
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser1, groupId: "group2Id");
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser2, groupId: "group1Id");
        await myGroupsRepository.joinGroup(
            user: RepositoryUtils.otherUser2, groupId: "group2Id");

        ///delete one group and check that its been deleted for both users
        await myGroupsRepository.deleteGroupWithId(groupId: "group1Id");
        var groups = await myGroupsRepository.getGroupsOfUser("user1Id");
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty &&
              list.length == 1 &&
              list.first.id == "group2Id";
        })));
        groups = await myGroupsRepository.getGroupsOfUser("user2Id");
        await expectLater(groups, emits(predicate<List<Group>>((list) {
          return list.isNotEmpty &&
              list.length == 1 &&
              list.first.id == "group2Id";
        })));
      });
    });

    test("getParticipantsToGroup", () async {
      ///intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();
      final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      ///end of initialization
      await myGroupsRepository.joinGroup(
          user: RepositoryUtils.otherUser1, groupId: "group1Id");
      final groups = myGroupsRepository.getParticipantsToGroup("group1Id");
      await expectLater(groups, emits(predicate<List<OtherUser>>((list) {
        return list.isNotEmpty &&
            list.length == 1 &&
            list.first.id == "user1Id";
      })));
      await myGroupsRepository.joinGroup(
          user: RepositoryUtils.otherUser2, groupId: "group1Id");
      await expectLater(groups, emits(predicate<List<OtherUser>>((list) {
        return list.isNotEmpty &&
            list.length == 2 &&
            list.first.id != list[1].id;
      })));
    });

    test("getCommonGroups", () async {
      ///intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final FirebaseStorage firebaseStorage = MockFirebaseStorage();
      final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);

      ///end of initialization
      ///common groups is empty at the start
      var commonGroups =
          await myGroupsRepository.getCommonGroups("user1Id", "user2Id");
      await expectLater(commonGroups, emits(predicate<List<Group>>((list) {
        return list.isEmpty;
      })));

      ///first user join one group but common is still empty
      await myGroupsRepository.joinGroup(
          user: RepositoryUtils.otherUser1, groupId: "group1Id");
      commonGroups =
          await myGroupsRepository.getCommonGroups("user1Id", "user2Id");
      await expectLater(commonGroups, emits(predicate<List<Group>>((list) {
        return list.isEmpty;
      })));

      ///second user join another group and common is still empty
      await myGroupsRepository.joinGroup(
          user: RepositoryUtils.otherUser2, groupId: "group2Id");
      commonGroups =
          await myGroupsRepository.getCommonGroups("user1Id", "user2Id");
      await expectLater(commonGroups, emits(predicate<List<Group>>((list) {
        return list.isEmpty;
      })));

      ///second user join first user group common is now the common one
      await myGroupsRepository.joinGroup(
          user: RepositoryUtils.otherUser2, groupId: "group1Id");
      commonGroups =
          await myGroupsRepository.getCommonGroups("user1Id", "user2Id");
      await expectLater(commonGroups, emits(predicate<List<Group>>((list) {
        return list.isNotEmpty &&
            list.length == 1 &&
            list.first.id == "group1Id";
      })));
    });

    group("modifyGroup", () {
      test("modify group with no image", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization
        ///add 2 users
        await myGroupsRepository.modifyGroup(
            group: Group(
              id: "group1Id",
              name: "newName",
              creatorId: "user1Id",
              caption: "newCaption",
              isPrivate: true,
              interests: ["food", "music"],
            ),
            imageFile: null,
            newMembers: [
              RepositoryUtils.otherUser1,
              RepositoryUtils.otherUser2,
            ],
            creatorId: "user1Id");
        var groupStream = await myGroupsRepository.getGroupWithId("group1Id");
        var group = await groupStream.first;
        expect(group.name, "newName");
        expect(group.caption, "newCaption");
        expect(group.isPrivate, true);
        expect(group.interests, ["food", "music"]);
        expect(group.numParticipants, 2);

        ///modify to have only user 1
        await myGroupsRepository.modifyGroup(
            group: Group(
              id: "group1Id",
              name: "newName2",
              creatorId: "user1Id",
              caption: "newCaption2",
              isPrivate: true,
              interests: ["food", "music"],
            ),
            imageFile: null,
            newMembers: [
              RepositoryUtils.otherUser1,
            ],
            creatorId: "user1Id");
        groupStream = await myGroupsRepository.getGroupWithId("group1Id");
        group = await groupStream.first;
        expect(group.name, "newName2");
        expect(group.caption, "newCaption2");
        expect(group.isPrivate, true);
        expect(group.interests, ["food", "music"]);
        expect(group.numParticipants, 1);

        ///try to remove owner
        await myGroupsRepository.modifyGroup(
            group: Group(
              id: "group1Id",
              name: "newName3",
              creatorId: "user1Id",
              caption: "newCaption3",
              isPrivate: true,
              interests: ["food", "music"],
            ),
            imageFile: null,
            newMembers: [
              RepositoryUtils.otherUser1,
            ],
            creatorId: "user1Id");
        groupStream = await myGroupsRepository.getGroupWithId("group1Id");
        group = await groupStream.first;
        expect(group.name, "newName3");
        expect(group.caption, "newCaption3");
        expect(group.isPrivate, true);
        expect(group.interests, ["food", "music"]);
        expect(group.numParticipants, 1);
      });
      test("modify group with image", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization
        await myGroupsRepository.modifyGroup(
            group: Group(
              id: "group1Id",
              name: "newName",
              creatorId: "user1Id",
              caption: "newCaption",
              isPrivate: true,
              interests: ["food", "music"],
            ),
            imageFile: XFile("test_resources/example.jpg"),
            newMembers: [
              RepositoryUtils.otherUser1,
              RepositoryUtils.otherUser2
            ],
            creatorId: "user1Id");
        final groupStream = await myGroupsRepository.getGroupWithId("group1Id");
        final group = await groupStream.first;
        expect(group.name, "newName");
        expect(group.caption, "newCaption");
        expect(group.isPrivate, true);
        expect(true, group.photo!.isNotEmpty);
        expect(group.interests, ["food", "music"]);
      });
    });

    group("saveNewGroup", () {
      test("save group no image", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization

        await myGroupsRepository.saveNewGroup(
            group: Group(
                id: "",
                name: "newName",
                caption: "newCaption",
                creatorId: "user1Id",
                numParticipants: 2,
                isPrivate: true,
                interests: ["food", "music"],
                photo: ""),
            creator: RepositoryUtils.otherUser1,
            imageFile: null,
            members: [RepositoryUtils.otherUser1, RepositoryUtils.otherUser2]);
        final groupStream = await myGroupsRepository.getGroupsOfUser("user1Id");
        final groupList = await groupStream.first;
        final group = groupList[0];
        expect(group.name, "newName");
        expect(group.caption, "newCaption");
        expect(group.isPrivate, true);
        expect(group.interests, <String>["food", "music"]);
        expect(group.numParticipants, 2);
      });
      test("save group with image", () async {
        ///intialization
        final FirebaseFirestore firebaseFirestore =
            await RepositoryUtils().getFakeFirestore();
        final FirebaseStorage firebaseStorage = MockFirebaseStorage();
        final MyGroupsRepository myGroupsRepository = MyGroupsRepository(
            firebaseFirestore: firebaseFirestore,
            firebaseStorage: firebaseStorage);

        ///end of initialization

        await myGroupsRepository.saveNewGroup(
            group: Group(
                id: "",
                name: "newName",
                caption: "newCaption",
                creatorId: "user1Id",
                numParticipants: 2,
                isPrivate: true,
                interests: ["food", "music"],
                photo: ""),
            creator: RepositoryUtils.otherUser1,
            imageFile: XFile("test_resources/example.jpg"),
            members: [RepositoryUtils.otherUser1, RepositoryUtils.otherUser2]);
        final groupStream = await myGroupsRepository.getGroupsOfUser("user1Id");
        final groupList = await groupStream.first;
        final group = groupList[0];
        expect(group.name, "newName");
        expect(group.caption, "newCaption");
        expect(group.isPrivate, true);
        expect(group.interests, <String>["food", "music"]);
        expect(group.numParticipants, 2);
        expect(true, group.photo!.isNotEmpty);
      });
    });
  });
}
