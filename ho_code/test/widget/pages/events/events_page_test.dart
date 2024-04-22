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
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/pages/events/add_event_popup.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/calendar_widget.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/event_card.dart';
import 'package:hang_out_app/presentation/pages/events/events_page.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_groups_events.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
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
  group("EventsPageWithNoEvents", () {
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
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myEventsRepository.getEventsOfUser(currentUserId))
          .thenAnswer((_) => eventCompleter.future);
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
                    child:
                        const MaterialApp(home: Material(child: EventsPage()))),
              );
            },
          ),
        );
        expect(find.byType(TopBarGroupsEventsPages), findsOneWidget);
        expect(find.byType(CalendarWidget), findsOneWidget);
        expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text("You don't have any events yet!"), findsOneWidget);
      });
    });
    // testWidgets('load events_page', (tester) async {
    //   await tester.pumpWidget(
    //     ScreenUtilInit(
    //       designSize: const Size(360, 800),
    //       builder: (context, child) {
    //         return MultiRepositoryProvider(
    //           providers: [
    //             RepositoryProvider<MyEventsRepository>(
    //                 create: (context) => myEventsRepository),
    //             RepositoryProvider<MyGroupsRepository>(
    //                 create: (context) => myGroupsRepository),
    //             RepositoryProvider<ChatRepository>(
    //                 create: (context) => chatRepository),
    //             RepositoryProvider<NotificationsRepository>(
    //                 create: (context) => notificationsRepository),
    //             RepositoryProvider<UserRepository>(
    //                 create: (context) => userRepository),
    //           ],
    //           child: MultiBlocProvider(providers: [
    //             BlocProvider<AppBloc>.value(value: appBloc),
    //             BlocProvider<UserBloc>.value(value: userBloc),
    //           ], child: const MaterialApp(home: Material(child: EventsPage()))),
    //         );
    //       },
    //     ),
    //   );
    //   expect(find.byType(TopBarGroupsEventsPages), findsOneWidget);
    //   expect(find.byType(CalendarWidget), findsOneWidget);
    //   expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
    //   for (int i = 0; i < 10; i++) {
    //     // because pumpAndSettle doesn't work with riverpod
    //     await tester.pump(const Duration(seconds: 1));
    //   }
    //   expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
    //   // expect(find.text("You don't have any events yet!"), findsOneWidget);
    //   // expect(find.text("An error occurred while loading cards"), findsOneWidget);
    // });
  });

  group("EventsPageWithEvent", () {
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
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myEventsRepository.getEventsOfUser(currentUserId))
          .thenAnswer((_) => eventCompleter.future);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
    });
    testWidgets('events page shows your loaded event',
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
                    child:
                        const MaterialApp(home: Material(child: EventsPage()))),
              );
            },
          ),
        );
        expect(find.byType(TopBarGroupsEventsPages), findsOneWidget);
        expect(find.byType(CalendarWidget), findsOneWidget);
        expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(EventCard), findsAtLeastNWidgets(2));
      });
    });
  });
  group("EventsPageClickAdd", () {
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
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myEventsRepository.getEventsOfUser(currentUserId))
          .thenAnswer((_) => eventCompleter.future);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
      when(() => myGroupsRepository.getGroupsOfUser(currentUserId))
          .thenAnswer((_) => groupCompleter.future);
    });
    testWidgets('events page shows add popup', (WidgetTester tester) async {
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
                    child:
                        const MaterialApp(home: Material(child: EventsPage()))),
              );
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TapFadeIcon), findsNWidgets(2));
        await tester.tap(find.byKey(const Key("add")));
        await tester.pumpAndSettle();
        expect(find.byType(AddEventPopup), findsOneWidget);
      });
    });
  });
  group("EventsPageClickEventCard", () {
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
    //for messages
    final messageList =
        <Message>[]; // Initialize with your desired list of events
    final messageStream = Stream.fromIterable([messageList]);
    //for participants
    final participantList = <OtherUser>[
      WidgetTestUtils.participant
    ]; // Initialize with your desired list of events
    final participantStream = Stream.fromIterable([participantList]);
    //for event from id 
    final eventFromIdStream =
        Stream.fromFuture(Future.value(WidgetTestUtils.event1));
    final eventFromIdCompleter = Completer<Stream<Event>>();
    eventFromIdCompleter.complete(eventFromIdStream);

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
      when(() => userData.photo).thenReturn("");
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myEventsRepository.getEventsOfUser(currentUserId))
          .thenAnswer((_) => eventCompleter.future);
      when(() => myEventsRepository.getParticipantsToEvent("event1Id"))
          .thenAnswer((_) => participantStream);
      when(() => myEventsRepository.getEventWithId("event1Id"))
          .thenAnswer((_) => eventFromIdCompleter.future);

      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
      when(() => myGroupsRepository.getGroupsOfUser(currentUserId))
          .thenAnswer((_) => groupCompleter.future);
      when(() => chatRepository.getTheChatOfTheEventWithId(eventId: "event1Id"))
          .thenAnswer((_) => messageStream);
    });
    testWidgets('events page shows chatView on card click',
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
                    child:
                        const MaterialApp(home: Material(child: EventsPage()))),
              );
            },
          ),
        );
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(EventCard), findsNWidgets(2));
        await tester.tap(find.byType(EventCard).first);
        await tester.pumpAndSettle();
        expect(find.byType(ChatView), findsOneWidget);
      });
    });
  });
}
