import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/profile/profile_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/user_info/user_info.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../utils.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockUser extends Mock implements User {}

void main() {
  group("user info phone", () {
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
    });
    testWidgets('users have one common group', (WidgetTester tester) async {
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
                      BlocProvider<ProfileBloc>.value(
                          value:
                              ProfileBloc(groupsRepository: myGroupsRepository)
                                ..add(const LoadGroupsInCommon(
                                    firstId: currentUserId,
                                    secondId: "user3Id"))),
                    ],
                    child: MaterialApp(
                        home: UserInfo(
                            heroTag: "tag",
                            user: OtherUser(
                              id: "user3Id",
                              name: WidgetHomeUtils.user3["name"] as String,
                              photo: WidgetHomeUtils.user3["photo"] as String,
                              interests: WidgetHomeUtils.user3["interests"]
                                  as List<String>,
                              description: WidgetHomeUtils.user3["description"]
                                  as String,
                            )))),
              );
            },
          ),
        );
        expect(find.byType(UserInfo), findsOneWidget);
        expect(
            find.text(WidgetHomeUtils.user3["name"] as String), findsOneWidget);
        expect(find.text(WidgetHomeUtils.user3["description"] as String),
            findsOneWidget);
        expect(find.text("My interests:"), findsOneWidget);
        expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text("Groups in common:"), findsOneWidget);
        // expect(find.byType(BottomWhiteNavBar), findsOneWidget);
      });
    });
    testWidgets('users have no common groups', (WidgetTester tester) async {
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
                      BlocProvider<ProfileBloc>.value(
                          value:
                              ProfileBloc(groupsRepository: myGroupsRepository)
                                ..add(const LoadGroupsInCommon(
                                    firstId: currentUserId,
                                    secondId: "user2Id"))),
                    ],
                    child: MaterialApp(
                        home: UserInfo(
                            heroTag: "tag",
                            user: OtherUser(
                              id: "user2Id",
                              name: WidgetHomeUtils.user2["name"] as String,
                              photo: WidgetHomeUtils.user2["photo"] as String,
                              interests: WidgetHomeUtils.user2["interests"]
                                  as List<String>,
                              description: WidgetHomeUtils.user2["description"]
                                  as String,
                            )))),
              );
            },
          ),
        );
        expect(find.byType(UserInfo), findsOneWidget);
        expect(
            find.text(WidgetHomeUtils.user2["name"] as String), findsOneWidget);
        expect(find.text(WidgetHomeUtils.user2["description"] as String),
            findsOneWidget);
        expect(find.text("My interests:"), findsOneWidget);
        expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text("Groups in common:"), findsNothing);
        // expect(find.byType(BottomWhiteNavBar), findsOneWidget);
      });
    });
    testWidgets('test user has photo', (WidgetTester tester) async {
      await tester.runAsync(() async {
        ImageManager.isTest = true;
        await mockNetworkImagesFor(() async => await tester.pumpWidget(
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
                          BlocProvider<ProfileBloc>.value(
                              value: ProfileBloc(
                                  groupsRepository: myGroupsRepository)
                                ..add(const LoadGroupsInCommon(
                                    firstId: currentUserId,
                                    secondId: "user2Id"))),
                        ],
                        child: MaterialApp(
                            home: UserInfo(
                                heroTag: "tag",
                                user: OtherUser(
                                  id: "user2Id",
                                  name: WidgetHomeUtils.user2["name"] as String,
                                  photo: "test_resources/example.jpg",
                                  interests: WidgetHomeUtils.user2["interests"]
                                      as List<String>,
                                  description: WidgetHomeUtils
                                      .user2["description"] as String,
                                )))),
                  );
                },
              ),
            ));
        expect(find.byType(UserInfo), findsOneWidget);
        expect(
            find.text(WidgetHomeUtils.user2["name"] as String), findsOneWidget);
        expect(find.text(WidgetHomeUtils.user2["description"] as String),
            findsOneWidget);
        expect(find.text("My interests:"), findsOneWidget);
        expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text("Groups in common:"), findsNothing);
        // expect(find.byType(BottomWhiteNavBar), findsOneWidget);
      });
    });
  });
  group("user info tablet", () {
    const Size tabletLandscapeSize = Size(1374, 1024);
    // const Size tabletPortraitSize = Size(1024, 1374);
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
    });
    testWidgets('users have one common group', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
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
                        BlocProvider<ProfileBloc>.value(
                            value: ProfileBloc(
                                groupsRepository: myGroupsRepository)
                              ..add(const LoadGroupsInCommon(
                                  firstId: currentUserId,
                                  secondId: "user3Id"))),
                      ],
                      child: MaterialApp(
                          home: UserInfo(
                              heroTag: "tag",
                              user: OtherUser(
                                id: "user3Id",
                                name: WidgetHomeUtils.user3["name"] as String,
                                photo: WidgetHomeUtils.user3["photo"] as String,
                                interests: WidgetHomeUtils.user3["interests"]
                                    as List<String>,
                                description: WidgetHomeUtils
                                    .user3["description"] as String,
                              )))),
                );
              },
            ),
          ),
        );
        expect(find.byType(UserInfo), findsOneWidget);
        expect(
            find.text(WidgetHomeUtils.user3["name"] as String), findsOneWidget);
        expect(find.text(WidgetHomeUtils.user3["description"] as String),
            findsOneWidget);
        expect(find.text("My interests:"), findsOneWidget);
        expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.text("Groups in common:"), findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('users have no common groups', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
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
                        BlocProvider<ProfileBloc>.value(
                            value: ProfileBloc(
                                groupsRepository: myGroupsRepository)
                              ..add(const LoadGroupsInCommon(
                                  firstId: currentUserId,
                                  secondId: "user2Id"))),
                      ],
                      child: MaterialApp(
                          home: UserInfo(
                              heroTag: "tag",
                              user: OtherUser(
                                id: "user2Id",
                                name: WidgetHomeUtils.user2["name"] as String,
                                photo: WidgetHomeUtils.user2["photo"] as String,
                                interests: WidgetHomeUtils.user2["interests"]
                                    as List<String>,
                                description: WidgetHomeUtils
                                    .user2["description"] as String,
                              )))),
                );
              },
            ),
          ),
        );
        expect(find.byType(UserInfo), findsOneWidget);
        expect(
            find.text(WidgetHomeUtils.user2["name"] as String), findsOneWidget);
        expect(find.text(WidgetHomeUtils.user2["description"] as String),
            findsOneWidget);
        expect(find.text("My interests:"), findsOneWidget);
        expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.text("Groups in common:"), findsNothing);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
    testWidgets('test user has photo', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      await tester.runAsync(() async {
        ImageManager.isTest = true;
        await mockNetworkImagesFor(() async => await tester.pumpWidget(
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
                            BlocProvider<ProfileBloc>.value(
                                value: ProfileBloc(
                                    groupsRepository: myGroupsRepository)
                                  ..add(const LoadGroupsInCommon(
                                      firstId: currentUserId,
                                      secondId: "user2Id"))),
                          ],
                          child: MaterialApp(
                              home: UserInfo(
                                  heroTag: "tag",
                                  user: OtherUser(
                                    id: "user2Id",
                                    name:
                                        WidgetHomeUtils.user2["name"] as String,
                                    photo: "test_resources/example.jpg",
                                    interests: WidgetHomeUtils
                                        .user2["interests"] as List<String>,
                                    description: WidgetHomeUtils
                                        .user2["description"] as String,
                                  )))),
                    );
                  },
                ),
              ),
            ));
        expect(find.byType(UserInfo), findsOneWidget);

        expect(find.byType(CircleAvatar), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });
}
