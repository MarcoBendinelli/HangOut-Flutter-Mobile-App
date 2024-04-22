import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/user/modify_user_cubit.dart';
import 'package:hang_out_app/data/models/user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/pages/events/add_event_popup.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/event_card.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/event_tablet_card.dart';
import 'package:hang_out_app/presentation/pages/events/events_page.dart';
import 'package:hang_out_app/presentation/pages/events/events_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/explore/event_card/explore_event_card.dart';
import 'package:hang_out_app/presentation/pages/explore/event_card/explore_tablet_event_card.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_page.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/explore/group_card/explore_group_card.dart';
import 'package:hang_out_app/presentation/pages/explore/group_card/explore_tablet_group_card.dart';
import 'package:hang_out_app/presentation/pages/groups/add_group_popup.dart';
import 'package:hang_out_app/presentation/pages/groups/group_card/group_card.dart';
import 'package:hang_out_app/presentation/pages/groups/group_card/group_tablet_card.dart';
import 'package:hang_out_app/presentation/pages/groups/groups_page.dart';
import 'package:hang_out_app/presentation/pages/groups/groups_tablet_page.dart';
import 'package:hang_out_app/presentation/pages/home_page.dart';
import 'package:hang_out_app/presentation/pages/home_tablet_page.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/bottom_tablet_nav_bar.dart';
import 'package:hang_out_app/presentation/widgets/bars/bottom_white_nav_bar.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/popups/chat_tablet_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/modify_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/modify_group_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/notifications/notifications_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/user_info/user_info.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class MockUser extends Mock implements User {}

