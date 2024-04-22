import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/user/modify_user_cubit.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/data/services/notification_service.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_page.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/home_page.dart';
import 'package:hang_out_app/presentation/pages/home_tablet_page.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/bottom_tablet_nav_bar.dart';
import 'package:hang_out_app/presentation/widgets/bars/bottom_white_nav_bar.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/popups/chat_tablet_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/notifications/notification_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/notifications/notifications_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

import '../../unit/blocs/user/user_bloc_notifications_test.dart';
import '../../unit/data/utils.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockClient extends Mock implements http.Client {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUser extends Mock implements User {}

class MockUserData extends Mock implements UserData {}

class Functions {
  void onClickGroupNotification(String id) {}
  void onClickEventNotification(String id) {}
  void onClickChatGroupNotification(String id, String thingToJoinName) {}
  void onClickChatEventNotification(String id, String thingToJoinName) {}
  void onClickPublicGroupNotification(String id) {}
}

class MockFunctions extends Mock implements Functions {}

void main() {
  group("NotificationsPopup - test", () {
    late FirebaseFirestore firebaseFirestore;
    late FirebaseMessaging firebaseMessaging;
    late NotificationService notificationService;
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    late http.Client mockClient;
    late OurNotification notification1;
    late OurNotification notification2;
    late OurNotification notification3;
    late OurNotification notification4;
    late OurNotification notification5;
    late OurNotification notification6;

    const String currentUserId = "user1Id";
    late FirebaseStorage firebaseStorage;
    late MyEventsRepository myEventsRepository;
    late MyGroupsRepository myGroupsRepository;
    late NotificationsRepository notificationsRepository;
    late ChatRepository chatRepository;
    late UserRepository userRepository;
    late AppBloc appBloc;
    late User user;
    final userMock = MockUserData();

    setUp(() async {
      mockClient = MockClient();
      firebaseFirestore = await RepositoryUtils().getFakeFirestore();
      firebaseMessaging = MockFirebaseMessaging();
      flutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
      when(() => firebaseMessaging.getToken(vapidKey: any(named: 'vapidKey')))
          .thenAnswer((_) async => 'DEVICE_ID');
      when(() => firebaseMessaging.requestPermission()).thenAnswer((_) async =>
          const NotificationSettings(
              alert: AppleNotificationSetting.enabled,
              announcement: AppleNotificationSetting.enabled,
              authorizationStatus: AuthorizationStatus.provisional,
              badge: AppleNotificationSetting.enabled,
              carPlay: AppleNotificationSetting.enabled,
              lockScreen: AppleNotificationSetting.enabled,
              notificationCenter: AppleNotificationSetting.enabled,
              showPreviews: AppleShowPreviewSetting.always,
              timeSensitive: AppleNotificationSetting.enabled,
              criticalAlert: AppleNotificationSetting.enabled,
              sound: AppleNotificationSetting.enabled));
      notificationService = NotificationService(
        firebaseFirestore: firebaseFirestore,
        firebaseMessaging: firebaseMessaging,
        localNotificationsPlugin: flutterLocalNotificationsPlugin,
        client: mockClient,
      );
      notificationService.firstInitialization("userXId");
      notificationService.initializeSettings();
      when(() => flutterLocalNotificationsPlugin.initialize(
              notificationService.initializationSettings,
              onDidReceiveNotificationResponse:
                  any(named: 'onDidReceiveNotificationResponse')))
          .thenAnswer((_) async => true);
      when(() => flutterLocalNotificationsPlugin.show(
              any(), any(), any(), any(), payload: 'body'))
          .thenAnswer((_) async => {});

      firebaseStorage = MockFirebaseStorage();
      myEventsRepository = MyEventsRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);
      myGroupsRepository = MyGroupsRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);
      notificationsRepository =
          NotificationsRepository(firebaseFirestore: firebaseFirestore);
      chatRepository = ChatRepository(firebaseFirestore: firebaseFirestore);
      userRepository = MockUserRepository();
      appBloc = MockAppBloc();
      user = MockUser();

      when(() => user.id).thenReturn(currentUserId);

      when(() => userMock.id).thenReturn(currentUserId);
      when(() => userMock.name).thenReturn("name");
      when(() => userMock.photo).thenReturn("photo");
      when(() => userMock.interests).thenReturn([]);
      when(() => userMock.description).thenReturn("description");

      when(() => userMock.interests).thenReturn([]);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userRepository.getUserDataStream(currentUserId))
          .thenAnswer((_) => Stream.value(userMock));

      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));
      List<String> splitDateHour =
          yesterday.toString().split(".")[0].split(":");
      String dateHour = "${splitDateHour[0]}:${splitDateHour[1]}";

      notification1 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "eventXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: dateHour,
          timestamp: 123,
          chatMessage: "chatMessage",
          eventCategory: "eventCategory",
          public: true);

      splitDateHour = now.toString().split(".")[0].split(":");
      dateHour = "${splitDateHour[0]}:${splitDateHour[1]}";

      notification2 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "eventXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: dateHour,
          timestamp: 123,
          chatMessage: "chatMessage",
          eventCategory: "eventCategory",
          public: true);

      yesterday = now.subtract(const Duration(days: 6));
      splitDateHour = yesterday.toString().split(".")[0].split(":");
      dateHour = "${splitDateHour[0]}:${splitDateHour[1]}";

      notification3 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "eventXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: dateHour,
          timestamp: 123,
          chatMessage: "",
          eventCategory: "eventCategory",
          public: true);

      yesterday = now.subtract(const Duration(days: 700));
      splitDateHour = yesterday.toString().split(".")[0].split(":");
      dateHour = "${splitDateHour[0]}:${splitDateHour[1]}";

      notification4 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "groupXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: dateHour,
          timestamp: 123,
          chatMessage: "",
          eventCategory: "",
          public: true);

      notification5 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "eventXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: "2023-06-15 19:26",
          timestamp: 123,
          chatMessage: "",
          eventCategory: "eventCategory",
          public: false);

      notification6 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "groupXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: "2023-06-15 19:26",
          timestamp: 123,
          chatMessage: "",
          eventCategory: "",
          public: false);
    });

    testWidgets('Notifications popup tap', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(360, 800),
            builder: (context, child) {
              return MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<MyEventsRepository>(
                      create: (context) => myEventsRepository),
                  RepositoryProvider<MyGroupsRepository>(
                      create: (context) => myGroupsRepository),
                  RepositoryProvider<ChatRepository>(
                      create: (context) => chatRepository),
                  RepositoryProvider<NotificationsRepository>(
                      create: (context) => notificationsRepository),
                  RepositoryProvider<UserRepository>(
                      create: (context) => userRepository),
                ],
                child: MultiBlocProvider(providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<UserBloc>.value(
                      value: UserBloc(
                          userRepository: userRepository,
                          notificationService: notificationService)),
                ], child: const MaterialApp(home: HomePage())),
              );
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ExplorePage), findsOneWidget);
        expect(find.byType(BottomWhiteNavBar), findsOneWidget);

        await tester.tap(find.byIcon(AppIcons.bellOutline));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification1);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(ChatView), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.bell));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification2);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(ChatView), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.bell));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification3);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline).last);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification4);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline).last);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification5);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline).last);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification6);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline).last);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);
      });
    });
  });

  group("Notification popup Tablet", () {
    const Size tabletLandscapeSize = Size(1374, 1024);
    late FirebaseFirestore firebaseFirestore;
    late FirebaseMessaging firebaseMessaging;
    late NotificationService notificationService;
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    late http.Client mockClient;
    late OurNotification notification1;
    late OurNotification notification2;
    late OurNotification notification3;
    late OurNotification notification4;
    late OurNotification notification5;
    late OurNotification notification6;

    const String currentUserId = "user1Id";
    late FirebaseStorage firebaseStorage;
    late MyEventsRepository myEventsRepository;
    late MyGroupsRepository myGroupsRepository;
    late NotificationsRepository notificationsRepository;
    late ChatRepository chatRepository;
    late UserRepository userRepository;
    late AppBloc appBloc;
    late User user;
    final userMock = MockUserData();

    setUp(() async {
      mockClient = MockClient();
      firebaseFirestore = await RepositoryUtils().getFakeFirestore();
      firebaseMessaging = MockFirebaseMessaging();
      flutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
      when(() => firebaseMessaging.getToken(vapidKey: any(named: 'vapidKey')))
          .thenAnswer((_) async => 'DEVICE_ID');
      when(() => firebaseMessaging.requestPermission()).thenAnswer((_) async =>
          const NotificationSettings(
              alert: AppleNotificationSetting.enabled,
              announcement: AppleNotificationSetting.enabled,
              authorizationStatus: AuthorizationStatus.provisional,
              badge: AppleNotificationSetting.enabled,
              carPlay: AppleNotificationSetting.enabled,
              lockScreen: AppleNotificationSetting.enabled,
              notificationCenter: AppleNotificationSetting.enabled,
              showPreviews: AppleShowPreviewSetting.always,
              timeSensitive: AppleNotificationSetting.enabled,
              criticalAlert: AppleNotificationSetting.enabled,
              sound: AppleNotificationSetting.enabled));
      notificationService = NotificationService(
        firebaseFirestore: firebaseFirestore,
        firebaseMessaging: firebaseMessaging,
        localNotificationsPlugin: flutterLocalNotificationsPlugin,
        client: mockClient,
      );
      notificationService.firstInitialization("userXId");
      notificationService.initializeSettings();
      when(() => flutterLocalNotificationsPlugin.initialize(
              notificationService.initializationSettings,
              onDidReceiveNotificationResponse:
                  any(named: 'onDidReceiveNotificationResponse')))
          .thenAnswer((_) async => true);
      when(() => flutterLocalNotificationsPlugin.show(
              any(), any(), any(), any(), payload: 'body'))
          .thenAnswer((_) async => {});

      firebaseStorage = MockFirebaseStorage();
      myEventsRepository = MyEventsRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);
      myGroupsRepository = MyGroupsRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);
      notificationsRepository =
          NotificationsRepository(firebaseFirestore: firebaseFirestore);
      chatRepository = ChatRepository(firebaseFirestore: firebaseFirestore);
      userRepository = MockUserRepository();
      appBloc = MockAppBloc();
      user = MockUser();

      when(() => user.id).thenReturn(currentUserId);

      when(() => userMock.id).thenReturn(currentUserId);
      when(() => userMock.name).thenReturn("name");
      when(() => userMock.photo).thenReturn("photo");
      when(() => userMock.interests).thenReturn([]);
      when(() => userMock.description).thenReturn("description");

      when(() => userMock.interests).thenReturn([]);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userRepository.getUserDataStream(currentUserId))
          .thenAnswer((_) => Stream.value(userMock));

      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));
      List<String> splitDateHour =
          yesterday.toString().split(".")[0].split(":");
      String dateHour = "${splitDateHour[0]}:${splitDateHour[1]}";

      notification1 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "eventXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: dateHour,
          timestamp: 123,
          chatMessage: "chatMessage",
          eventCategory: "eventCategory",
          public: true);

      splitDateHour = now.toString().split(".")[0].split(":");
      dateHour = "${splitDateHour[0]}:${splitDateHour[1]}";

      notification2 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "eventXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: dateHour,
          timestamp: 123,
          chatMessage: "chatMessage",
          eventCategory: "eventCategory",
          public: true);

      yesterday = now.subtract(const Duration(days: 6));
      splitDateHour = yesterday.toString().split(".")[0].split(":");
      dateHour = "${splitDateHour[0]}:${splitDateHour[1]}";

      notification3 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "eventXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: dateHour,
          timestamp: 123,
          chatMessage: "",
          eventCategory: "eventCategory",
          public: true);

      yesterday = now.subtract(const Duration(days: 700));
      splitDateHour = yesterday.toString().split(".")[0].split(":");
      dateHour = "${splitDateHour[0]}:${splitDateHour[1]}";

      notification4 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "groupXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: dateHour,
          timestamp: 123,
          chatMessage: "",
          eventCategory: "",
          public: true);

      notification5 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "eventXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: "2023-06-15 19:26",
          timestamp: 123,
          chatMessage: "",
          eventCategory: "eventCategory",
          public: false);

      notification6 = OurNotification(
          notificationId: "",
          userIds: ["user1Id"],
          thingToOpenId: "groupXId",
          thingToNotifyName: "thingToNotifyName",
          sourceName: "sourceName",
          dateHour: "2023-06-15 19:26",
          timestamp: 123,
          chatMessage: "",
          eventCategory: "",
          public: false);
    });

    testWidgets('Notifications popup tap tablet', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: tabletLandscapeSize,
              builder: (context, child) {
                TabletConstants.setDimensions(context);
                PopupTabletConstants.setSmallestDimension(context);
                return MultiRepositoryProvider(
                  providers: [
                    RepositoryProvider<MyEventsRepository>(
                        create: (context) => myEventsRepository),
                    RepositoryProvider<MyGroupsRepository>(
                        create: (context) => myGroupsRepository),
                    RepositoryProvider<ChatRepository>(
                        create: (context) => chatRepository),
                    RepositoryProvider<NotificationsRepository>(
                        create: (context) => notificationsRepository),
                    RepositoryProvider<UserRepository>(
                        create: (context) => userRepository),
                  ],
                  child: MultiBlocProvider(providers: [
                    BlocProvider<AppBloc>.value(value: appBloc),
                    BlocProvider<ModifyUserCubit>.value(
                        value: ModifyUserCubit(
                      userRepository: userRepository,
                    )),
                    BlocProvider<UserBloc>.value(
                        value: UserBloc(
                            userRepository: userRepository,
                            notificationService: notificationService)),
                  ], child: const MaterialApp(home: HomeTabletPage())),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(ExploreTabletPage), findsOneWidget);

        await tester.tap(find.byIcon(AppIcons.bellOutline));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification1);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(ChatTabletPopup), findsOneWidget);
        await tester.tap(find.byType(BottomTabletNavBar), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification2);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(ChatTabletPopup), findsOneWidget);
        await tester.tap(find.byType(BottomTabletNavBar), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification3);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        await tester.tap(find.byType(BottomTabletNavBar), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification4);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
        await tester.tap(find.byType(BottomTabletNavBar), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification5);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        await tester.tap(find.byType(BottomTabletNavBar), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);

        await notificationsRepository.addNewNotification(
            notification: notification6);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Dismissible).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
        await tester.tap(find.byType(BottomTabletNavBar), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.drag(
            find.byType(Dismissible).first, const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationRow), findsNothing);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
