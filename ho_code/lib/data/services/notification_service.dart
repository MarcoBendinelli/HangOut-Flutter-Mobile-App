import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static bool isTest = false;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;
  final FirebaseFirestore _db;
  final FirebaseMessaging _firebaseMessaging;
  bool amIInitialized = false;
  late String _currentUserId;
  late String _currentTokenDevice;
  late Function _onClickGroupNotification;
  late Function _onClickPublicGroupNotification;
  late Function _onClickEventNotification;
  late Function _onClickChatGroupNotification;
  late Function _onClickChatEventNotification;
  late InitializationSettings initializationSettings;
  final http.Client _client;

  NotificationService({
    FirebaseFirestore? firebaseFirestore,
    FirebaseMessaging? firebaseMessaging,
    FlutterLocalNotificationsPlugin? localNotificationsPlugin,
    http.Client? client,
  })  : _db = firebaseFirestore ?? FirebaseFirestore.instance,
        _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        _client = client ?? http.Client(),
        _localNotificationsPlugin =
            localNotificationsPlugin ?? FlutterLocalNotificationsPlugin();

  void setOnNotInitialized() {
    amIInitialized = false;
    deleteToken();
  }

  void deleteToken() async {
    try {
      await _db.collection("tokens").doc(_currentUserId).update({
        'token': FieldValue.arrayRemove([_currentTokenDevice]),
      });
    } catch (e) {
      debugPrint("There is not token to delete");
    }
  }

  Future<void> firstInitialization(String userId) async {
    if (!amIInitialized) {
      debugPrint("First initialization of the notification service...");
      try {
        _currentUserId = userId;
      } catch (e) {
        debugPrint(e.toString());
      }

      try {
        if (!isTest) {
          requestFirebaseMessagingPermission();
          getAndSaveToken();
        }
        initializeSettings();
        amIInitialized = true;
      } catch (e) {
        debugPrint("The request to FirebaseMessaging is already sent");
      }
    }
  }

  Future<void> setNotificationsBehaviour(
      {required Function onClickGroupNotification,
      required Function onClickEventNotification,
      required Function onClickChatGroupNotification,
      required Function onClickChatEventNotification,
      required Function onClickPublicGroupNotification}) async {
    debugPrint("Setting the Notification behaviours...");

    try {
      _onClickChatGroupNotification = onClickChatGroupNotification;
    } catch (e) {
      debugPrint(e.toString());
    }
    try {
      _onClickChatEventNotification = onClickChatEventNotification;
    } catch (e) {
      debugPrint(e.toString());
    }
    try {
      _onClickEventNotification = onClickEventNotification;
    } catch (e) {
      debugPrint(e.toString());
    }
    try {
      _onClickGroupNotification = onClickGroupNotification;
    } catch (e) {
      debugPrint(e.toString());
    }

    try {
      _onClickPublicGroupNotification = onClickPublicGroupNotification;
    } catch (e) {
      debugPrint(e.toString());
    }

    await _localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    firebaseMessagingSetUp();
  }

  Future<void> requestFirebaseMessagingPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("User granted provisional permission");
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  /// This is the device token, if we use a different emulator / device
  /// we will have a different token
  Future<void> getAndSaveToken() async {
    try {
      await _firebaseMessaging.getToken().then((token) async {
        debugPrint("My token is $token");
        _currentTokenDevice = token!;
        await _db.collection("tokens").doc(_currentUserId).update({
          'token': FieldValue.arrayUnion([token]),
        });
      });
    } catch (e) {
      await _firebaseMessaging.getToken().then((token) async {
        debugPrint("My token is $token");
        _currentTokenDevice = token!;
        await _db.collection("tokens").doc(_currentUserId).set({
          'token': FieldValue.arrayUnion([token]),
        });
      });
    }
  }

  void initializeSettings() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true);

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    initializationSettings = const InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux);
  }

  void firebaseMessagingSetUp() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      String title = message.notification!.title.toString();
      String body = message.notification!.body.toString();

      debugPrint("-------------------onMessage---------------------------");
      debugPrint("onMessage: $title/$body");

      firebaseOnListen(body: body, title: title);
    });
  }

  Future<void> firebaseOnListen(
      {required String title, required String body}) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'HangOut',
      'HangOut',
      importance: Importance.high,
      styleInformation: bigTextStyleInformation,
      priority: Priority.high,
      playSound: true,
    );

    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
      threadIdentifier: "thread_id",
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
        macOS: darwinNotificationDetails);

    await _localNotificationsPlugin.show(0, title, body, notificationDetails,
        payload: body);
  }

  Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    try {
      final String? payload = notificationResponse.payload;

      if (notificationResponse.payload != null &&
          notificationResponse.payload!.isNotEmpty) {
        debugPrint('The notification is clicked, payload: $payload');
        List<String> splitPayload = payload!.split(":");

        String thingToJoin = splitPayload[0];
        String thingToJoinName = splitPayload[1];

        if (thingToJoin.contains("group") &&
            !thingToJoin.contains("chat") &&
            !thingToJoin.contains("new")) {
          // New group notification
          String idGroup =
              await getIdGroupWhereCurrentUserIsIn(thingToJoinName);
          _onClickGroupNotification(idGroup);
        } else if (thingToJoin.contains("group") &&
            !thingToJoin.contains("chat") &&
            thingToJoin.contains("new")) {
          // New group notification
          String idGroup = await getIdGroup(thingToJoinName);
          _onClickPublicGroupNotification(idGroup);
        } else if (thingToJoin.contains("event") &&
            !thingToJoin.contains("chat")) {
          // New event notification
          String idEvent = await getIdEvent(thingToJoinName);
          _onClickEventNotification(idEvent);
        } else if (thingToJoin.contains("group") &&
            thingToJoin.contains("chat")) {
          // Chat group notification
          String idGroup =
              await getIdGroupWhereCurrentUserIsIn(thingToJoinName);
          _onClickChatGroupNotification(idGroup, thingToJoinName);
        } else if (thingToJoin.contains("event") &&
            thingToJoin.contains("chat")) {
          // Chat event notification
          String idEvent =
              await getIdEventWhereCurrentUserIsIn(thingToJoinName);
          _onClickChatEventNotification(idEvent, thingToJoinName);
        }
      } else {
        debugPrint('The payload is null or empty');
      }
    } catch (e) {
      debugPrint('An error occurred on receiving the notification: $e');
    }
    return;
  }

  Future<void> sendPushMessage(
      {required String token,
      required String title,
      required String body}) async {
    try {
      await _client.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAALqfGamA:APA91bEy4wKHfz1-D1EWGwCYg-CjVthLra1U4-IPMl_o1gfVXzo66zKt7dBPaQm6IB-ZMnZ0jnQGMyda9YRfU6EnhOdKVRWfYNb79ojbORhYRHPkrKRSFzmy3duFeD9g1pXOGUoQkZ0k'
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "HangOut",
            },
            "to": token,
          }));
    } catch (e) {
      debugPrint("An Error occurs in pushing notification: ");
    }
  }

  Future<List<String>> getTokenOfUser(String userId) async {
    final docRef = _db.collection("tokens").doc(userId);

    List<String> tokens = await docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return List.from(data["token"]);
      },
      onError: (e) => debugPrint("Error getting document: $e"),
    );
    return tokens;
  }

  Future<String> getIdGroup(String groupName) async {
    return await _db
        .collection('groups')
        .where("name", isEqualTo: groupName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Group.fromSnapshot(doc).id).first)
        .first;
  }

  Future<String> getIdGroupWhereCurrentUserIsIn(String groupName) async {
    return await _db
        .collection('groups')
        .where("name", isEqualTo: groupName)
        .where("members", arrayContains: _currentUserId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Group.fromSnapshot(doc).id).first)
        .first;
  }

  Future<String> getIdEventWhereCurrentUserIsIn(String eventName) async {
    return await _db
        .collection('events')
        .where("name", isEqualTo: eventName)
        .where("members", arrayContains: _currentUserId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromSnapshot(doc).id).first)
        .first;
  }

  Future<String> getIdEvent(String eventName) async {
    return await _db
        .collection('events')
        .where("name", isEqualTo: eventName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromSnapshot(doc).id).first)
        .first;
  }

// void cancelSingleNotifications({required id}) =>
//     _flutterLocalNotificationsPlugin.cancel(id);
//
// void cancelAllNotifications() => _flutterLocalNotificationsPlugin.cancelAll();
}
