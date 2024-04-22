import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/services/notification_service.dart';
import 'package:hang_out_app/presentation/login/login_page.dart';
import 'package:hang_out_app/presentation/pages/events/add_event_popup.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/event_card.dart';
import 'package:hang_out_app/presentation/pages/events/events_page.dart';
import 'package:hang_out_app/presentation/pages/explore/event_card/explore_event_card.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_page.dart';
import 'package:hang_out_app/presentation/pages/explore/group_card/explore_group_card.dart';
import 'package:hang_out_app/presentation/pages/groups/add_group_popup.dart';
import 'package:hang_out_app/presentation/pages/groups/group_card/group_card.dart';
import 'package:hang_out_app/presentation/pages/groups/groups_page.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/popups/modify_group_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hang_out_app/main.dart' as app;
import 'package:flutter/material.dart';

const loginButtonKey = Key('loginForm_continue_raisedButton');
const signInWithGoogleButtonKey = Key('loginForm_googleLogin_raisedButton');
const createAccountButtonKey = Key('loginForm_createAccount_flatButton');
const signUpButtonKey = Key('signUpForm_continue_raisedButton');
const signUpEmailInputKey = Key('signUpForm_emailInput_textField');

const logInEmailInputKey = Key('loginForm_emailInput_textField');
const logInPasswordInputKey = Key('loginForm_passwordInput_textField');
const nameInputKey = Key('signUpForm_nameInput_textField');
const photoInputKey = Key('signUpForm_photoInput_button');
const signUpPasswordInputKey = Key('signUpForm_passwordInput_textField');
const confirmedPasswordInputKey =
    Key('signUpForm_confirmedPasswordInput_textField');
const String eventName = "EventName";
const String eventName2 = "EventName2";
const String groupName = "GroupName";
const String groupName2 = "GroupName2";
const String mainEmail = "test@test.it";
const String mainPassword = "password";
const String secondEmail = "test@test.org";
const String secondPassword = "password";

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  NotificationService.isTest = true;

  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    "end to end testing",
    (tester) async {
      await app.main(useFirestoreEmulator: true);
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();

      await createAccount(tester, binding, main: true);
      await tester.pumpAndSettle();

      await createEvent(tester, binding);
      await tester.pumpAndSettle();

      await writeMessageInEvent(tester, binding);
      await tester.pumpAndSettle();
      await editEvent(tester, binding);
      await tester.pumpAndSettle();
      await createGroup(tester, binding);
      await tester.pumpAndSettle();
      await writeMessageInGroup(tester, binding);
      await tester.pumpAndSettle();
      await editGroup(tester, binding);
      await tester.pumpAndSettle();
      await logOut(tester, binding);
      await tester.pumpAndSettle();
      await createAccount(tester, binding, main: false);
      await tester.pumpAndSettle();
      await joinEvent(tester, binding);
      await tester.pumpAndSettle();
      await joinGroup(tester, binding);
      await tester.pumpAndSettle();
      await leaveEvent(tester, binding);
      await tester.pumpAndSettle();
      await leaveGroup(tester, binding);
      await tester.pumpAndSettle();
      await logOut(tester, binding);
      await tester.pumpAndSettle();
      await logIn(tester, binding, main: true);
      await tester.pumpAndSettle();
      await deleteEvent(tester, binding);
      await tester.pumpAndSettle();
      await deleteGroup(tester, binding);
      await tester.pumpAndSettle();
      await deleteAccount(tester, binding);
      await tester.pumpAndSettle();
      await logIn(tester, binding, main: false);
      await tester.pumpAndSettle();
      await deleteAccount(tester, binding);
      await tester.pumpAndSettle();
    },
  );
}

