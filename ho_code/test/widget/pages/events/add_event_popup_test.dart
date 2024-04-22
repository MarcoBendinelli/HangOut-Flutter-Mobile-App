import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/pages/events/add_event_popup.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hang_out_app/data/models/user.dart';

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
  // late ChatRepository chatRepository;
  late UserRepository userRepository;
  // late NotificationsRepository notificationsRepository;
  late AppBloc appBloc;
  late User user;
  late UserData userData;
  late UserBloc userBloc;
  const String currentUserId = "user1Id";
  group("Add Event popup", () {
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
      // chatRepository = MockChatRepository();
      // notificationsRepository = MockNotificationsRepository();
      userRepository = MockUserRepository();
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userData.id).thenReturn(currentUserId);
      when(() => userData.name).thenReturn("user1");
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      // when(() => myEventsRepository.getEventsOfUser(currentUserId))
      //     .thenAnswer((_) => eventCompleter.future);
      // when(() => notificationsRepository.getNotifications(currentUserId))
      //     .thenAnswer((_) => notificationCompleter.future);
      when(() => myGroupsRepository.getGroupsOfUser(currentUserId))
          .thenAnswer((_) => groupCompleter.future);
    });

    testWidgets("Add Event popup initial", (tester) async {
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
                // RepositoryProvider<ChatRepository>(
                //     create: (context) => chatRepository),
                // RepositoryProvider<NotificationsRepository>(
                //     create: (context) => notificationsRepository),
                RepositoryProvider<UserRepository>(
                    create: (context) => userRepository),
              ],
              child: MultiBlocProvider(
                  providers: [
                    BlocProvider<AppBloc>.value(value: appBloc),
                    BlocProvider<UserBloc>.value(value: userBloc),
                  ],
                  child: const MaterialApp(
                      home: Material(
                          child: AddEventPopup(
                    heroTag: "tag",
                  )))),
            );
          },
        ),
      );

      ///find all the fields at initial value
      expect(find.text("YYYY-MM-DD"), findsOneWidget);
      expect(find.text("hh:mm"), findsOneWidget);
      expect(find.text("Write the event caption here"), findsOneWidget);
      expect(find.text("Search on the map"), findsOneWidget);
      expect(find.byKey(const Key("disabledDone")), findsOneWidget);
      await tester.enterText(
          find.byKey(const Key("text-photo-textInput")), "testTitle");
      expect(find.text("testTitle"), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, "testDescription");
      expect(find.text("testDescription"), findsOneWidget);
    });
  });
}
