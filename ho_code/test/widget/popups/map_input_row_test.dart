import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/map/map_cubit.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/popups/map_input_row.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockUser extends Mock implements User {}

class MockMapCubit extends MockCubit<MapState> implements MapCubit {}

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
    late MapCubit mapCubit;
    late MapCubit realMapCubit;
    late User user;
    late UserData currentUserData;
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
      mapCubit = MockMapCubit();
      realMapCubit = MapCubit();
      user = MockUser();
      currentUserData = WidgetHomeUtils.currentUserData;
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userBloc.state).thenReturn(UserLoaded(user: currentUserData));
      when(() => mapCubit.state).thenReturn(const MapState());
      when(() => userBloc.getInterestedUsersToNotify(
              newGroupEventInterests: any(named: "newGroupEventInterests")))
          .thenAnswer((_) async => []);
    });

    testWidgets('test initial state ask to tap on map',
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
                      BlocProvider<MapCubit>.value(value: mapCubit),
                    ],
                    child: MaterialApp(
                        home: MapInputRow(
                      callback: ({
                        latitude = 0,
                        longitude = 0,
                        locationName = "",
                      }) {},
                    ))),
              );
            },
          ),
        );
        expect(find.byType(MapInputRow), findsOneWidget);
        expect(find.text("Search on the map"), findsOneWidget);
      });
    });
    group("map cubit return point", () {
      setUp(() {
        when(() => mapCubit.state).thenReturn(const MapState(
            status: MapStatus.success, locationName: "selectedName"));
      });
      testWidgets('test selected point is displayed',
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
                        BlocProvider<MapCubit>.value(value: mapCubit),
                      ],
                      child: MaterialApp(
                          home: MapInputRow(
                        callback: ({
                          latitude = 0,
                          longitude = 0,
                          locationName = "",
                        }) {},
                      ))),
                );
              },
            ),
          );
          expect(find.byType(MapInputRow), findsOneWidget);
          expect(find.text("selectedName"), findsOneWidget);
        });
      });
    });
    group("map cubit return error", () {
      setUp(() {
        when(() => mapCubit.state).thenReturn(const MapState(
            status: MapStatus.error, locationName: "selectedName"));
      });
      testWidgets('test invalid point is displayed',
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
                        BlocProvider<MapCubit>.value(value: mapCubit),
                      ],
                      child: MaterialApp(
                          home: MapInputRow(
                        callback: ({
                          latitude = 0,
                          longitude = 0,
                          locationName = "",
                        }) {},
                      ))),
                );
              },
            ),
          );
          expect(find.byType(MapInputRow), findsOneWidget);
          expect(find.text("selectedName"), findsNothing);
          expect(find.text('Invalid Location'), findsOneWidget);
        });
      });
    });

    testWidgets('test all 3 possible states', (WidgetTester tester) async {
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
                      BlocProvider<MapCubit>.value(value: realMapCubit),
                    ],
                    child: MaterialApp(
                        home: MapInputRow(
                      callback: ({
                        latitude = 0,
                        longitude = 0,
                        locationName = "",
                      }) {},
                    ))),
              );
            },
          ),
        );
        expect(find.byType(MapInputRow), findsOneWidget);
        expect(find.text('Search on the map'), findsOneWidget);
        realMapCubit.addPosition(
            latitude: 1, longitude: 1, locationName: "locationName");
        await tester.pumpAndSettle();
        expect(find.text('locationName'), findsOneWidget);
        realMapCubit.setFailure();
        await tester.pumpAndSettle();
        expect(find.text('Invalid Location'), findsOneWidget);
      });
    });
    testWidgets('test all 3 Tablet possible states',
        (WidgetTester tester) async {
      const Size tabletLandscapeSize = Size(1374, 1024);
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletLandscapeSize;
        tester.binding.window.devicePixelRatioTestValue = 1.0;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletLandscapeSize, devicePixelRatio: 1.0),
            child: ScreenUtilInit(
              designSize: const Size(360, 800),
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
                        BlocProvider<MapCubit>.value(value: realMapCubit),
                      ],
                      child: MaterialApp(
                          home: MapInputRow(
                        callback: ({
                          latitude = 0,
                          longitude = 0,
                          locationName = "",
                        }) {},
                      ))),
                );
              },
            ),
          ),
        );
        expect(find.byType(MapInputRow), findsOneWidget);
        expect(find.text('Search on the map'), findsOneWidget);
        realMapCubit.addPosition(
            latitude: 1, longitude: 1, locationName: "locationName");
        await tester.pumpAndSettle();
        expect(find.text('locationName'), findsOneWidget);
        realMapCubit.setFailure();
        await tester.pumpAndSettle();
        expect(find.text('Invalid Location'), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