Future<void> createAccount(
    WidgetTester tester, IntegrationTestWidgetsFlutterBinding binding,
    {required bool main}) async {
  debugPrint("create account");
  await tester.tap(find.byKey(createAccountButtonKey));
  await tester.pumpAndSettle();
  await tester.enterText(
      find.byKey(nameInputKey), main ? "MainTester" : "SecondTester");
  await tester.enterText(
      find.byKey(signUpEmailInputKey), main ? mainEmail : secondEmail);
  await tester.enterText(find.byKey(signUpPasswordInputKey), "password");
  await tester.enterText(find.byKey(confirmedPasswordInputKey), "password");
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await binding.takeScreenshot('create');
  await tester.tap(find.byKey(signUpButtonKey));
  await tester.pumpAndSettle();
  await tester.pump();
  await tester.pump(const Duration(seconds: 5));
  await tester.pump(const Duration(seconds: 5));
  await tester.pump();
  expect(find.byType(ExplorePage), findsOneWidget);
}

Future<void> createEvent(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("create event");
  await tester.tap(find.byKey(const Key("go-to-events-page")));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.plusCircleOutline));
  await tester.pumpAndSettle();
  expect(find.byType(AddEventPopup), findsOneWidget);

  ///insert date
  await tester.tap(find.byIcon(AppIcons.edit2Outline));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Done"));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, eventName);
  await tester.enterText(find.byType(TextField).last, "new event description");
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.publicOutlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.privateOutlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.publicOutlined));
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.text("done");
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );

  ///click some of the options present in the bottom half
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.sport));
  // await tester.tap(find.byIcon(AppIcons.globe2Outline));
  await tester.pumpAndSettle();

  ///check that done can be pressed and press it
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  expect(find.byKey(const Key("activeDone")), findsOneWidget);
  await binding.takeScreenshot('events/create');
  await tester.tap(find.byKey(const Key("activeDone")));
  await tester.pumpAndSettle();
  pumpEventQueue(times: 20);
  expect(find.byType(EventCard), findsOneWidget);
  await binding.takeScreenshot('pages/my-events');
}

Future<void> editEvent(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("edit event");

  ///click on the event and check message is present
  await tester.tap(find.byType(EventCard));
  await tester.pumpAndSettle();
  expect(find.byType(ChatView), findsOneWidget);
  expect(find.text(eventName), findsOneWidget);

  //bacause 2 memebrs the top one is followed by, and is not found

  ///open event info
  await tester.tap(find.text(
    eventName,
  ));
  await tester.pumpAndSettle();
  expect(find.byType(SingleEventPopup), findsOneWidget);
  expect(find.byIcon(AppIcons.sport), findsOneWidget);

  ///press modify
  await tester.tap(find.byIcon(AppIcons.edit2Outline));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).first, eventName);
  await tester.enterText(find.byType(TextField).last, "new Caption");
  await tester.testTextInput.receiveAction(TextInputAction.done);
  // await tester.pumpAndSettle();

  // await tester.tap(find.byIcon(AppIcons.publicOutlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.food));

  ///scroll down to done button
  var listFinder = find.byType(SingleChildScrollView).first;
  var itemFinder = find.text("done");
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  await binding.takeScreenshot('events/edit');
  await tester.tap(find.text("done"));
  await tester.pumpAndSettle();
  expect(find.byType(SingleEventPopup), findsOneWidget);
  // expect(find.text(eventName2), findsOneWidget);
  // expect(find.text("new Caption"), findsOneWidget);
  expect(find.byIcon(AppIcons.food), findsOneWidget);

  ///go back to events page
  await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline).last);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
  await tester.pumpAndSettle();
  expect(find.byType(EventsPage), findsOneWidget);
}

