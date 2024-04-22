import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/theme/theme_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/user/modify_user_cubit.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/pages/home_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/profile/notifications_user_col.dart';
import 'package:hang_out_app/presentation/pages/profile/profile_page.dart';
import 'package:hang_out_app/presentation/pages/profile/theme_selector_row.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_photo_row.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockThemeBloc extends MockBloc<ThemeEvent, bool> implements ThemeBloc {}

class MockUser extends Mock implements User {}

void main() {
  group("Profile page test", () {
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
    late ThemeBloc themeBloc;
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
      themeBloc = MockThemeBloc();
      user = MockUser();
      currentUserData = WidgetHomeUtils.currentUserData;
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => appBloc.add(const DeleteRequested()))
          .thenAnswer((_) async => {});
      when(() => appBloc.add(const AppLogoutRequested()))
          .thenAnswer((_) async => {});
      when(() => userBloc.state).thenReturn(UserLoaded(user: currentUserData));
      when(() => themeBloc.state).thenReturn(true);
      when(() => themeBloc.add(const ThemeChanged(isThemeDark: true)))
          .thenAnswer((_) async => {});
      when(() => userBloc.getInterestedUsersToNotify(
              newGroupEventInterests: any(named: "newGroupEventInterests")))
          .thenAnswer((_) async => []);
    });

    testWidgets('First profile test', (WidgetTester tester) async {
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
                      BlocProvider<ThemeBloc>.value(value: themeBloc),
                      BlocProvider<ModifyUserCubit>.value(
                          value: ModifyUserCubit(
                        userRepository: userRepository,
                      )),
                    ],
                    child: const MaterialApp(
                        home: Material(child: ProfilePage()))),
              );
            },
          ),
        );

        expect(find.byType(TextPhotoRow), findsOneWidget);
        expect(find.byType(NotificationsUserCol), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.text("save");
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        expect(find.byKey(const Key("disabledSave")), findsNothing);
        expect(find.byKey(const Key("activeSave")), findsOneWidget);

        await tester.tap(find.byKey(const Key("activeSave")));

        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, "mynewName");
        await tester.enterText(
            find.byKey(const Key("Input_Row_Text_Field")).first, "");
        await tester.enterText(
            find.byKey(const Key("Input_Row_Text_Field")).last, "");

        await tester.pumpAndSettle();

        expect(find.byKey(const Key("disabledSave")), findsOneWidget);
        expect(find.byKey(const Key("activeSave")), findsNothing);

        await tester.enterText(
            find.byKey(const Key("Input_Row_Text_Field")).first, "Bio");

        await tester.pumpAndSettle();

        expect(find.byKey(const Key("disabledSave")), findsNothing);
        expect(find.byKey(const Key("activeSave")), findsOneWidget);

        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(0));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(1));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(2));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(3));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(4));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(5));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(6));

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byKey(const Key("theme_selector_button")));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(AppIcons.trashOutline));
        await tester.pumpAndSettle();
        expect(find.text("Continue"), findsOneWidget);

        await tester.tap(find.text("Cancel"));
        await tester.pumpAndSettle();

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byIcon(AppIcons.trashOutline));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Continue"));
        await tester.pumpAndSettle();

        verify(() => appBloc.add(const DeleteRequested())).called(1);
      });
    });

    testWidgets('Logout profile test', (WidgetTester tester) async {
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
                      BlocProvider<ThemeBloc>.value(value: themeBloc),
                      BlocProvider<ModifyUserCubit>.value(
                          value: ModifyUserCubit(
                        userRepository: userRepository,
                      )),
                    ],
                    child: const MaterialApp(
                        home: Material(child: ProfilePage()))),
              );
            },
          ),
        );

        expect(find.byType(TextPhotoRow), findsOneWidget);
        expect(find.byType(NotificationsUserCol), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.text("save");

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        await tester.tap(find.byIcon(AppIcons.logOutOutline));
        await tester.pumpAndSettle();

        verify(() => appBloc.add(const AppLogoutRequested())).called(1);
      });
    });
  });

  group("Theme selctor profile", () {
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
    late ThemeBloc themeBloc;
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
      themeBloc = MockThemeBloc();
      user = MockUser();
      currentUserData = WidgetHomeUtils.currentUserData;
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => appBloc.add(const DeleteRequested()))
          .thenAnswer((_) async => {});
      when(() => appBloc.add(const AppLogoutRequested()))
          .thenAnswer((_) async => {});
      when(() => userBloc.state).thenReturn(UserLoaded(user: currentUserData));
      when(() => themeBloc.state).thenReturn(false);
      when(() => themeBloc.add(const ThemeChanged(isThemeDark: false)))
          .thenAnswer((_) async => {});
      when(() => userBloc.getInterestedUsersToNotify(
              newGroupEventInterests: any(named: "newGroupEventInterests")))
          .thenAnswer((_) async => []);
    });

    testWidgets('Theme selctor profile - state = false',
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
                child: MultiBlocProvider(
                    providers: [
                      BlocProvider<AppBloc>.value(value: appBloc),
                      BlocProvider<UserBloc>.value(value: userBloc),
                      BlocProvider<ThemeBloc>.value(value: themeBloc),
                      BlocProvider<ModifyUserCubit>.value(
                          value: ModifyUserCubit(
                        userRepository: userRepository,
                      )),
                    ],
                    child: const MaterialApp(
                        home: Material(child: ProfilePage()))),
              );
            },
          ),
        );

        expect(find.byType(TextPhotoRow), findsOneWidget);
        expect(find.byType(NotificationsUserCol), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.text("save");

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        await tester.tap(find.byKey(const Key("theme_selector_button")));
        await tester.pumpAndSettle();
      });
    });
  });

  group("Tablet profile page test - theme selector - state false", () {
    const String currentUserId = "user1Id";
    const Size tabletLandscapeSize = Size(1374, 1024);
    const Size tabletPortraitSize = Size(1024, 1374);
    late FirebaseFirestore firebaseFirestore;
    late FirebaseStorage firebaseStorage;
    late MyEventsRepository myEventsRepository;
    late MyGroupsRepository myGroupsRepository;
    late NotificationsRepository notificationsRepository;
    late ChatRepository chatRepository;
    late UserRepository userRepository;
    late AppBloc appBloc;
    late UserBloc userBloc;
    late ThemeBloc themeBloc;
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
      themeBloc = MockThemeBloc();
      user = MockUser();
      currentUserData = WidgetHomeUtils.currentUserData;
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userBloc.state).thenReturn(UserLoaded(user: currentUserData));
      when(() => themeBloc.state).thenReturn(false);
      when(() => themeBloc.add(const ThemeChanged(isThemeDark: false)))
          .thenAnswer((_) async => {});
      when(() => userBloc.getInterestedUsersToNotify(
              newGroupEventInterests: any(named: "newGroupEventInterests")))
          .thenAnswer((_) async => []);
    });
    testWidgets(
        'Tablet landscape profile page test - theme selector - state false',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 0.3;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 0.3),
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
                    BlocProvider<UserBloc>.value(value: userBloc),
                    BlocProvider<ThemeBloc>.value(value: themeBloc),
                    BlocProvider<ModifyUserCubit>.value(
                        value: ModifyUserCubit(
                      userRepository: userRepository,
                    )),
                  ], child: const MaterialApp(home: HomeTabletPage())),
                );
              },
            ),
          ),
        );
        await tester.tap(find.byKey(const Key("go-to-profile-page")));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsUserCol), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.text("save");

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byKey(const Key("theme_selector_button")));
        await tester.pumpAndSettle();
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets(
        'Tablet portrait profile page test - theme selector - state false',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 0.3;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 0.3),
            child: ScreenUtilInit(
              designSize: tabletPortraitSize,
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
                    BlocProvider<UserBloc>.value(value: userBloc),
                    BlocProvider<ThemeBloc>.value(value: themeBloc),
                    BlocProvider<ModifyUserCubit>.value(
                        value: ModifyUserCubit(
                      userRepository: userRepository,
                    )),
                  ], child: const MaterialApp(home: HomeTabletPage())),
                );
              },
            ),
          ),
        );
        await tester.tap(find.byKey(const Key("go-to-profile-page")));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsUserCol), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.text("save");

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byKey(const Key("theme_selector_button")));
        await tester.pumpAndSettle();
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });

  group("Profile page Tablet", () {
    const String currentUserId = "user1Id";
    const Size tabletLandscapeSize = Size(1374, 1024);
    const Size tabletPortraitSize = Size(1024, 1374);
    late FirebaseFirestore firebaseFirestore;
    late FirebaseStorage firebaseStorage;
    late MyEventsRepository myEventsRepository;
    late MyGroupsRepository myGroupsRepository;
    late NotificationsRepository notificationsRepository;
    late ChatRepository chatRepository;
    late UserRepository userRepository;
    late AppBloc appBloc;
    late UserBloc userBloc;
    late ThemeBloc themeBloc;
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
      themeBloc = MockThemeBloc();
      user = MockUser();
      currentUserData = WidgetHomeUtils.currentUserData;
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userBloc.state).thenReturn(UserLoaded(user: currentUserData));
      when(() => themeBloc.state).thenReturn(true);
      when(() => themeBloc.add(const ThemeChanged(isThemeDark: true)))
          .thenAnswer((_) async => {});
      when(() => userBloc.getInterestedUsersToNotify(
              newGroupEventInterests: any(named: "newGroupEventInterests")))
          .thenAnswer((_) async => []);
    });
    testWidgets('First tablet profile page test landscape',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 0.3;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 0.3),
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
                    BlocProvider<UserBloc>.value(value: userBloc),
                    BlocProvider<ThemeBloc>.value(value: themeBloc),
                    BlocProvider<ModifyUserCubit>.value(
                        value: ModifyUserCubit(
                      userRepository: userRepository,
                    )),
                  ], child: const MaterialApp(home: HomeTabletPage())),
                );
              },
            ),
          ),
        );
        await tester.tap(find.byKey(const Key("go-to-profile-page")));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsUserCol), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.text("save");
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        expect(find.byKey(const Key("disabledSave")), findsNothing);
        expect(find.byKey(const Key("activeSave")), findsOneWidget);

        await tester.tap(find.byKey(const Key("activeSave")));

        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, "mynewName");
        await tester.enterText(
            find.byKey(const Key("Input_Row_Text_Field")).first, "");
        await tester.enterText(
            find.byKey(const Key("Input_Row_Text_Field")).last, "");

        await tester.pumpAndSettle();

        expect(find.byKey(const Key("disabledSave")), findsOneWidget);
        expect(find.byKey(const Key("activeSave")), findsNothing);

        await tester.enterText(
            find.byKey(const Key("Input_Row_Text_Field")).first, "Bio");

        await tester.pumpAndSettle();

        expect(find.byKey(const Key("disabledSave")), findsNothing);
        expect(find.byKey(const Key("activeSave")), findsOneWidget);

        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(0));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(1));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(2));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(3));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(4));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(5));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(6));

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byKey(const Key("theme_selector_button")));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(AppIcons.trashOutline));
        await tester.pumpAndSettle();
        expect(find.text("Continue"), findsOneWidget);

        await tester.tap(find.text("Cancel"));
        await tester.pumpAndSettle();

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byIcon(AppIcons.trashOutline));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Continue"));
        await tester.pumpAndSettle();

        verify(() => appBloc.add(const DeleteRequested())).called(1);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('Logout tablet profile page test landscape',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 0.3;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 0.3),
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
                    BlocProvider<UserBloc>.value(value: userBloc),
                    BlocProvider<ThemeBloc>.value(value: themeBloc),
                    BlocProvider<ModifyUserCubit>.value(
                        value: ModifyUserCubit(
                      userRepository: userRepository,
                    )),
                  ], child: const MaterialApp(home: HomeTabletPage())),
                );
              },
            ),
          ),
        );
        await tester.tap(find.byKey(const Key("go-to-profile-page")));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationsUserCol), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.text("save");

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        await tester.tap(find.byIcon(AppIcons.logOutOutline));
        await tester.pumpAndSettle();

        verify(() => appBloc.add(const AppLogoutRequested())).called(1);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('First tablet profile page test portrait',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 0.3;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 0.3),
            child: ScreenUtilInit(
              designSize: tabletPortraitSize,
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
                    BlocProvider<UserBloc>.value(value: userBloc),
                    BlocProvider<ThemeBloc>.value(value: themeBloc),
                    BlocProvider<ModifyUserCubit>.value(
                        value: ModifyUserCubit(
                      userRepository: userRepository,
                    )),
                  ], child: const MaterialApp(home: HomeTabletPage())),
                );
              },
            ),
          ),
        );
        await tester.tap(find.byKey(const Key("go-to-profile-page")));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsUserCol), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.text("save");
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        expect(find.byKey(const Key("disabledSave")), findsNothing);
        expect(find.byKey(const Key("activeSave")), findsOneWidget);

        await tester.tap(find.byKey(const Key("activeSave")));

        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, "mynewName");
        await tester.enterText(
            find.byKey(const Key("Input_Row_Text_Field")).first, "");
        await tester.enterText(
            find.byKey(const Key("Input_Row_Text_Field")).last, "");

        await tester.pumpAndSettle();

        expect(find.byKey(const Key("disabledSave")), findsOneWidget);
        expect(find.byKey(const Key("activeSave")), findsNothing);

        await tester.enterText(
            find.byKey(const Key("Input_Row_Text_Field")).first, "Bio");

        await tester.pumpAndSettle();

        expect(find.byKey(const Key("disabledSave")), findsNothing);
        expect(find.byKey(const Key("activeSave")), findsOneWidget);

        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(0));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(1));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(2));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(3));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(4));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(5));
        await tester.tap(find
            .descendant(
              of: find.byKey(const Key("Notifications_column")),
              matching: find.byType(IconButton),
            )
            .at(6));

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        await tester.tap(find.byIcon(AppIcons.trashOutline));
        await tester.pumpAndSettle();
        expect(find.text("Continue"), findsOneWidget);

        await tester.tap(find.text("Cancel"));
        await tester.pumpAndSettle();

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byIcon(AppIcons.trashOutline));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Continue"));
        await tester.pumpAndSettle();

        verify(() => appBloc.add(const DeleteRequested())).called(1);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('Logout tablet profile page test portrait',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 0.3;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 0.3),
            child: ScreenUtilInit(
              designSize: tabletPortraitSize,
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
                    BlocProvider<UserBloc>.value(value: userBloc),
                    BlocProvider<ThemeBloc>.value(value: themeBloc),
                    BlocProvider<ModifyUserCubit>.value(
                        value: ModifyUserCubit(
                      userRepository: userRepository,
                    )),
                  ], child: const MaterialApp(home: HomeTabletPage())),
                );
              },
            ),
          ),
        );
        await tester.tap(find.byKey(const Key("go-to-profile-page")));
        await tester.pumpAndSettle();

        expect(find.byType(NotificationsUserCol), findsOneWidget);
        expect(find.byType(ThemeSelector), findsOneWidget);

        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.text("save");

        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        await tester.tap(find.byIcon(AppIcons.logOutOutline));
        await tester.pumpAndSettle();

        verify(() => appBloc.add(const AppLogoutRequested())).called(1);
      });
    });
  });
}
