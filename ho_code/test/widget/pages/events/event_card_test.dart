import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/calendar_widget.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/event_card.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/event_card_bottom.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/event_card_top.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:table_calendar/table_calendar.dart';
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
  late MyEventsRepository eventsRepository;
  late AppBloc appBloc;
  late User user;
  late UserData userData;
  late UserBloc userBloc;
  const String currentUserId = "user1Id";
  group("event_card and calendar", () {
    // Define the expected result
    final eventList = <Event>[]; // Initialize with your desired list of events
    final eventStream = Stream.fromIterable([eventList]);
    final eventCompleter = Completer<Stream<List<Event>>>();
    eventCompleter.complete(eventStream);

    setUp(() {
      appBloc = MockAppBloc();
      userBloc = MockUserBloc();
      user = MockUser();
      userData = MockUserData();
      eventsRepository = MockMyEventsRepository();
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userData.id).thenReturn(currentUserId);
      when(() => userData.name).thenReturn("user1");
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => eventsRepository.getEventsOfUser(currentUserId))
          .thenAnswer((_) => eventCompleter.future);
    });
    testWidgets('SingleEventCard no photo', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return RepositoryProvider<MyEventsRepository>.value(
              value: eventsRepository,
              child: MultiBlocProvider(providers: [
                BlocProvider<AppBloc>.value(value: appBloc),
                BlocProvider<UserBloc>.value(value: userBloc),
              ], child: MaterialApp(home: EventCard(WidgetTestUtils.event1))),
            );
          },
        ),
      );
      expect(find.byType(EventCardBottom), findsOneWidget);
      expect(find.byType(EventCardTop), findsOneWidget);
    });

    testWidgets('SingleEventCard photo', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return RepositoryProvider<MyEventsRepository>.value(
              value: eventsRepository,
              child: MultiBlocProvider(providers: [
                BlocProvider<AppBloc>.value(value: appBloc),
                BlocProvider<UserBloc>.value(value: userBloc),
              ], child: MaterialApp(home: EventCard(WidgetTestUtils.event2))),
            );
          },
        ),
      );
      expect(find.byType(EventCardBottom), findsOneWidget);
      expect(find.byType(EventCardTop), findsOneWidget);
    });

    testWidgets('CalendarWidget', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) {
            return RepositoryProvider<MyEventsRepository>.value(
              value: eventsRepository,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<UserBloc>.value(value: userBloc),
                ],
                child: MaterialApp(
                  home: Material(
                    child: CalendarWidget(
                      events: [WidgetTestUtils.event1],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
      expect(find.byType(TableCalendar), findsOneWidget);
      // expect(find.byType(EventCardTop), findsOneWidget);
      // await tester.pumpAndSettle();
      // expect(find.byType(ChatView), findsOneWidget);
    });
  });
}
