import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/pages/explore/event_card/explore_event_card.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_page.dart';
import 'package:hang_out_app/presentation/pages/explore/group_card/explore_group_card.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';
import 'package:hang_out_app/presentation/widgets/scroll_category/multi_scroll_category.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hang_out_app/data/models/user.dart';

import '../../utils.dart';

class MockMyEventsRepository extends Mock implements MyEventsRepository {}

class MockMyGroupsRepository extends Mock implements MyGroupsRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockUser extends Mock implements User {}

class MockUserData extends Mock implements UserData {}

void main() {
  late MyEventsRepository myEventsRepository;
  late MyGroupsRepository myGroupsRepository;
  late ChatRepository chatRepository;
  late UserRepository userRepository;
  late NotificationsRepository notificationsRepository;
  late AppBloc appBloc;
  late User user;
  late UserData userData;
  late UserBloc userBloc;
  const String currentUserId = "user1Id";
  group("ExplorePageWithNoEvent", () {
    // Define the expected result
    final eventList = <Event>[]; // Initialize with your desired list of events
    final eventStream = Stream.fromIterable([eventList]);
    final eventCompleter = Completer<Stream<List<Event>>>();
    eventCompleter.complete(eventStream);
    //for notifications
    final notificationList =
        <OurNotification>[]; // Initialize with your desired list of events
    final notificationStream = Stream.fromIterable([notificationList]);
    final notificationCompleter = Completer<Stream<List<OurNotification>>>();
    notificationCompleter.complete(notificationStream);

    setUp(() {
      appBloc = MockAppBloc();
      userBloc = MockUserBloc();
      user = MockUser();
      userData = MockUserData();
      myEventsRepository = MockMyEventsRepository();
      myGroupsRepository = MockMyGroupsRepository();
      chatRepository = MockChatRepository();
      notificationsRepository = MockNotificationsRepository();
      userRepository = MockUserRepository();
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userData.id).thenReturn(currentUserId);
      when(() => userData.name).thenReturn("user1");
      when(() => userData.interests).thenReturn(["food", "culture"]);
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myEventsRepository.getNonParticipatingEventsOfUser(
          currentUserId, any())).thenAnswer((_) => eventCompleter.future);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
    });

    testWidgets('events page shows you have no events yet if loaded []',
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
                    ],
                    child: const MaterialApp(
                        home: Material(child: ExplorePage()))),
              );
            },
          ),
        );
        expect(find.text("Search"), findsOneWidget);
        // expect(find.byType(DropdownButton), findsOneWidget);
        expect(find.byType(MultiScrollCategory), findsOneWidget);
        expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text("No event found"), findsOneWidget);
      });
    });
  });
  group("ExplorePageWithEvents", () {
    // Define the expected result
    final eventList = <Event>[
      WidgetTestUtils.event1,
      WidgetTestUtils.event2
    ]; // Initialize with your desired list of events
    final eventStream = Stream.fromIterable([eventList]);
    final eventCompleter = Completer<Stream<List<Event>>>();
    eventCompleter.complete(eventStream);
    //for notifications
    final notificationList =
        <OurNotification>[]; // Initialize with your desired list of events
    final notificationStream = Stream.fromIterable([notificationList]);
    final notificationCompleter = Completer<Stream<List<OurNotification>>>();
    notificationCompleter.complete(notificationStream);
    //for event from id
    final eventFromIdStream =
        Stream.fromFuture(Future.value(WidgetTestUtils.event1));
    final eventFromIdCompleter = Completer<Stream<Event>>();
    eventFromIdCompleter.complete(eventFromIdStream);
    //for participants
    final participantList = <OtherUser>[
      WidgetTestUtils.participant
    ]; // Initialize with your desired list of events
    final participantStream = Stream.fromIterable([participantList]);

    setUp(() {
      appBloc = MockAppBloc();
      userBloc = MockUserBloc();
      user = MockUser();
      userData = MockUserData();
      myEventsRepository = MockMyEventsRepository();
      myGroupsRepository = MockMyGroupsRepository();
      chatRepository = MockChatRepository();
      notificationsRepository = MockNotificationsRepository();
      userRepository = MockUserRepository();
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userData.id).thenReturn(currentUserId);
      when(() => userData.name).thenReturn("user1");
      when(() => userData.interests).thenReturn(["food", "culture"]);
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myEventsRepository.getNonParticipatingEventsOfUser(
          currentUserId, any())).thenAnswer((_) => eventCompleter.future);
      when(() => myEventsRepository.getEventWithId(any()))
          .thenAnswer((_) => eventFromIdCompleter.future);
      when(() => myEventsRepository.getParticipantsToEvent("event1Id"))
          .thenAnswer((_) => participantStream);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
    });

    testWidgets('explore page shows the event not yet joined',
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
                    ],
                    child: const MaterialApp(
                        home: Material(child: ExplorePage()))),
              );
            },
          ),
        );
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ExploreEventCard), findsNWidgets(2));
      });
    });

    testWidgets('click on ExploreEventCard', (WidgetTester tester) async {
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
                        home: Material(child: ExplorePage()))),
              );
            },
          ),
        );
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ExploreEventCard), findsNWidgets(2));
        await tester.tap(find.byType(ExploreEventCard).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
      });
    });
  });
  group("ExplorePageSwitchGroupsEmpty", () {
    // Define the expected result
    final eventList = <Event>[
      WidgetTestUtils.event1,
      WidgetTestUtils.event2
    ]; // Initialize with your desired list of events
    final eventStream = Stream.fromIterable([eventList]);
    final eventCompleter = Completer<Stream<List<Event>>>();
    eventCompleter.complete(eventStream);
    //for notifications
    final notificationList =
        <OurNotification>[]; // Initialize with your desired list of events
    final notificationStream = Stream.fromIterable([notificationList]);
    final notificationCompleter = Completer<Stream<List<OurNotification>>>();
    notificationCompleter.complete(notificationStream);
    //for groups
    final groupList = <Group>[]; // Initialize with your desired list of events
    final groupStream = Stream.fromIterable([groupList]);
    final groupCompleter = Completer<Stream<List<Group>>>();
    groupCompleter.complete(groupStream);

    setUp(() {
      appBloc = MockAppBloc();
      userBloc = MockUserBloc();
      user = MockUser();
      userData = MockUserData();
      myEventsRepository = MockMyEventsRepository();
      myGroupsRepository = MockMyGroupsRepository();
      chatRepository = MockChatRepository();
      notificationsRepository = MockNotificationsRepository();
      userRepository = MockUserRepository();
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userData.id).thenReturn(currentUserId);
      when(() => userData.name).thenReturn("user1");
      when(() => userData.interests).thenReturn(["food", "culture"]);
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myEventsRepository.getNonParticipatingEventsOfUser(
          currentUserId, any())).thenAnswer((_) => eventCompleter.future);
      when(() => myGroupsRepository.getNonParticipatingGroupOfUser(
          currentUserId, any())).thenAnswer((_) => groupCompleter.future);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
    });

    testWidgets('switch to empty group explore', (WidgetTester tester) async {
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
                        home: Material(child: ExplorePage()))),
              );
            },
          ),
        );
        await tester.tap(find.byKey(const Key("drop-down")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("select-groups")).last);
        await tester.pumpAndSettle();
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text("No group found"), findsOneWidget);
      });
    });
  });
  group("ExplorePageSwitchGroupsLoadedAndFilter", () {
    // Define the expected result
    final eventList = <Event>[
      WidgetTestUtils.event1,
      WidgetTestUtils.event2
    ]; // Initialize with your desired list of events
    final eventStream = Stream.fromIterable([eventList]);
    final eventCompleter = Completer<Stream<List<Event>>>();
    eventCompleter.complete(eventStream);
    //for notifications
    final notificationList =
        <OurNotification>[]; // Initialize with your desired list of events
    final notificationStream = Stream.fromIterable([notificationList]);
    final notificationCompleter = Completer<Stream<List<OurNotification>>>();
    notificationCompleter.complete(notificationStream);
    //for groups
    final groupList = <Group>[
      WidgetTestUtils.group1,
      WidgetTestUtils.group2
    ]; // Initialize with your desired list of events
    final groupStream = Stream.fromIterable([groupList]);
    final groupCompleter = Completer<Stream<List<Group>>>();
    groupCompleter.complete(groupStream);
    //for groups2
    final group2List = <Group>[
      WidgetTestUtils.group1,
    ]; // Initialize with your desired list of events
    final group2Stream = Stream.fromIterable([group2List]);
    final group2Completer = Completer<Stream<List<Group>>>();
    group2Completer.complete(group2Stream);
    //for group from id
    final groupFromIdStream =
        Stream.fromFuture(Future.value(WidgetTestUtils.group1));
    final groupFromIdCompleter = Completer<Stream<Group>>();
    groupFromIdCompleter.complete(groupFromIdStream);
    //for participants
    final participantList = <OtherUser>[
      WidgetTestUtils.participant
    ]; // Initialize with your desired list of events
    final participantStream = Stream.fromIterable([participantList]);

    setUp(() {
      appBloc = MockAppBloc();
      userBloc = MockUserBloc();
      user = MockUser();
      userData = MockUserData();
      myEventsRepository = MockMyEventsRepository();
      myGroupsRepository = MockMyGroupsRepository();
      chatRepository = MockChatRepository();
      notificationsRepository = MockNotificationsRepository();
      userRepository = MockUserRepository();
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userData.id).thenReturn(currentUserId);
      when(() => userData.name).thenReturn("user1");
      when(() => userData.description).thenReturn("description");
      when(() => userData.photo).thenReturn("");
      when(() => userData.interests).thenReturn(["food", "culture"]);
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myEventsRepository.getNonParticipatingEventsOfUser(
          currentUserId, any())).thenAnswer((_) => eventCompleter.future);
      when(() => myGroupsRepository.getNonParticipatingGroupOfUser(
              currentUserId, ["food", "culture"]))
          .thenAnswer((_) => groupCompleter.future);
      when(() => myGroupsRepository
              .getNonParticipatingGroupOfUser(currentUserId, ["culture"]))
          .thenAnswer((_) => group2Completer.future);
      when(() => myGroupsRepository.getGroupWithId(any()))
          .thenAnswer((_) => groupFromIdCompleter.future);
      when(() => myGroupsRepository.getParticipantsToGroup(any()))
          .thenAnswer((_) => participantStream);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
    });

    testWidgets('switch to loaded group explore and filter',
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
                    ],
                    child: const MaterialApp(
                        home: Material(child: ExplorePage()))),
              );
            },
          ),
        );

        ///move to group page
        await tester.tap(find.byKey(const Key("drop-down")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("select-groups")).last);
        await tester.pumpAndSettle();
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ExploreGroupCard), findsNWidgets(2));

        ///tap on first filter to deselct it
        await tester.tap(find.byKey(const Key("scroll-rectangle")).first);
        await tester.pumpAndSettle();

        ///check that loadNonParticipatingGroups was called with different filter a one card was removed
        expect(find.byType(ExploreGroupCard), findsNWidgets(1));

        ///move back to explore
        await tester.tap(find.byKey(const Key("drop-down")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("select-events")).last);
        await tester.pumpAndSettle();
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ExploreEventCard), findsNWidgets(2));
      });
    });

    testWidgets('tap on Explore group card', (WidgetTester tester) async {
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
                        home: Material(child: ExplorePage()))),
              );
            },
          ),
        );

        ///move to group page
        await tester.tap(find.byKey(const Key("drop-down")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("select-groups")).last);
        await tester.pumpAndSettle();
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(ExploreGroupCard), findsNWidgets(2));
        await tester.tap(find.byType(ExploreGroupCard).first);
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
      });
    });
  });
  group("ExplorePageClickSearch", () {
    // Define the expected result
    final eventList = <Event>[
      WidgetTestUtils.event1,
      WidgetTestUtils.event2
    ]; // Initialize with your desired list of events
    final eventStream = Stream.fromIterable([eventList]);
    final eventCompleter = Completer<Stream<List<Event>>>();
    eventCompleter.complete(eventStream);
    //for notifications
    final notificationList = <OurNotification>[
      WidgetTestUtils.notification1
    ]; // Initialize with your desired list of events
    final notificationStream = Stream.fromIterable([notificationList]);
    final notificationCompleter = Completer<Stream<List<OurNotification>>>();
    notificationCompleter.complete(notificationStream);

    setUp(() {
      appBloc = MockAppBloc();
      userBloc = MockUserBloc();
      user = MockUser();
      userData = MockUserData();
      myEventsRepository = MockMyEventsRepository();
      myGroupsRepository = MockMyGroupsRepository();
      chatRepository = MockChatRepository();
      notificationsRepository = MockNotificationsRepository();
      userRepository = MockUserRepository();
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userData.id).thenReturn(currentUserId);
      when(() => userData.name).thenReturn("user1");
      when(() => userData.interests).thenReturn(["food", "culture"]);
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myEventsRepository.getNonParticipatingEventsOfUser(
          currentUserId, any())).thenAnswer((_) => eventCompleter.future);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
    });

    testWidgets('explore page search by name', (WidgetTester tester) async {
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
                        home: Material(child: ExplorePage()))),
              );
            },
          ),
        );
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///check that it starts with 2 events
        expect(find.byType(ExploreEventCard), findsNWidgets(2));
        await tester.tap(find.byType(TextField));
        await tester.enterText(
            find.byType(TextField), WidgetTestUtils.event1.name);
        await tester.pumpAndSettle();

        ///check that only one event remains unfiltered
        expect(find.byType(ExploreEventCard), findsNWidgets(1));
      });
    });

    // testWidgets('explore page click notification', (WidgetTester tester) async {
    //   await tester.runAsync(() async {
    //     await tester.pumpWidget(
    //       ScreenUtilInit(
    //         designSize: const Size(360, 800),
    //         builder: (context, child) {
    //           return MultiRepositoryProvider(
    //             providers: [
    //               RepositoryProvider<MyEventsRepository>(
    //                   create: (context) => myEventsRepository),
    //               RepositoryProvider<MyGroupsRepository>(
    //                   create: (context) => myGroupsRepository),
    //               RepositoryProvider<ChatRepository>(
    //                   create: (context) => chatRepository),
    //               RepositoryProvider<NotificationsRepository>(
    //                   create: (context) => notificationsRepository),
    //               RepositoryProvider<UserRepository>(
    //                   create: (context) => userRepository),
    //             ],
    //             child: MultiBlocProvider(
    //                 providers: [
    //                   BlocProvider<AppBloc>.value(value: appBloc),
    //                   BlocProvider<UserBloc>.value(value: userBloc),
    //                 ],
    //                 child: const MaterialApp(
    //                     home: Material(child: ExplorePage()))),
    //           );
    //         },
    //       ),
    //     );
    //     for (int i = 0; i < 5; i++) {
    //       // because pumpAndSettle doesn't work
    //       await tester.pump(const Duration(seconds: 1));
    //     }
    //     await tester.tap(find.byKey(const Key("notification-bell"),));
    //     await tester.pumpAndSettle();
    //     expect(find.byType(NotificationsPopup), findsOneWidget);

    //   });
    // });
  });
}
