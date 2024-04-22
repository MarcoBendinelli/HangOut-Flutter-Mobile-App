import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';

import '../utils.dart';

void main() {
  group("NotificationsRepository", () {
    test("getNotificationsOfUser", () async {
      /// Intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final NotificationsRepository notificationsRepository =
          NotificationsRepository(firebaseFirestore: firebaseFirestore);

      /// End of initialization

      /// Returns an empty list if the user has no notifications
      var notifications = await notificationsRepository.getNotifications("id");
      await expectLater(notifications,
          emits(predicate<List<OurNotification>>((list) {
        return list.isEmpty;
      })));

      /// Add a notification and now a list with the new notification is returned
      await notificationsRepository.addNewNotification(
          notification: RepositoryUtils.notification1);
      notifications = await notificationsRepository.getNotifications("id");
      await expectLater(notifications,
          emits(predicate<List<OurNotification>>((list) {
        return list.isNotEmpty &&
            list.first.chatMessage == "chatMessage" &&
            list.first.userIds.length == 1 &&
            list.first.userIds[0] == "id";
      })));

      /// Update the previous notification with a new message
      await notificationsRepository.addNewNotification(
          notification: RepositoryUtils.notificationSameIdOf1);
      notifications = await notificationsRepository.getNotifications("id");
      await expectLater(notifications,
          emits(predicate<List<OurNotification>>((list) {
        return list.isNotEmpty &&
            list.first.chatMessage == "chatMessage2" &&
            list.first.userIds.length == 1 &&
            list.first.userIds[0] == "id";
      })));
    });

    test("removeUserFromNotificationIds", () async {
      /// Intialization
      final FirebaseFirestore firebaseFirestore =
          await RepositoryUtils().getFakeFirestore();
      final NotificationsRepository notificationsRepository =
          NotificationsRepository(firebaseFirestore: firebaseFirestore);

      /// End of initialization

      /// Add a notification with 2 users
      await notificationsRepository.addNewNotification(
          notification: RepositoryUtils.notification2Users);
      // Get the notifications of the first user
      var notifications = await notificationsRepository.getNotifications("id1");

      await expectLater(notifications,
          emits(predicate<List<OurNotification>>((list) {
        return list.isNotEmpty &&
            list.first.chatMessage == "" &&
            list.first.userIds.length == 2 &&
            list.first.userIds[0] == "id1" &&
            list.first.userIds[1] == "id2";
      })));

      List<OurNotification> notificationsFirstUser = await notifications.first;
      String notificationId = notificationsFirstUser.first.notificationId;

      /// Remove the first user
      await notificationsRepository.removeUserFromNotification(
          idUser: "id1", idNotification: notificationId);
      // Get the notifications of the first user
      notifications = await notificationsRepository.getNotifications("id1");

      await expectLater(notifications,
          emits(predicate<List<OurNotification>>((list) {
        return list.isEmpty;
      })));

      // Get the notifications of the second user
      notifications = await notificationsRepository.getNotifications("id2");

      await expectLater(notifications,
          emits(predicate<List<OurNotification>>((list) {
        return list.isNotEmpty &&
            list.first.userIds.length == 1 &&
            list.first.userIds[0] == "id2";
      })));

      /// Remove also the second user
      await notificationsRepository.removeUserFromNotification(
          idUser: "id2", idNotification: notificationId);
      // Get the notifications of the second user
      notifications = await notificationsRepository.getNotifications("id2");

      await expectLater(notifications,
          emits(predicate<List<OurNotification>>((list) {
        return list.isEmpty;
      })));

      // Get the notifications of the second user
      notifications = await notificationsRepository.getNotifications("id1");

      await expectLater(notifications,
          emits(predicate<List<OurNotification>>((list) {
        return list.isEmpty;
      })));

      // Try to re delete the notification
      await notificationsRepository.removeUserFromNotification(
          idUser: "123", idNotification: notificationId);
    });
  });
}