Future<void> createGroup(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("create group");
  await tester.tap(find.byKey(const Key("go-to-groups-page")));
  await tester.pumpAndSettle();

  ///create new group
  await tester.tap(find.byIcon(AppIcons.plusCircleOutline));
  await tester.pumpAndSettle();
  expect(find.byType(AddGroupPopup), findsOneWidget);

  await tester.enterText(find.byType(TextField).first, groupName);
  await tester.enterText(find.byType(TextField).last, "new group description");
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  ///add one member again
  await tester.tap(find.byKey(const Key("add-member-button")));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key("done-add-button")));
  await tester.pumpAndSettle();

  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.text("done");
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );

  ///click some of the options present in the bottom half
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.publicOutlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.privateOutlined));
  await tester.tap(find.byIcon(AppIcons.sport));
  await tester.tap(find.byIcon(AppIcons.culture));
  await tester.pumpAndSettle();

  ///check that done can be pressed and press it
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  await binding.takeScreenshot('groups/create');
  expect(find.byKey(const Key("activeDone")), findsOneWidget);
  await tester.tap(find.byKey(const Key("activeDone")));
  await tester.pumpAndSettle();
  pumpEventQueue(times: 20);

  expect(find.byType(GroupsPage), findsOneWidget);
  await binding.takeScreenshot('pages/my-groups');
}

Future<void> editGroup(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("edit group");

  ///click on the group and check message is present
  await tester.tap(find.byType(GroupCard));
  await tester.pumpAndSettle();
  expect(find.byType(ChatView), findsOneWidget);
  expect(find.text(groupName), findsOneWidget);

  ///open group info
  await tester.tap(find.text(
    groupName,
  ));
  await tester.pumpAndSettle();
  expect(find.byType(SingleGroupPopup), findsOneWidget);
  expect(find.byIcon(AppIcons.sport), findsOneWidget);
  expect(find.byIcon(AppIcons.culture), findsOneWidget);

  ///press modify
  await tester.tap(find.byIcon(AppIcons.edit2Outline));
  await tester.pumpAndSettle();
  expect(find.byType(ModifyGroupPopup), findsOneWidget);
  await tester.enterText(find.byType(TextField).first, groupName);
  await tester.enterText(find.byType(TextField).last, "new Caption");

  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.publicOutlined));
  await tester.pumpAndSettle();

  ///open add memebr and close by arrow
  await tester.tap(find.byKey(const Key("add-member-button")));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.arrowIosDownOutline));
  await tester.pumpAndSettle();

  /// go down to done button
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.text("done");
  await tester.tap(find.byIcon(AppIcons.food));
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  await binding.takeScreenshot('groups/edit');
  await tester.tap(find.text("done"));
  await tester.pumpAndSettle();
  expect(find.byType(SingleGroupPopup), findsOneWidget);
  // expect(find.text(groupName2), findsOneWidget);
  // expect(find.text("new Caption"), findsOneWidget);

  ///go back to groups page
  await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline).last);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
  await tester.pumpAndSettle();
  expect(find.byType(GroupsPage), findsOneWidget);
}

Future<void> writeMessageInEvent(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("write message in event");
  await tester.tap(find.byType(EventCard));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), "message");
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
  await tester.pumpAndSettle();
  expect(find.text("message"), findsOneWidget);
  await binding.takeScreenshot('events/message');
  await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
  await tester.pumpAndSettle();
  expect(find.byType(EventsPage), findsOneWidget);
}

Future<void> writeMessageInGroup(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("write message in group");
  await tester.tap(find.byType(GroupCard));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), "message");
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.arrowCircleUpOutline));
  await tester.pumpAndSettle();
  expect(find.text("message"), findsOneWidget);
  await binding.takeScreenshot('groups/message');
  await tester.tap(find.byIcon(AppIcons.arrowIosBackOutline));
  await tester.pumpAndSettle();
  expect(find.byType(GroupsPage), findsOneWidget);
}

Future<void> logOut(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("logOut");
  await tester.tap(find.byKey(const Key("go-to-profile-page")));
  await tester.pumpAndSettle();
  await binding.takeScreenshot('pages/profile');
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.byIcon(AppIcons.logOutOutline);
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.logOutOutline));
  await tester.pumpAndSettle();
  expect(find.byType(LoginPage), findsOneWidget);
}

