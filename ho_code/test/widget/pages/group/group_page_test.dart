import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
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
import 'package:hang_out_app/presentation/pages/groups/add_group_popup.dart';
import 'package:hang_out_app/presentation/pages/groups/group_card/group_card.dart';
import 'package:hang_out_app/presentation/pages/groups/group_cards.dart';
import 'package:hang_out_app/presentation/pages/groups/groups_page.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_groups_events.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_return_and_name.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/multi_category_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/privacy_selector_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_photo_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/new_or_modify_group_widgets/group_members_row.dart';
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
  group("GroupsPageWithNoGroups", () {
    // Define the expected result
    final groupList = <Group>[]; // Initialize with your desired list of events
    final groupStream = Stream.fromIterable([groupList]);
    final groupCompleter = Completer<Stream<List<Group>>>();
    groupCompleter.complete(groupStream);
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
      when(() => myGroupsRepository.getGroupsOfUser(currentUserId))
          .thenAnswer((_) => groupCompleter.future);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
    });

    testWidgets('groups page shows you have no events yet if loaded []',
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
                        const MaterialApp(home: Material(child: GroupsPage()))),
              );
            },
          ),
        );
        expect(find.byType(TopBarGroupsEventsPages), findsOneWidget);
        expect(find.byType(GroupCards), findsOneWidget);
        expect(find.byType(OurCircularProgressIndicator), findsOneWidget);
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text("You don't have any groups yet!"), findsOneWidget);
      });
    });
  });
  group("GroupsPageWithGroups", () {
    // Define the expected result
    final groupList = <Group>[
      WidgetTestUtils.group1,
      WidgetTestUtils.group2
    ]; // Initialize with your desired list of events
    final groupStream = Stream.fromIterable([groupList]);
    final groupCompleter = Completer<Stream<List<Group>>>();
    groupCompleter.complete(groupStream);
    //for notifications
    final notificationList =
        <OurNotification>[]; // Initialize with your desired list of events
    final notificationStream = Stream.fromIterable([notificationList]);
    final notificationCompleter = Completer<Stream<List<OurNotification>>>();
    notificationCompleter.complete(notificationStream);
    //for messages
    final messageList =
        <Message>[]; // Initialize with your desired list of events
    final messageStream = Stream.fromIterable([messageList]);
    //for participants
    final participantList = <OtherUser>[
      WidgetTestUtils.participant
    ]; // Initialize with your desired list of events
    final participantStream = Stream.fromIterable([participantList]);
    //for group from id
    final groupFromIdStream =
        Stream.fromFuture(Future.value(WidgetTestUtils.group1));
    final groupFromIdCompleter = Completer<Stream<Group>>();
    groupFromIdCompleter.complete(groupFromIdStream);

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
      when(() => myGroupsRepository.getGroupsOfUser(currentUserId))
          .thenAnswer((_) => groupCompleter.future);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);

      when(() => myGroupsRepository.getParticipantsToGroup(any()))
          .thenAnswer((_) => participantStream);
      when(() => myGroupsRepository.getGroupWithId(any()))
          .thenAnswer((_) => groupFromIdCompleter.future);

      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
      when(() => myGroupsRepository.getGroupsOfUser(currentUserId))
          .thenAnswer((_) => groupCompleter.future);
      when(() => chatRepository.getTheChatOfTheGroupWithId(groupId: "group1Id"))
          .thenAnswer((_) => messageStream);
    });

    testWidgets('groups page shows your groups', (WidgetTester tester) async {
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
                        const MaterialApp(home: Material(child: GroupsPage()))),
              );
            },
          ),
        );
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.byType(GroupCard), findsNWidgets(2));
      });
    });
    testWidgets('clicking one one group chat is opened',
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
                        const MaterialApp(home: Material(child: GroupsPage()))),
              );
            },
          ),
        );
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        await tester.tap(find.byType(GroupCard).first);
        await tester.pumpAndSettle();
        expect(find.byType(ChatView), findsOneWidget);
      });
    });
  });
  group("GroupsPageClickAdd", () {
    // Define the expected result
    final groupList = <Group>[]; // Initialize with your desired list of events
    final groupStream = Stream.fromIterable([groupList]);
    final groupCompleter = Completer<Stream<List<Group>>>();
    groupCompleter.complete(groupStream);
    //for notifications
    final notificationList =
        <OurNotification>[]; // Initialize with your desired list of events
    final notificationStream = Stream.fromIterable([notificationList]);
    final notificationCompleter = Completer<Stream<List<OurNotification>>>();
    notificationCompleter.complete(notificationStream);
    //for theseUsers
    final theseUsersList = <OtherUser>[
      WidgetTestUtils.participant
    ]; // Initialize with your desired list of events
    final theseUsersStream = Stream.fromIterable([theseUsersList]);
    //for allUsers
    final allUsersList = <UserData>[
      WidgetTestUtils.allUser1
    ]; // Initialize with your desired list of events
    final allUsersStream = Stream.fromIterable([allUsersList]);

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
      when(() => userData.description).thenReturn("");
      when(() => userData.interests).thenReturn(<String>[]);
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => myGroupsRepository.getGroupsOfUser(currentUserId))
          .thenAnswer((_) => groupCompleter.future);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
      when(() => userRepository.getTheseUsers(any()))
          .thenAnswer((_) => theseUsersStream);
      when(() => userRepository.getAllUsers())
          .thenAnswer((_) => allUsersStream);
    });

    testWidgets('add group is in initial state', (WidgetTester tester) async {
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
                        const MaterialApp(home: Material(child: GroupsPage()))),
              );
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TapFadeIcon), findsNWidgets(2));
        await tester.tap(find.byType(TapFadeIcon).first);
        await tester.pumpAndSettle();
        expect(find.byType(AddGroupPopup), findsOneWidget);
        expect(find.byType(TopBarReturnAndName), findsOneWidget);
        expect(find.byType(TextPhotoRow), findsOneWidget);
        expect(find.byType(TextInputRow), findsOneWidget);
        expect(find.byType(GroupMembersRow), findsOneWidget);

        expect(find.byType(MultiCategoryInputRow), findsOneWidget);
        expect(find.byType(PrivacySelectorRow), findsOneWidget);
        expect(find.text("Max 20 characters"), findsOneWidget);
        expect(find.text(Constants.groupCaptionHint), findsOneWidget);
        expect(
            find.byKey(
              const Key("disabledDone"),
            ),
            findsOneWidget);
      });
    });
    testWidgets('add group update fields', (WidgetTester tester) async {
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
                        const MaterialApp(home: Material(child: GroupsPage()))),
              );
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TapFadeIcon), findsNWidgets(2));
        await tester.tap(find.byType(TapFadeIcon).first);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key("disabledDone")), findsOneWidget);
        expect(find.byKey(const Key("activeDone")), findsNothing);
        await tester.enterText(find.byType(TextField).first, "GroupName");
        await tester.enterText(find.byType(TextField).last, "GroupDescription");
        await tester.tap(find.byKey(const Key("scroll-rectangle")).first);
        await tester.tap(find.byKey(const Key("public-selector")));
        await tester.pumpAndSettle();

        ///expect done to now be active
        expect(find.byKey(const Key("activeDone")), findsOneWidget);

        ///add memebr popup and still active done
        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.arrowIosDownOutline));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key("activeDone")), findsOneWidget);
      });
    });
  });
}
