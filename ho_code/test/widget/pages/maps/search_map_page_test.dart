import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/pages/maps/search_map_page.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:mocktail/mocktail.dart';
import '../../utils.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockUser extends Mock implements User {}

class MockController extends Mock implements PickerMapController {}

void main() {
  group("Map Page", () {
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
    late PickerMapController pickerMapController;
    String text = "text";
    setUp(() async {
      firebaseFirestore = FakeFirebaseFirestore();
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
      pickerMapController = MockController();
      when(() => user.id).thenReturn(currentUserId);
      when(() => pickerMapController.searchableText)
          .thenReturn(ValueNotifier(text));
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userBloc.state).thenReturn(UserLoaded(user: currentUserData));
      when(() => userBloc.getInterestedUsersToNotify(
              newGroupEventInterests: any(named: "newGroupEventInterests")))
          .thenAnswer((_) async => []);
    });
    testWidgets('test top search map widget', (WidgetTester tester) async {
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
                        home: TopSearchWidget(
                      testController: pickerMapController,
                    ))),
              );
            },
          ),
        );
        expect(find.byType(TopSearchWidget), findsOneWidget);
      });
    });
    testWidgets('test map parts', (WidgetTester tester) async {
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
                  child: const MaterialApp(
                      home: Scaffold(
                    body: SearchMapPage(
                      isForTest: true,
                    ),
                  )),
                ),
              );
            },
          ),
        );
        expect(find.byType(SearchMapPage), findsOneWidget);
        expect(find.byKey(const Key("top-widget-picker")), findsOneWidget);
        expect(find.byKey(const Key("bottom-widget-picker")), findsOneWidget);
      });
    });
    testWidgets('test map Tablet parts', (WidgetTester tester) async {
      const Size tabletLandscapeSize = Size(1374, 1024);
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
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<AppBloc>.value(value: appBloc),
                      BlocProvider<UserBloc>.value(value: userBloc),
                    ],
                    child: const MaterialApp(
                        home: Scaffold(
                      body: SearchMapPage(
                        isForTest: true,
                      ),
                    )),
                  ),
                );
              },
            ),
          ),
        );
        expect(find.byType(SearchMapPage), findsOneWidget);
        expect(
            find.byKey(const Key("top-tablet-widget-picker")), findsOneWidget);
        expect(find.byKey(const Key("bottom-tablet-widget-picker")),
            findsOneWidget);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });
  });
}