void main() {
  group("Big Tests", () {
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
      when(() => userBloc.getInterestedUsersToNotify(
              newGroupEventInterests: any(named: "newGroupEventInterests")))
          .thenAnswer((_) async => []);
    });
    testWidgets('go through all events screens', (WidgetTester tester) async {
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
                child: MultiBlocProvider(providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<UserBloc>.value(value: userBloc),
                ], child: const MaterialApp(home: HomePage())),
              );
            },
          ),
        );
        expect(find.byType(ExplorePage), findsOneWidget);
        expect(find.byType(BottomWhiteNavBar), findsOneWidget);
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();

        ///check that the user event has been loaded
        expect(find.byType(EventsPage), findsOneWidget);
        expect(find.byType(EventCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.event1["name"] as String),
            findsOneWidget);

        ///click on the event and check message is present
        await tester.tap(find.byType(EventCard));
        await tester.pumpAndSettle();
        expect(find.byType(ChatView), findsOneWidget);
        expect(find.text(WidgetHomeUtils.messageEvent1["text"] as String),
            findsOneWidget);

        ///expect top bar and message to display user name
        expect(
            find.text(WidgetHomeUtils.user1["name"] as String),
            findsNWidgets(
                1)); //bacause 2 memebrs the top one is followed by, and is not found

        ///open event info
        await tester.tap(find.text(
          WidgetHomeUtils.event1["name"] as String,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        expect(find.byIcon(AppIcons.sport), findsOneWidget);

        ///press modify
        await tester.tap(find.byIcon(AppIcons.edit2Outline));
        await tester.pumpAndSettle();
        expect(find.byType(ModifyEventPopup), findsOneWidget);
        await tester.enterText(find.byType(TextField).first, "new Name");
        await tester.enterText(find.byType(TextField).last, "new Caption");
        await tester.tap(find.byIcon(AppIcons.privateOutlined));
        await tester.pumpAndSettle();

        ///scroll down to done button
        var listFinder = find.byType(SingleChildScrollView).first;
        var itemFinder = find.text("done");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byIcon(AppIcons.food));
        await tester.tap(find.text("done"));
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        expect(find.text("new Name"), findsOneWidget);
        expect(find.text("new Caption"), findsOneWidget);
        expect(find.byIcon(AppIcons.food), findsOneWidget);

        ///go back to events page
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline).last);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
        await tester.pumpAndSettle();
        expect(find.byType(EventsPage), findsOneWidget);

        ///create new event
        await tester.tap(find.byIcon(AppIcons.plusCircleOutline));
        await tester.pumpAndSettle();
        expect(find.byType(AddEventPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.edit2Outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text("Done"));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, "new event Name");
        await tester.enterText(
            find.byType(TextField).last, "new event description");
        await tester.tap(find.byIcon(AppIcons.publicOutlined));
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("done");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        ///click some of the options present in the bottom half
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.sport));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CircleAvatar).last);
        await tester.pumpAndSettle();

        ///check that done can be pressed and press it
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        expect(find.byKey(const Key("activeDone")), findsOneWidget);
        await tester.tap(find.byKey(const Key("activeDone")));
        await tester.pumpAndSettle();
        pumpEventQueue(times: 20);

        expect(find.byType(EventsPage), findsOneWidget);
      });
    });
    testWidgets('go through all groups screens', (WidgetTester tester) async {
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
                child: MultiBlocProvider(providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<UserBloc>.value(value: userBloc),
                ], child: const MaterialApp(home: HomePage())),
              );
            },
          ),
        );
        expect(find.byType(ExplorePage), findsOneWidget);
        expect(find.byType(BottomWhiteNavBar), findsOneWidget);
        await tester.tap(find.byKey(const Key("go-to-groups-page")));
        await tester.pumpAndSettle();

        ///check that the user group has been loaded
        expect(find.byType(GroupsPage), findsOneWidget);
        expect(find.byType(GroupCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.group1["name"] as String),
            findsOneWidget);

        ///click on the group and check message is present
        await tester.tap(find.byType(GroupCard));
        await tester.pumpAndSettle();
        expect(find.byType(ChatView), findsOneWidget);
        expect(find.text(WidgetHomeUtils.messageEvent1["text"] as String),
            findsOneWidget);

        ///expect top bar and message to display user name
        expect(
            find.text(WidgetHomeUtils.user1["name"] as String),
            findsNWidgets(
                1)); //1 because in top part name is followed by comma with no space

        ///open group info
        await tester.tap(find.text(
          WidgetHomeUtils.group1["name"] as String,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
        expect(find.byIcon(AppIcons.food), findsOneWidget);
        expect(find.byIcon(AppIcons.music), findsOneWidget);

        ///press modify
        await tester.tap(find.byIcon(AppIcons.edit2Outline));
        await tester.pumpAndSettle();
        expect(find.byType(ModifyGroupPopup), findsOneWidget);
        await tester.enterText(find.byType(TextField).first, "new Name");
        await tester.enterText(find.byType(TextField).last, "new Caption");
        await tester.tap(find.byIcon(AppIcons.privateOutlined));
        await tester.pumpAndSettle();

        ///add member popup and still active done
        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const Key("search-user-bar")), "user2");
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("add-user-selector")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("done-add-button")));
        await tester.pumpAndSettle();

        ///remove member popup and still active done
        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const Key("search-user-bar")), "user2");
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("add-user-selector")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("done-add-button")));
        await tester.pumpAndSettle();

        ///open again just to close by arrow

        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.arrowIosDownOutline));
        await tester.pumpAndSettle();

        ///add one member again
        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const Key("search-user-bar")), "user2");
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("add-user-selector")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("done-add-button")));
        await tester.pumpAndSettle();

        /// go down to done button
        var listFinder = find.byType(SingleChildScrollView).first;
        var itemFinder = find.text("done");
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byIcon(AppIcons.culture));
        await tester.tap(find.text("done"));
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
        expect(find.text("new Name"), findsOneWidget);
        expect(find.text("new Caption"), findsOneWidget);
        expect(find.byIcon(AppIcons.culture), findsOneWidget);

        ///go back to groups page
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline).last);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
        await tester.pumpAndSettle();
        expect(find.byType(GroupsPage), findsOneWidget);

        ///create new group
        await tester.tap(find.byIcon(AppIcons.plusCircleOutline));
        await tester.pumpAndSettle();
        expect(find.byType(AddGroupPopup), findsOneWidget);
        // await tester.tap(find.byIcon(AppIcons.edit2Outline));
        // await tester.pumpAndSettle();
        // await tester.tap(find.text("Done"));
        // await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, "new group Name");
        await tester.enterText(
            find.byType(TextField).last, "new group description");
        await tester.pumpAndSettle();

        ///add one member again
        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const Key("search-user-bar")), "user2");
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("add-user-selector")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("done-add-button")));
        await tester.pumpAndSettle();

        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("done");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        ///click some of the options present in the bottom half
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.publicOutlined));
        await tester.tap(find.byIcon(AppIcons.sport));
        await tester.tap(find.byIcon(AppIcons.culture));
        await tester.pumpAndSettle();

        ///check that done can be pressed and press it
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        expect(find.byKey(const Key("activeDone")), findsOneWidget);
        await tester.tap(find.byKey(const Key("activeDone")));
        await tester.pumpAndSettle();
        pumpEventQueue(times: 20);

        expect(find.byType(GroupsPage), findsOneWidget);
      });
    });
    testWidgets('go through all explore screens event side',
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
                child: MultiBlocProvider(providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<UserBloc>.value(value: userBloc),
                ], child: const MaterialApp(home: HomePage())),
              );
            },
          ),
        );
        expect(find.byType(ExplorePage), findsOneWidget);
        expect(find.byType(BottomWhiteNavBar), findsOneWidget);

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///check that the user not joined event has been loaded
        expect(find.byType(ExploreEventCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.event2["name"] as String),
            findsOneWidget);

        ///click on the event and check content
        await tester.tap(find.byType(ExploreEventCard));
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);

        ///it's a popup so below is considered as well, find the creator in participants
        expect(find.byIcon(AppIcons.food), findsNWidgets(2)); //scroll+popup
        expect(
            find.text(WidgetHomeUtils.user2["name"] as String), findsOneWidget);
        expect(find.text(WidgetHomeUtils.event2["locationName"] as String),
            findsOneWidget);

        /// check members profile (user2) and go back
        expect(find.byType(CircleAvatar), findsOneWidget);
        await tester.tap(find.byType(CircleAvatar));
        await tester.pumpAndSettle();
        expect(find.byType(UserInfo), findsOneWidget);
        expect(find.text(WidgetHomeUtils.user2["description"] as String),
            findsOneWidget);
        await tester.tap(find.byKey(const Key("user-info-bacl-button")));
        await tester.pumpAndSettle();

        ///join event
        await tester.tap(find.text("join"));
        await pumpEventQueue(times: 20);
        // expect(find.text("no event found"), findsOneWidget);
      });
    });
    testWidgets('go through all explore screens group side',
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
                child: MultiBlocProvider(providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<UserBloc>.value(value: userBloc),
                ], child: const MaterialApp(home: HomePage())),
              );
            },
          ),
        );
        expect(find.byType(ExplorePage), findsOneWidget);
        expect(find.byType(BottomWhiteNavBar), findsOneWidget);

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///move to explore group section
        await tester.tap(find.byKey(const Key("drop-down")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("select-groups")).last);
        await tester.pumpAndSettle();

        ///check that the user not joined group has been loaded
        expect(find.byType(ExploreGroupCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.group2["name"] as String),
            findsOneWidget);

        ///click on the group and check content
        await tester.tap(find.byType(ExploreGroupCard));
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);

        ///it's a popup so below is considered as well, find the creator in participants
        expect(
            find.byIcon(AppIcons.food), findsNWidgets(3)); //scroll+card+popup
        expect(
            find.text(WidgetHomeUtils.user2["name"] as String), findsOneWidget);

        ///join group
        await tester.tap(find.text("join"));
        await pumpEventQueue(times: 20);
        // expect(find.text("no event found"), findsOneWidget);
      });
    });
    testWidgets('go through all notifications popups',
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
                child: MultiBlocProvider(providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<UserBloc>.value(value: userBloc),
                ], child: const MaterialApp(home: HomePage())),
              );
            },
          ),
        );
        expect(find.byType(ExplorePage), findsOneWidget);
        expect(find.byType(BottomWhiteNavBar), findsOneWidget);

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///click bell on events page
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.bellOutline));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.tap(find.byKey(
          const Key("close-popup"),
        ));
        await tester.pumpAndSettle();

        ///click bell on explore page
        await tester.tap(find.byKey(const Key("go-to-explore-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.bellOutline));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
        await tester.pumpAndSettle();

        ///click bell on groups page
        await tester.tap(find.byKey(const Key("go-to-groups-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.bellOutline));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
        await tester.pumpAndSettle();
      });
    });
    testWidgets('delete/join/leave event', (WidgetTester tester) async {
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
                child: MultiBlocProvider(providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<UserBloc>.value(value: userBloc),
                ], child: const MaterialApp(home: HomePage())),
              );
            },
          ),
        );

        /// go to owned event popup
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(EventCard));
        await tester.pumpAndSettle();
        await tester.tap(find.text(
          WidgetHomeUtils.event1["name"] as String,
        ));
        await tester.pumpAndSettle();

        ///scroll down to delete button
        var listFinder = find.byType(SingleChildScrollView).first;
        var itemFinder = find.text("delete");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        ///delete event
        await tester.tap(find.text("delete"));
        await tester.pumpAndSettle();
        // await pumpEventQueue(times: 20);

        ///move to explore page and open the event
        await tester.tap(find.byKey(const Key("go-to-explore-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ExploreEventCard));
        await tester.pumpAndSettle();

        ///scroll down and join the event
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("join");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.text("join"));
        await tester.pumpAndSettle();

        ///go back to event page and leave the joined event
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(EventCard));
        await tester.pumpAndSettle();
        await tester.tap(find.text(
          WidgetHomeUtils.event2["name"] as String,
        ));
        await tester.pumpAndSettle();

        ///scroll down to leave button and leave
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("leave");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.text("leave"));
        await tester.pumpAndSettle();
      });
    });
    testWidgets('delete/join/leave group', (WidgetTester tester) async {
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
                child: MultiBlocProvider(providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<UserBloc>.value(value: userBloc),
                ], child: const MaterialApp(home: HomePage())),
              );
            },
          ),
        );

        /// go to owned group popup
        await tester.tap(find.byKey(const Key("go-to-groups-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GroupCard));
        await tester.pumpAndSettle();
        await tester.tap(find.text(
          WidgetHomeUtils.group1["name"] as String,
        ));
        await tester.pumpAndSettle();

        ///scroll down to delete button
        var listFinder = find.byType(SingleChildScrollView).first;
        var itemFinder = find.text("delete");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        ///delete group
        await tester.tap(find.text("delete"));
        await tester.pumpAndSettle();
        // await pumpEventQueue(times: 20);

        ///move to explore page switch to group and open the group
        await tester.tap(find.byKey(const Key("go-to-explore-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("drop-down")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("select-groups")).last);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ExploreGroupCard));
        await tester.pumpAndSettle();

        ///scroll down and join the group
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("join");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.text("join"));
        await tester.pumpAndSettle();

        ///go back to group page and leave the joined group
        await tester.tap(find.byKey(const Key("go-to-groups-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GroupCard));
        await tester.pumpAndSettle();
        await tester.tap(find.text(
          WidgetHomeUtils.group2["name"] as String,
        ));
        await tester.pumpAndSettle();

        ///scroll down to leave button and leave
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("leave");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.text("leave"));
        await tester.pumpAndSettle();
      });
    });
  });
  group("Big Tests Tablet", () {
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
      when(() => userBloc.getInterestedUsersToNotify(
              newGroupEventInterests: any(named: "newGroupEventInterests")))
          .thenAnswer((_) async => []);
    });
    testWidgets('go through all Tablet events LandScape screens',
        (WidgetTester tester) async {
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
                  child: MultiBlocProvider(providers: [
                    BlocProvider<AppBloc>.value(value: appBloc),
                    BlocProvider<UserBloc>.value(value: userBloc),
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
        expect(find.byType(ExploreTabletPage), findsOneWidget);
        expect(find.byType(BottomTabletNavBar), findsOneWidget);
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();

        ///check that the user event has been loaded
        expect(find.byType(EventsTabletPage), findsOneWidget);
        expect(find.byType(EventTabletCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.event1["name"] as String),
            findsOneWidget);

        ///click on the event and check message is present
        await tester.tap(find.byType(EventTabletCard));
        await tester.pumpAndSettle();
        expect(find.byType(ChatTabletPopup), findsOneWidget);
        expect(find.text(WidgetHomeUtils.messageEvent1["text"] as String),
            findsOneWidget);

        ///expect top bar and message to display user name
        expect(
            find.text(WidgetHomeUtils.user1["name"] as String),
            findsNWidgets(
                1)); //bacause 2 memebrs the top one is followed by, and is not found

        ///open event info
        await tester.tap(find.byKey(
          const Key("chat-title"),
        ));
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        expect(find.byIcon(AppIcons.sport), findsOneWidget);

        ///press modify
        await tester.tap(find.byIcon(AppIcons.edit2Outline));
        await tester.pumpAndSettle();
        expect(find.byType(ModifyEventPopup), findsOneWidget);
        await tester.enterText(find.byType(TextField).first, "new Name");
        await tester.enterText(find.byType(TextField).last, "new Caption");
        await tester.tap(find.byIcon(AppIcons.privateOutlined));
        await tester.pumpAndSettle();

        ///scroll down to done button
        var listFinder = find.byType(SingleChildScrollView).first;
        var itemFinder = find.text("done");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byIcon(AppIcons.food));
        await tester.tap(find.text("done"));
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        expect(find.text("new Name"), findsOneWidget);
        expect(find.text("new Caption"), findsOneWidget);
        expect(find.byIcon(AppIcons.food), findsOneWidget);

        ///go back to events page
        await tester.tap(find.byKey(const Key("go-to-explore-page")).last,
            warnIfMissed:
                false); //tap on chat arrow whic is outside and triggers a tap outside of popup type event
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("go-to-explore-page")),
            warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(EventsTabletPage), findsOneWidget);

        ///create new event
        await tester.tap(find.byIcon(AppIcons.plusCircleOutline));
        await tester.pumpAndSettle();
        expect(find.byType(AddEventPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.edit2Outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text("Done"));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, "new event Name");
        await tester.enterText(
            find.byType(TextField).last, "new event description");
        await tester.tap(find.byIcon(AppIcons.publicOutlined));
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("done");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        ///click some of the options present in the bottom half
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.sport));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CircleAvatar).last);
        await tester.pumpAndSettle();

        ///check that done can be pressed and press it
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        expect(find.byKey(const Key("activeDone")), findsOneWidget);
        await tester.tap(find.byKey(const Key("activeDone")));
        await tester.pumpAndSettle();
        pumpEventQueue(times: 20);

        expect(find.byType(EventsTabletPage), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    testWidgets('go through all Tablet events Portrait screens',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 0.9;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 0.9),
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
        expect(find.byType(ExploreTabletPage), findsOneWidget);
        expect(find.byType(BottomTabletNavBar), findsOneWidget);
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();

        ///check that the user event has been loaded
        expect(find.byType(EventsTabletPage), findsOneWidget);
        expect(find.byType(EventTabletCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.event1["name"] as String),
            findsOneWidget);

        ///click on the event and check message is present
        await tester.tap(find.byType(EventTabletCard));
        await tester.pumpAndSettle();
        expect(find.byType(ChatTabletPopup), findsOneWidget);
        expect(find.text(WidgetHomeUtils.messageEvent1["text"] as String),
            findsOneWidget);

        ///expect top bar and message to display user name
        expect(
            find.text(WidgetHomeUtils.user1["name"] as String),
            findsNWidgets(
                1)); //bacause 2 memebrs the top one is followed by, and is not found

        ///open event info
        await tester.tap(find.byKey(
          const Key("chat-title"),
        ));
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        expect(find.byIcon(AppIcons.sport), findsOneWidget);

        ///press modify
        await tester.tap(find.byIcon(AppIcons.edit2Outline));
        await tester.pumpAndSettle();
        expect(find.byType(ModifyEventPopup), findsOneWidget);
        await tester.enterText(find.byType(TextField).first, "new Name");
        await tester.enterText(find.byType(TextField).last, "new Caption");
        await tester.tap(find.byIcon(AppIcons.privateOutlined));
        await tester.pumpAndSettle();

        ///scroll down to done button
        var listFinder = find.byType(SingleChildScrollView).first;
        var itemFinder = find.text("done");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byIcon(AppIcons.food));
        await tester.tap(find.text("done"));
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);
        expect(find.text("new Name"), findsOneWidget);
        expect(find.text("new Caption"), findsOneWidget);
        expect(find.byIcon(AppIcons.food), findsOneWidget);

        ///go back to events page
        await tester.tap(find.byKey(const Key("go-to-explore-page")),
            warnIfMissed:
                false); //tap on chat arrow whic is outside and triggers a tap outside of popup type event
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("go-to-explore-page")),
            warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(EventsTabletPage), findsOneWidget);

        ///create new event
        await tester.tap(find.byIcon(AppIcons.plusCircleOutline));
        await tester.pumpAndSettle();
        expect(find.byType(AddEventPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.edit2Outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text("Done"));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, "new event Name");
        await tester.enterText(
            find.byType(TextField).last, "new event description");
        await tester.tap(find.byIcon(AppIcons.publicOutlined));
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("done");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        ///click some of the options present in the bottom half
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.sport));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CircleAvatar).last);
        await tester.pumpAndSettle();

        ///check that done can be pressed and press it
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        expect(find.byKey(const Key("activeDone")), findsOneWidget);
        await tester.tap(find.byKey(const Key("activeDone")));
        await tester.pumpAndSettle();
        pumpEventQueue(times: 20);

        expect(find.byType(EventsTabletPage), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    testWidgets('go through all Tablet groups screens',
        (WidgetTester tester) async {
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
                  child: MultiBlocProvider(providers: [
                    BlocProvider<AppBloc>.value(value: appBloc),
                    BlocProvider<UserBloc>.value(value: userBloc),
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
        expect(find.byType(ExploreTabletPage), findsOneWidget);
        expect(find.byType(BottomTabletNavBar), findsOneWidget);
        await tester.tap(find.byKey(const Key("go-to-groups-page")));
        await tester.pumpAndSettle();

        ///check that the user group has been loaded
        expect(find.byType(GroupsTabletPage), findsOneWidget);
        expect(find.byType(GroupTabletCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.group1["name"] as String),
            findsOneWidget);

        ///click on the group and check message is present
        await tester.tap(find.byType(GroupTabletCard));
        await tester.pumpAndSettle();
        expect(find.byType(ChatTabletPopup), findsOneWidget);
        expect(find.text(WidgetHomeUtils.messageEvent1["text"] as String),
            findsOneWidget);

        ///expect top bar and message to display user name
        expect(
            find.text(WidgetHomeUtils.user1["name"] as String),
            findsNWidgets(
                1)); //1 because in top part name is followed by comma with no space

        ///open group info
        await tester.tap(find.byKey(
          const Key("chat-title"),
        ));
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
        expect(find.byIcon(AppIcons.food), findsOneWidget);
        expect(find.byIcon(AppIcons.music), findsOneWidget);

        ///press modify
        await tester.tap(find.byIcon(AppIcons.edit2Outline));
        await tester.pumpAndSettle();
        expect(find.byType(ModifyGroupPopup), findsOneWidget);
        await tester.enterText(find.byType(TextField).first, "new Name");
        await tester.enterText(find.byType(TextField).last, "new Caption");
        await tester.pumpAndSettle();

        ///add member popup and still active done
        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const Key("search-user-bar")), "user2");
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("add-user-selector")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("done-add-button")));
        await tester.pumpAndSettle();

        ///remove member popup and still active done
        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const Key("search-user-bar")), "user2");
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("add-user-selector")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("done-add-button")));
        await tester.pumpAndSettle();

        ///open again just to close by arrow

        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.arrowIosDownOutline));
        await tester.pumpAndSettle();

        ///add one member again
        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const Key("search-user-bar")), "user2");
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("add-user-selector")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("done-add-button")));
        await tester.pumpAndSettle();

        /// go down to done button
        var listFinder = find.byType(SingleChildScrollView).first;
        var itemFinder = find.text("done");
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.byIcon(AppIcons.privateOutlined));
        await tester.tap(find.byIcon(AppIcons.culture));
        await tester.tap(find.text("done"));
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);
        expect(find.text("new Name"), findsOneWidget);
        expect(find.text("new Caption"), findsNWidgets(2));
        expect(find.byIcon(AppIcons.culture), findsOneWidget);

        ///go back to groups page
        await tester.tap(find.byKey(const Key("go-to-events-page")),
            warnIfMissed: false);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("go-to-events-page")),
            warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(GroupsTabletPage), findsOneWidget);

        ///create new group
        await tester.tap(find.byIcon(AppIcons.plusCircleOutline));
        await tester.pumpAndSettle();
        expect(find.byType(AddGroupPopup), findsOneWidget);
        // await tester.tap(find.byIcon(AppIcons.edit2Outline));
        // await tester.pumpAndSettle();
        // await tester.tap(find.text("Done"));
        // await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, "new group Name");
        await tester.enterText(
            find.byType(TextField).last, "new group description");
        await tester.pumpAndSettle();

        ///add one member again
        await tester.tap(find.byKey(const Key("add-member-button")));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byKey(const Key("search-user-bar")), "user2");
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("add-user-selector")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("done-add-button")));
        await tester.pumpAndSettle();

        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("done");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        ///click some of the options present in the bottom half
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.publicOutlined));
        await tester.tap(find.byIcon(AppIcons.sport));
        await tester.tap(find.byIcon(AppIcons.culture));
        await tester.pumpAndSettle();

        ///check that done can be pressed and press it
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        expect(find.byKey(const Key("activeDone")), findsOneWidget);
        await tester.tap(find.byKey(const Key("activeDone")));
        await tester.pumpAndSettle();
        pumpEventQueue(times: 20);

        expect(find.byType(GroupsTabletPage), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    testWidgets('go through all Tablet Landscape explore screens event side',
        (WidgetTester tester) async {
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
                  child: MultiBlocProvider(providers: [
                    BlocProvider<AppBloc>.value(value: appBloc),
                    BlocProvider<UserBloc>.value(value: userBloc),
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
        expect(find.byType(ExploreTabletPage), findsOneWidget);
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///check that the user not joined event has been loaded
        expect(find.byType(ExploreTabletEventCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.event2["name"] as String),
            findsOneWidget);

        ///click on the event and check content
        await tester.tap(find.byType(ExploreTabletEventCard));
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);

        ///it's a popup so below is considered as well, find the creator in participants
        expect(find.byIcon(AppIcons.food), findsNWidgets(2)); //scroll+popup
        expect(
            find.text(WidgetHomeUtils.user2["name"] as String), findsOneWidget);
        expect(find.text(WidgetHomeUtils.event2["locationName"] as String),
            findsOneWidget);

        /// check members profile (user2) and go back
        expect(find.byType(CircleAvatar), findsOneWidget);
        await tester.tap(find.byType(CircleAvatar));
        await tester.pumpAndSettle();
        expect(find.byType(UserInfo), findsOneWidget);
        expect(find.text(WidgetHomeUtils.user2["description"] as String),
            findsOneWidget);
        await tester.tap(find.byKey(const Key("user-info-bacl-button")));
        await tester.pumpAndSettle();

        ///join event
        await tester.tap(find.text("join"));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("go-to-explore-page")));
        await tester.pumpAndSettle();
        // expect(find.text("no event found"), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    testWidgets('go through all Tablet Portrait explore screens event side',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 0.9;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 0.9),
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
        expect(find.byType(ExploreTabletPage), findsOneWidget);
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///check that the user not joined event has been loaded
        expect(find.byType(ExploreTabletEventCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.event2["name"] as String),
            findsOneWidget);

        ///click on the event and check content
        await tester.tap(find.byType(ExploreTabletEventCard));
        await tester.pumpAndSettle();
        expect(find.byType(SingleEventPopup), findsOneWidget);

        ///it's a popup so below is considered as well, find the creator in participants
        expect(find.byIcon(AppIcons.food), findsNWidgets(2)); //scroll+popup
        expect(
            find.text(WidgetHomeUtils.user2["name"] as String), findsOneWidget);
        expect(find.text(WidgetHomeUtils.event2["locationName"] as String),
            findsOneWidget);

        /// check members profile (user2) and go back
        expect(find.byType(CircleAvatar), findsOneWidget);
        await tester.tap(find.byType(CircleAvatar));
        await tester.pumpAndSettle();
        expect(find.byType(UserInfo), findsOneWidget);
        expect(find.text(WidgetHomeUtils.user2["description"] as String),
            findsOneWidget);
        await tester.tap(find.byKey(const Key("user-info-bacl-button")));
        await tester.pumpAndSettle();

        ///join event
        await tester.tap(find.text("join"));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("go-to-explore-page")));
        await tester.pumpAndSettle();
        // expect(find.text("no event found"), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    testWidgets('go through all Tablet Landscape explore screens group side',
        (WidgetTester tester) async {
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
                  child: MultiBlocProvider(providers: [
                    BlocProvider<AppBloc>.value(value: appBloc),
                    BlocProvider<UserBloc>.value(value: userBloc),
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
        expect(find.byType(ExploreTabletPage), findsOneWidget);
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///move to explore group section
        await tester.tap(find.byKey(const Key("drop-down")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("select-groups")).last);
        await tester.pumpAndSettle();

        ///check that the user not joined group has been loaded
        expect(find.byType(ExploreTabletGroupCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.group2["name"] as String),
            findsOneWidget);

        ///click on the group and check content
        await tester.tap(find.byType(ExploreTabletGroupCard));
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);

        ///it's a popup so below is considered as well, find the creator in participants
        expect(
            find.byIcon(AppIcons.food), findsNWidgets(3)); //scroll+card+popup
        expect(
            find.text(WidgetHomeUtils.user2["name"] as String), findsOneWidget);

        ///join group
        await tester.tap(find.text("join"));
        await pumpEventQueue(times: 20);
        // expect(find.text("no event found"), findsOneWidget);
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    testWidgets('go through all Tablet Portrait explore screens group side',
        (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.binding.window.physicalSizeTestValue = tabletPortraitSize;
        tester.binding.window.devicePixelRatioTestValue = 0.9;
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
                size: tabletPortraitSize, devicePixelRatio: 0.9),
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
        expect(find.byType(ExploreTabletPage), findsOneWidget);
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///move to explore group section
        await tester.tap(find.byKey(const Key("drop-down")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("select-groups")).last);
        await tester.pumpAndSettle();

        ///check that the user not joined group has been loaded
        expect(find.byType(ExploreTabletGroupCard), findsOneWidget);
        expect(find.text(WidgetHomeUtils.group2["name"] as String),
            findsOneWidget);

        ///click on the group and check content
        await tester.tap(find.byType(ExploreTabletGroupCard));
        await tester.pumpAndSettle();
        expect(find.byType(SingleGroupPopup), findsOneWidget);

        ///it's a popup so below is considered as well, find the creator in participants
        expect(
            find.byIcon(AppIcons.food), findsNWidgets(3)); //scroll+card+popup
        expect(
            find.text(WidgetHomeUtils.user2["name"] as String), findsOneWidget);

        ///join group
        await tester.tap(find.text("join"));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("go-to-explore-page")));
        await tester.pumpAndSettle();
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    testWidgets('go through all Tablet notifications popups',
        (WidgetTester tester) async {
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
                  child: MultiBlocProvider(providers: [
                    BlocProvider<AppBloc>.value(value: appBloc),
                    BlocProvider<UserBloc>.value(value: userBloc),
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
        expect(find.byType(ExploreTabletPage), findsOneWidget);
        expect(find.byType(BottomTabletNavBar), findsOneWidget);

        ///give time to load
        for (int i = 0; i < 5; i++) {
          // because pumpAndSettle doesn't work
          await tester.pump(const Duration(seconds: 1));
        }

        ///click bell on events page
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.bellOutline));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline),
            warnIfMissed: false);
        await tester.pumpAndSettle();

        ///click bell on explore page
        await tester.tap(find.byKey(const Key("go-to-explore-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.bellOutline));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.tap(find.byKey(const Key("go-to-events-page")),
            warnIfMissed: false);
        await tester.pumpAndSettle();

        ///click bell on groups page
        await tester.tap(find.byKey(const Key("go-to-groups-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AppIcons.bellOutline));
        await tester.pumpAndSettle();
        expect(find.byType(NotificationsPopup), findsOneWidget);
        await tester.tap(find.byKey(const Key("go-to-events-page")),
            warnIfMissed: false);
        await tester.pumpAndSettle();
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    testWidgets('delete/join/leave Tablet event', (WidgetTester tester) async {
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
                  child: MultiBlocProvider(providers: [
                    BlocProvider<AppBloc>.value(value: appBloc),
                    BlocProvider<UserBloc>.value(value: userBloc),
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

        /// go to owned event popup
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(EventTabletCard));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(
          const Key("chat-title"),
        ));
        await tester.pumpAndSettle();

        ///scroll down to delete button
        var listFinder = find.byType(SingleChildScrollView).first;
        var itemFinder = find.text("delete");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        ///delete event
        await tester.tap(find.text("delete"));
        await tester.pumpAndSettle();
        // await pumpEventQueue(times: 20);

        ///move to explore page and open the event
        await tester.tap(find.byKey(const Key("go-to-explore-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ExploreTabletEventCard));
        await tester.pumpAndSettle();

        ///scroll down and join the event
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("join");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.text("join"));
        await tester.pumpAndSettle();

        ///go back to event page and leave the joined event
        await tester.tap(find.byKey(const Key("go-to-events-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(EventTabletCard));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(
          const Key("chat-title"),
        ));
        await tester.pumpAndSettle();

        ///scroll down to leave button and leave
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("leave");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.text("leave"));
        await tester.pumpAndSettle();
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
    testWidgets('delete/join/leave Tablet group', (WidgetTester tester) async {
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
                  child: MultiBlocProvider(providers: [
                    BlocProvider<AppBloc>.value(value: appBloc),
                    BlocProvider<UserBloc>.value(value: userBloc),
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

        /// go to owned group popup
        await tester.tap(find.byKey(const Key("go-to-groups-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GroupTabletCard));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(
          const Key("chat-title"),
        ));
        await tester.pumpAndSettle();

        ///scroll down to delete button
        var listFinder = find.byType(SingleChildScrollView).first;
        var itemFinder = find.text("delete");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );

        ///delete group
        await tester.tap(find.text("delete"));
        await tester.pumpAndSettle();
        // await pumpEventQueue(times: 20);

        ///move to explore page switch to group and open the group
        await tester.tap(find.byKey(const Key("go-to-explore-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("drop-down")));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key("select-groups")).last);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ExploreTabletGroupCard));
        await tester.pumpAndSettle();

        ///scroll down and join the group
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("join");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.text("join"));
        await tester.pumpAndSettle();

        ///go back to group page and leave the joined group
        await tester.tap(find.byKey(const Key("go-to-groups-page")));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GroupTabletCard));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(
          const Key("chat-title"),
        ));
        await tester.pumpAndSettle();

        ///scroll down to leave button and leave
        listFinder = find.byType(SingleChildScrollView).first;
        itemFinder = find.text("leave");
        // Scroll until the item to be found appears.
        await tester.dragUntilVisible(
          itemFinder,
          listFinder,
          const Offset(0, -500),
        );
        await tester.tap(find.text("leave"));
        await tester.pumpAndSettle();
      });
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
