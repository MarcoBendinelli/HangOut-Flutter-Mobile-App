import 'dart:convert';

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
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/bottom_tablet_nav_bar.dart';
import 'package:hang_out_app/presentation/widgets/bars/bottom_white_nav_bar.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/popups/chat_tablet_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import '../../blocs/user/user_bloc_notifications_test.dart';
import '../utils.dart';

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
  group("NotificationService - functions", () {
    late FirebaseFirestore firebaseFirestore;
    late FirebaseMessaging firebaseMessaging;
    late NotificationService notificationService;
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    late http.Client mockClient;

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
      // UserLoaded
    });

    testWidgets('test public group notification function',
        (WidgetTester tester) async {
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

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationPublicGroup}groupX",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
      });
    });

    testWidgets('test add group notification function',
        (WidgetTester tester) async {
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

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationGroup}groupX",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
      });
    });

    testWidgets('test join event notification function',
        (WidgetTester tester) async {
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

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationEvent}event1",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
      });
    });

    testWidgets('test group chat notification function',
        (WidgetTester tester) async {
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

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationChatGroup}groupX",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(ChatView), findsOneWidget);
      });
    });

    testWidgets('test event chat notification function',
        (WidgetTester tester) async {
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

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationChatEvent}eventX",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(ChatView), findsOneWidget);
      });
    });
  });

  group("Notification functions Tests Tablet", () {
    const Size tabletLandscapeSize = Size(1374, 1024);
    late FirebaseFirestore firebaseFirestore;
    late FirebaseMessaging firebaseMessaging;
    late NotificationService notificationService;
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    late http.Client mockClient;

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
      // UserLoaded
    });

    testWidgets('tablet public group notification function',
        (WidgetTester tester) async {
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
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationPublicGroup}groupX",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('tablet add group notification function',
        (WidgetTester tester) async {
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
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationGroup}groupX",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('tablet join event notification function',
        (WidgetTester tester) async {
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
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationEvent}event1",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('tablet group chat notification function',
        (WidgetTester tester) async {
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
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationChatGroup}groupX",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(ChatTabletPopup), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('tablet event chat notification function',
        (WidgetTester tester) async {
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
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        NotificationResponse notification = const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 0,
          actionId: "actionId",
          input: "input",
          payload: "${Constants.bodyNotificationChatEvent}eventX",
        );

        await notificationService
            .onDidReceiveNotificationResponse(notification);
        await tester.pumpAndSettle();
        expect(find.byType(ChatTabletPopup), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });

  group("NotificationService", () {
    late FirebaseFirestore firebaseFirestore;
    late FirebaseMessaging firebaseMessaging;
    late NotificationService notificationService;
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    late http.Client mockClient;
    late Functions functions;

    setUp(() async {
      mockClient = MockClient();
      functions = MockFunctions();
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
      // Two initializations don't break
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
      await notificationService.setNotificationsBehaviour(
        onClickGroupNotification: functions.onClickGroupNotification,
        onClickEventNotification: functions.onClickEventNotification,
        onClickChatGroupNotification: functions.onClickChatGroupNotification,
        onClickChatEventNotification: functions.onClickChatEventNotification,
        onClickPublicGroupNotification:
            functions.onClickPublicGroupNotification,
      );
    });

    test("getAndSaveToken", () async {
      await notificationService.getAndSaveToken();
      expect(await notificationService.getTokenOfUser('userXId'), ['DEVICE_ID']);
    });

    test("setNotificationsBehaviour", () async {
      // The late properties are initialized 2 times (with try catch)
      await notificationService.setNotificationsBehaviour(
        onClickGroupNotification: (String id) {},
        onClickEventNotification: (String id) {},
        onClickChatGroupNotification: (String id) {},
        onClickChatEventNotification: (String id) {},
        onClickPublicGroupNotification: (String id) {},
      );
      // The late errors are correctly catched
      verify(() => flutterLocalNotificationsPlugin.initialize(
          notificationService.initializationSettings,
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'))).called(2);
    });

    test('verify firebaseOnListen', () async {
      await notificationService.firebaseOnListen(title: 'title', body: 'body');
      verify(() => flutterLocalNotificationsPlugin
          .show(any(), any(), any(), any(), payload: 'body')).called(1);
    });

    test('should send push message with the correct parameters', () async {
      // Arrange
      const token = 'TOKEN';
      const title = 'Test Title';
      const body = 'Test Body';

      final expectedRequestBody = jsonEncode(<String, dynamic>{
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
      });

      final response = http.Response('', 200); // Mock the response

      when(() => mockClient.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAALqfGamA:APA91bEy4wKHfz1-D1EWGwCYg-CjVthLra1U4-IPMl_o1gfVXzo66zKt7dBPaQm6IB-ZMnZ0jnQGMyda9YRfU6EnhOdKVRWfYNb79ojbORhYRHPkrKRSFzmy3duFeD9g1pXOGUoQkZ0k'
            },
            body: expectedRequestBody,
          )).thenAnswer((_) async => response);

      // Act
      await notificationService.sendPushMessage(
          token: token, title: title, body: body);

      // Assert
      verify(() => mockClient.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAALqfGamA:APA91bEy4wKHfz1-D1EWGwCYg-CjVthLra1U4-IPMl_o1gfVXzo66zKt7dBPaQm6IB-ZMnZ0jnQGMyda9YRfU6EnhOdKVRWfYNb79ojbORhYRHPkrKRSFzmy3duFeD9g1pXOGUoQkZ0k'
            },
            body: expectedRequestBody,
          )).called(1);
    });

    test('should get error', () async {
      // Arrange
      const token = 'TOKEN';
      const title = 'Test Title';
      const body = 'Test Body';

      final expectedRequestBody = jsonEncode(<String, dynamic>{
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
      });

      when(() => mockClient.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAALqfGamA:APA91bEy4wKHfz1-D1EWGwCYg-CjVthLra1U4-IPMl_o1gfVXzo66zKt7dBPaQm6IB-ZMnZ0jnQGMyda9YRfU6EnhOdKVRWfYNb79ojbORhYRHPkrKRSFzmy3duFeD9g1pXOGUoQkZ0k'
            },
            body: expectedRequestBody,
          )).thenThrow((_) async => Exception);

      // Act
      await notificationService.sendPushMessage(
          token: token, title: title, body: body);

      // Assert
      verify(() => mockClient.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAALqfGamA:APA91bEy4wKHfz1-D1EWGwCYg-CjVthLra1U4-IPMl_o1gfVXzo66zKt7dBPaQm6IB-ZMnZ0jnQGMyda9YRfU6EnhOdKVRWfYNb79ojbORhYRHPkrKRSFzmy3duFeD9g1pXOGUoQkZ0k'
            },
            body: expectedRequestBody,
          )).called(1);
    });

    test('verify onDidReceiveNotificationResponse exception', () async {
      NotificationService newNotificationService = NotificationService(
        firebaseFirestore: firebaseFirestore,
        firebaseMessaging: firebaseMessaging,
        localNotificationsPlugin: flutterLocalNotificationsPlugin,
        client: mockClient,
      );
      newNotificationService.firstInitialization("userXId");
      newNotificationService.initializeSettings();
      NotificationResponse notification = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 0,
        actionId: "actionId",
        input: "input",
        payload: "${Constants.bodyNotificationGroup}groupX",
      );

      await newNotificationService.setNotificationsBehaviour(
        onClickGroupNotification: (String id) {
          throw Exception();
        },
        onClickEventNotification: functions.onClickEventNotification,
        onClickChatGroupNotification: functions.onClickChatGroupNotification,
        onClickChatEventNotification: functions.onClickChatEventNotification,
        onClickPublicGroupNotification:
            functions.onClickPublicGroupNotification,
      );

      await newNotificationService
          .onDidReceiveNotificationResponse(notification);
    });

    test('verify onDidReceiveNotificationResponse empty payload', () async {
      NotificationResponse notification = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 0,
        actionId: "actionId",
        input: "input",
        payload: "",
      );

      await notificationService.onDidReceiveNotificationResponse(notification);
      verifyNever(() => functions.onClickGroupNotification(any()));
      verifyNever(() => functions.onClickEventNotification(any()));
      verifyNever(() => functions.onClickChatGroupNotification(any(), any()));
      verifyNever(() => functions.onClickChatEventNotification(any(), any()));
      verifyNever(() => functions.onClickPublicGroupNotification(any()));
    });

    test('verify onDidReceiveNotificationResponse group', () async {
      NotificationResponse notification = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 0,
        actionId: "actionId",
        input: "input",
        payload: "${Constants.bodyNotificationGroup}groupX",
      );

      await notificationService.onDidReceiveNotificationResponse(notification);
      expect(await notificationService.getIdGroupWhereCurrentUserIsIn('groupX'),
          'groupXId');
      verify(() => functions.onClickGroupNotification(any())).called(1);
    });

    test('verify onDidReceiveNotificationResponse event', () async {
      NotificationResponse notification = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 0,
        actionId: "actionId",
        input: "input",
        payload: "${Constants.bodyNotificationEvent}event1",
      );

      await notificationService.onDidReceiveNotificationResponse(notification);
      expect(await notificationService.getIdEvent('event1'), 'event1Id');
      verify(() => functions.onClickEventNotification(any())).called(1);
    });

    test('verify onDidReceiveNotificationResponse group chat', () async {
      NotificationResponse notification = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 0,
        actionId: "actionId",
        input: "input",
        payload: "${Constants.bodyNotificationChatGroup}groupX",
      );

      await notificationService.onDidReceiveNotificationResponse(notification);
      expect(await notificationService.getIdGroupWhereCurrentUserIsIn('groupX'),
          'groupXId');
      verify(() => functions.onClickChatGroupNotification(any(), any()))
          .called(1);
    });

    test('verify onDidReceiveNotificationResponse event chat', () async {
      NotificationResponse notification = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 0,
        actionId: "actionId",
        input: "input",
        payload: "${Constants.bodyNotificationChatEvent}eventX",
      );

      await notificationService.onDidReceiveNotificationResponse(notification);
      expect(await notificationService.getIdEventWhereCurrentUserIsIn('eventX'),
          'eventXId');
      verify(() => functions.onClickChatEventNotification(any(), any()))
          .called(1);
    });

    test('verify onDidReceiveNotificationResponse public group', () async {
      NotificationResponse notification = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 0,
        actionId: "actionId",
        input: "input",
        payload: "${Constants.bodyNotificationPublicGroup}groupX",
      );

      await notificationService.onDidReceiveNotificationResponse(notification);
      expect(await notificationService.getIdGroup('groupX'), 'groupXId');
      verify(() => functions.onClickPublicGroupNotification(any())).called(1);
    });

    test('verify onDidReceiveNotificationResponse public event', () async {
      NotificationResponse notification = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 0,
        actionId: "actionId",
        input: "input",
        payload: "${Constants.bodyNotificationPublicEvent}eventX",
      );

      await notificationService.onDidReceiveNotificationResponse(notification);
      expect(await notificationService.getIdEvent('eventX'), 'eventXId');
      verify(() => functions.onClickEventNotification(any())).called(1);
    });
  });

  group("NotificationService - different permission: authorized", () {
    late FirebaseFirestore firebaseFirestore;
    late FirebaseMessaging firebaseMessaging;
    late NotificationService notificationService;
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

    setUpAll(() async {
      firebaseFirestore = await RepositoryUtils().getFakeFirestore();
      firebaseMessaging = MockFirebaseMessaging();
      flutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
      when(() => firebaseMessaging.requestPermission()).thenAnswer((_) async =>
          const NotificationSettings(
              alert: AppleNotificationSetting.enabled,
              announcement: AppleNotificationSetting.enabled,
              authorizationStatus: AuthorizationStatus.authorized,
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
      );
    });

    setUp(() => when(() => firebaseMessaging.requestPermission()).thenAnswer(
        (_) async => const NotificationSettings(
            alert: AppleNotificationSetting.enabled,
            announcement: AppleNotificationSetting.enabled,
            authorizationStatus: AuthorizationStatus.authorized,
            badge: AppleNotificationSetting.enabled,
            carPlay: AppleNotificationSetting.enabled,
            lockScreen: AppleNotificationSetting.enabled,
            notificationCenter: AppleNotificationSetting.enabled,
            showPreviews: AppleShowPreviewSetting.always,
            timeSensitive: AppleNotificationSetting.enabled,
            criticalAlert: AppleNotificationSetting.enabled,
            sound: AppleNotificationSetting.enabled)));
    test("Authorized", () async {
      await notificationService.requestFirebaseMessagingPermission();
      verify(() => firebaseMessaging.requestPermission()).called(1);
    });
  });

  group("NotificationService - different permission: denied", () {
    late FirebaseFirestore firebaseFirestore;
    late FirebaseMessaging firebaseMessaging;
    late NotificationService notificationService;
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

    setUpAll(() async {
      firebaseFirestore = await RepositoryUtils().getFakeFirestore();
      firebaseMessaging = MockFirebaseMessaging();
      flutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
      when(() => firebaseMessaging.requestPermission()).thenAnswer((_) async =>
          const NotificationSettings(
              alert: AppleNotificationSetting.enabled,
              announcement: AppleNotificationSetting.enabled,
              authorizationStatus: AuthorizationStatus.authorized,
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
      );
    });

    setUp(() => when(() => firebaseMessaging.requestPermission()).thenAnswer(
        (_) async => const NotificationSettings(
            alert: AppleNotificationSetting.enabled,
            announcement: AppleNotificationSetting.enabled,
            authorizationStatus: AuthorizationStatus.denied,
            badge: AppleNotificationSetting.enabled,
            carPlay: AppleNotificationSetting.enabled,
            lockScreen: AppleNotificationSetting.enabled,
            notificationCenter: AppleNotificationSetting.enabled,
            showPreviews: AppleShowPreviewSetting.always,
            timeSensitive: AppleNotificationSetting.enabled,
            criticalAlert: AppleNotificationSetting.enabled,
            sound: AppleNotificationSetting.enabled)));
    test("Denied", () async {
      await notificationService.requestFirebaseMessagingPermission();
      verify(() => firebaseMessaging.requestPermission()).called(1);
    });
  });
}
