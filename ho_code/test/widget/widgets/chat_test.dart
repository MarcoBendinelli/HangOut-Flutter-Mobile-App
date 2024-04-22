import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/popups/chat_tablet_popup.dart';
import 'package:mocktail/mocktail.dart';
import '../utils.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockUser extends Mock implements User {}

const String newText = "new message from tester";
dynamic eventTimeStamp;
TextMessage getMessage(String senderId, String name) {
  eventTimeStamp++;
  return TextMessage(
    text: newText,
    timeStamp: eventTimeStamp,
    dateHour: "2022-05-11 16:41",
    senderId: senderId,
    senderNickname: name,
    senderPhoto: "",
  );
}

void main() {
  group("chat phone tests", () {
    const String currentUserId = "user1Id";
    late FirebaseFirestore firebaseFirestore;
    late FirebaseStorage firebaseStorage;
    late MyEventsRepository myEventsRepository;
    late MyGroupsRepository myGroupsRepository;
    late NotificationsRepository notificationsRepository;
    late ChatRepository chatRepository;
    late UserRepository userRepository;
    late AppBloc appBloc;
    late UserBloc userBloc;
    late User user;
    late UserData currentUserData;
    setUp(() async {
      firebaseFirestore = await WidgetHomeUtils.getFakeFirestore();
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
      userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);
      appBloc = MockAppBloc();
      userBloc = MockUserBloc();
      user = MockUser();
      currentUserData = WidgetHomeUtils.currentUserData;
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userBloc.state).thenReturn(UserLoaded(user: currentUserData));
      eventTimeStamp = 1683816106606;
    });
    testWidgets('write new message in event', (WidgetTester tester) async {
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
                child: MultiBlocProvider(
                    providers: [
                      BlocProvider<AppBloc>.value(value: appBloc),
                      BlocProvider<UserBloc>.value(value: userBloc),
                    ],
                    child: MaterialApp(
                        home: ChatView(
                      id: WidgetHomeUtils.event1["id"] as String,
                      isForTheGroup: false,
                      chatName: WidgetHomeUtils.event1["name"] as String,
                    ))),
              );
            },
          ),
        );

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ChatView), findsOneWidget);
        expect(find.text(WidgetHomeUtils.messageEvent1["text"] as String),
            findsOneWidget);
        expect(find.text(WidgetHomeUtils.secondMessageEvent1["text"] as String),
            findsOneWidget);
        await tester.enterText(find.byType(TextField), newText);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
        await tester.pumpAndSettle();
        expect(find.text(newText), findsOneWidget);
      });
    });
    testWidgets('write new message in group', (WidgetTester tester) async {
      const String newText = "new message from tester";
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
                child: MultiBlocProvider(
                    providers: [
                      BlocProvider<AppBloc>.value(value: appBloc),
                      BlocProvider<UserBloc>.value(value: userBloc),
                    ],
                    child: MaterialApp(
                        home: ChatView(
                      id: WidgetHomeUtils.group1["id"] as String,
                      isForTheGroup: true,
                      chatName: WidgetHomeUtils.group1["name"] as String,
                    ))),
              );
            },
          ),
        );

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ChatView), findsOneWidget);
        await tester.enterText(find.byType(TextField), newText);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
        await tester.pumpAndSettle();
        expect(find.text(newText), findsOneWidget);
      });
    });
    testWidgets('2 messages with same sender', (WidgetTester tester) async {
      const String newText = "new message from tester";
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
                child: MultiBlocProvider(
                    providers: [
                      BlocProvider<AppBloc>.value(value: appBloc),
                      BlocProvider<UserBloc>.value(value: userBloc),
                    ],
                    child: MaterialApp(
                        home: ChatView(
                      id: WidgetHomeUtils.event2["id"] as String,
                      isForTheGroup: false,
                      chatName: WidgetHomeUtils.event2["name"] as String,
                    ))),
              );
            },
          ),
        );

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ChatView), findsOneWidget);
        // await tester.enterText(find.byType(TextField), newText);
        // await tester.pumpAndSettle();
        // await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
        // await tester.pumpAndSettle();
        // expect(find.text(newText), findsOneWidget);
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user2Id", "user2"), eventId: "event2Id");
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user2Id", "user2"), eventId: "event2Id");
        // await chatRepository.sendTextMessageInTheEvent(
        //     message: getMessage("user1Id"), eventId: "event2Id");

        // await tester.enterText(find.byType(TextField), "newText2");
        await tester.pumpAndSettle();
        // await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
        // await tester.pumpAndSettle();
        expect(find.text(newText), findsNWidgets(2));
      });
    });
    testWidgets('1 messages with user1 -> 2 with user 2 -> 1 with user1',
        (WidgetTester tester) async {
      const String newText = "new message from tester";
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
                child: MultiBlocProvider(
                    providers: [
                      BlocProvider<AppBloc>.value(value: appBloc),
                      BlocProvider<UserBloc>.value(value: userBloc),
                    ],
                    child: MaterialApp(
                        home: ChatView(
                      id: WidgetHomeUtils.event2["id"] as String,
                      isForTheGroup: false,
                      chatName: WidgetHomeUtils.event2["name"] as String,
                    ))),
              );
            },
          ),
        );

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ChatView), findsOneWidget);

        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user1Id", "user1"), eventId: "event2Id");
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user2Id", "user2"), eventId: "event2Id");
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user2Id", "user2"), eventId: "event2Id");
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user1Id", "user1"), eventId: "event2Id");

        await tester.pumpAndSettle();

        expect(find.text(newText), findsNWidgets(4));
      });
    });
  });
  group("chat tablet tests", () {
    const String currentUserId = "user1Id";
    const Size tabletLandscapeSize = Size(1374, 1024);
    late FirebaseFirestore firebaseFirestore;
    late FirebaseStorage firebaseStorage;
    late MyEventsRepository myEventsRepository;
    late MyGroupsRepository myGroupsRepository;
    late NotificationsRepository notificationsRepository;
    late ChatRepository chatRepository;
    late UserRepository userRepository;
    late AppBloc appBloc;
    late UserBloc userBloc;
    late User user;
    late UserData currentUserData;
    setUp(() async {
      firebaseFirestore = await WidgetHomeUtils.getFakeFirestore();
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
      userRepository = UserRepository(
          firebaseFirestore: firebaseFirestore,
          firebaseStorage: firebaseStorage);
      appBloc = MockAppBloc();
      userBloc = MockUserBloc();
      user = MockUser();
      currentUserData = WidgetHomeUtils.currentUserData;
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userBloc.state).thenReturn(UserLoaded(user: currentUserData));
      eventTimeStamp = 1683816106606;
    });
    testWidgets('write new message in event', (WidgetTester tester) async {
      await tester.runAsync(() async {
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
                  child: MultiBlocProvider(
                      providers: [
                        BlocProvider<AppBloc>.value(value: appBloc),
                        BlocProvider<UserBloc>.value(value: userBloc),
                      ],
                      child: MaterialApp(
                          home: ChatTabletPopup(
                        heroTag: "tag",
                        id: WidgetHomeUtils.event1["id"] as String,
                        isForTheGroup: false,
                        chatName: WidgetHomeUtils.event1["name"] as String,
                      ))),
                );
              },
            ),
          ),
        );

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ChatTabletPopup), findsOneWidget);
        expect(find.text(WidgetHomeUtils.messageEvent1["text"] as String),
            findsOneWidget);
        expect(find.text(WidgetHomeUtils.secondMessageEvent1["text"] as String),
            findsOneWidget);
        await tester.enterText(find.byType(TextField), newText);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
        await tester.pumpAndSettle();
        expect(find.text(newText), findsOneWidget);
      });
    });
    testWidgets('write new message in group', (WidgetTester tester) async {
      const String newText = "new message from tester";
      await tester.runAsync(() async {
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
                  child: MultiBlocProvider(
                      providers: [
                        BlocProvider<AppBloc>.value(value: appBloc),
                        BlocProvider<UserBloc>.value(value: userBloc),
                      ],
                      child: MaterialApp(
                          home: ChatTabletPopup(
                        heroTag: "tag",
                        id: WidgetHomeUtils.group1["id"] as String,
                        isForTheGroup: true,
                        chatName: WidgetHomeUtils.group1["name"] as String,
                      ))),
                );
              },
            ),
          ),
        );

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ChatTabletPopup), findsOneWidget);
        await tester.enterText(find.byType(TextField), newText);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
        await tester.pumpAndSettle();
        expect(find.text(newText), findsOneWidget);
      });
    });
    testWidgets('2 messages with same sender', (WidgetTester tester) async {
      const String newText = "new message from tester";
      await tester.runAsync(() async {
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
                  child: MultiBlocProvider(
                      providers: [
                        BlocProvider<AppBloc>.value(value: appBloc),
                        BlocProvider<UserBloc>.value(value: userBloc),
                      ],
                      child: MaterialApp(
                          home: ChatTabletPopup(
                        heroTag: "tag",
                        id: WidgetHomeUtils.event2["id"] as String,
                        isForTheGroup: false,
                        chatName: WidgetHomeUtils.event2["name"] as String,
                      ))),
                );
              },
            ),
          ),
        );

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ChatTabletPopup), findsOneWidget);
        // await tester.enterText(find.byType(TextField), newText);
        // await tester.pumpAndSettle();
        // await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
        // await tester.pumpAndSettle();
        // expect(find.text(newText), findsOneWidget);
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user2Id", "user2"), eventId: "event2Id");
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user2Id", "user2"), eventId: "event2Id");
        // await chatRepository.sendTextMessageInTheEvent(
        //     message: getMessage("user1Id"), eventId: "event2Id");

        // await tester.enterText(find.byType(TextField), "newText2");
        await tester.pumpAndSettle();
        // await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
        // await tester.pumpAndSettle();
        expect(find.text(newText), findsNWidgets(2));
      });
    });
    testWidgets('1 messages with user1 -> 2 with user 2 -> 1 with user1',
        (WidgetTester tester) async {
      const String newText = "new message from tester";
      await tester.runAsync(() async {
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
                  child: MultiBlocProvider(
                      providers: [
                        BlocProvider<AppBloc>.value(value: appBloc),
                        BlocProvider<UserBloc>.value(value: userBloc),
                      ],
                      child: MaterialApp(
                          home: ChatTabletPopup(
                        heroTag: "tag",
                        id: WidgetHomeUtils.event2["id"] as String,
                        isForTheGroup: false,
                        chatName: WidgetHomeUtils.event2["name"] as String,
                      ))),
                );
              },
            ),
          ),
        );

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ChatTabletPopup), findsOneWidget);

        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user1Id", "user1"), eventId: "event2Id");
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user2Id", "user2"), eventId: "event2Id");
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user2Id", "user2"), eventId: "event2Id");
        await chatRepository.sendTextMessageInTheEvent(
            message: getMessage("user1Id", "user1"), eventId: "event2Id");

        await tester.pumpAndSettle();

        expect(find.text(newText), findsNWidgets(4));
      });
    });
  });
}