Future<void> joinEvent(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("join event");
  await tester.tap(find.byIcon(AppIcons.food));
  await tester.pumpAndSettle();
  await binding.takeScreenshot('pages/explore-events');
  await tester.tap(find.byType(ExploreEventCard));
  await tester.pumpAndSettle();

  ///scroll down and join the group
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.text("join");
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  await binding.takeScreenshot('events/join');
  await tester.tap(find.text("join"));
  await tester.pumpAndSettle();
}

Future<void> joinGroup(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("create group");
  await tester.tap(find.byIcon(AppIcons.sport));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key("drop-down")));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key("select-groups")).last);
  await tester.pumpAndSettle();
  await binding.takeScreenshot('pages/explore-groups');
  await tester.tap(find.byType(ExploreGroupCard));
  await tester.pumpAndSettle();

  ///scroll down and join the group
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.text("join");
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  await binding.takeScreenshot('groups/join');
  await tester.tap(find.text("join"));
  await tester.pumpAndSettle();
}

Future<void> leaveEvent(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("leave event");
  await tester.tap(find.byKey(const Key("go-to-events-page")));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(EventCard));
  await tester.pumpAndSettle();
  await tester.tap(find.text(
    eventName,
  ));
  await tester.pumpAndSettle();

  ///scroll down to leave button and leave
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.text("leave");
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  await binding.takeScreenshot('events/leave');
  await tester.tap(find.text("leave"));
  await tester.pumpAndSettle();
}

Future<void> leaveGroup(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("leave group");
  await tester.tap(find.byKey(const Key("go-to-groups-page")));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(GroupCard));
  await tester.pumpAndSettle();
  await tester.tap(find.text(
    groupName,
  ));
  await tester.pumpAndSettle();

  ///scroll down to leave button and leave
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.text("leave");
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  await binding.takeScreenshot('groups/leave');
  await tester.tap(find.text("leave"));
  await tester.pumpAndSettle();
}

Future<void> logIn(
    WidgetTester tester, IntegrationTestWidgetsFlutterBinding binding,
    {required bool main}) async {
  debugPrint("logIn");
  await tester.enterText(
      find.byKey(logInEmailInputKey), main ? mainEmail : secondEmail);
  await tester.enterText(
      find.byKey(logInPasswordInputKey), main ? mainPassword : secondPassword);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
  await binding.takeScreenshot('login');
  await tester.tap(find.byKey(loginButtonKey));
  await tester.pumpAndSettle();
}

Future<void> deleteEvent(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("delete event");
  await tester.tap(find.byKey(const Key("go-to-events-page")));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(EventCard));
  await tester.pumpAndSettle();
  await tester.tap(find.text(
    eventName,
  ));
  await tester.pumpAndSettle();

  ///scroll down to delete button
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.text("delete");
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );

  ///delete event
  await tester.tap(find.text("delete"));
  await tester.pumpAndSettle();
}

Future<void> deleteGroup(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("delete group");
  await tester.tap(find.byKey(const Key("go-to-groups-page")));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(GroupCard));
  await tester.pumpAndSettle();
  await tester.tap(find.text(
    groupName,
  ));
  await tester.pumpAndSettle();

  ///scroll down to delete button
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.text("delete");
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );

  ///delete event
  await tester.tap(find.text("delete"));
  await tester.pumpAndSettle();
}

Future<void> deleteAccount(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  debugPrint("delete account");
  await tester.tap(find.byKey(const Key("go-to-profile-page")));
  await tester.pumpAndSettle();
  final listFinder = find.byType(SingleChildScrollView).first;
  final itemFinder = find.byIcon(AppIcons.trashOutline);
  // Scroll until the item to be found appears.
  await tester.dragUntilVisible(
    itemFinder,
    listFinder,
    const Offset(0, -500),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(AppIcons.trashOutline));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Continue"));
  await tester.pumpAndSettle();

  ///give time to delete
  await tester.pump();
  await tester.pump(const Duration(seconds: 5));
  await tester.pump(const Duration(seconds: 5));
  await tester.pump();
}
