import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/groups/add_group/add_group_cubit.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/pages/groups/add_group_popup.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hang_out_app/data/models/user.dart';
import '../../../unit/blocs/members/members_bloc_test.dart';
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

class MockGroup extends Mock implements Group {}

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
  late AddGroupCubit addGroupCubit;
  const String currentUserId = "user1Id";
  group("description", () {
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
      addGroupCubit = AddGroupCubit(groupsRepository: myGroupsRepository);
      registerFallbackValue(MockGroup());
      registerFallbackValue(MockOtherUser());
      when(() => user.id).thenReturn(currentUserId);
      when(() => appBloc.state).thenReturn(AppState.authenticated(user));
      when(() => userData.id).thenReturn(currentUserId);
      when(() => userData.name).thenReturn("user1");
      when(() => userData.photo).thenReturn("");
      when(() => userData.description).thenReturn("");
      when(() => userData.interests).thenReturn(<String>[]);
      when(() => userBloc.state).thenReturn(UserLoaded(user: userData));
      when(() => userBloc.getInterestedUsersToNotify(
              newGroupEventInterests: any(named: "newGroupEventInterests")))
          .thenAnswer((_) async => []);
      when(() => myGroupsRepository.getGroupsOfUser(currentUserId))
          .thenAnswer((_) => groupCompleter.future);
      when(() => notificationsRepository.getNotifications(currentUserId))
          .thenAnswer((_) => notificationCompleter.future);
      when(() => userRepository.getTheseUsers(any()))
          .thenAnswer((_) => theseUsersStream);
      when(() => userRepository.getAllUsers())
          .thenAnswer((_) => allUsersStream);
      when(() => myGroupsRepository.saveNewGroup(
          group: any(named: "group"),
          creator: any(named: "creator"),
          imageFile: null,
          members: any(named: "members"))).thenAnswer((_) async => "groupId");
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
                      BlocProvider<AddGroupCubit>.value(value: addGroupCubit),
                      BlocProvider<MembersBloc>.value(
                          value: MembersBloc(
                              eventsRepository: myEventsRepository,
                              groupsRepository: myGroupsRepository,
                              userRepository: userRepository))
                    ],
                    child: const MaterialApp(
                        home: Material(
                            child: AddGroupPopup(
                      heroTag: "tag",
                    )))),
              );
            },
          ),
        );

        // expect(find.byType(TapFadeIcon), findsNWidgets(2));
        // await tester.tap(find.byType(TapFadeIcon).first);
        // await tester.pumpAndSettle();
        expect(find.byKey(const Key("disabledDone")), findsOneWidget);
        expect(find.byKey(const Key("activeDone")), findsNothing);
        await tester.enterText(find.byType(TextField).first, "GroupName");
        await tester.enterText(find.byType(TextField).last, "GroupDescription");
        await tester.tap(find.byKey(const Key("scroll-rectangle")).first);
        await tester.tap(find.byKey(const Key("public-selector")));
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///expect done to now be active
        expect(find.byKey(const Key("activeDone")), findsOneWidget);
        final listFinder = find.byType(SingleChildScrollView).first;
        final itemFinder = find.byKey(const Key('activeDone'));

        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byKey(const Key("activeDone")));
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }
        verify(() => myGroupsRepository.saveNewGroup(
              group: any(named: "group"),
              creator: any(named: "creator"),
              imageFile: null,
              members: any(named: "members"),
            )).called(1);
        // ///add memebr popup and still active done
        // await tester.tap(find.byKey(const Key("add-member-button")));
        // await tester.pumpAndSettle();
        // await tester.tap(find.byType(GestureDetector).first);
        // await tester.pumpAndSettle();
        // expect(find.byKey(const Key("activeDone")), findsOneWidget);
      });
    });
  });
}
