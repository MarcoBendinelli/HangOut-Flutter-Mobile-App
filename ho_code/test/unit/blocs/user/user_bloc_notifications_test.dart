import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/data/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class MockUserData extends Mock implements UserData {}

void main() {
  group('UserBloc', () {
    final userMock = MockUserData();
    const String userId = "userId";
    late UserRepository userRepository;
    late NotificationService notificationService;
    late UserBloc blocToTest;

    setUp(() {
      userRepository = MockUserRepository();
      notificationService = MockNotificationService();
      blocToTest = UserBloc(
          userRepository: userRepository,
          notificationService: notificationService);
    });

    test('Initializaion of notifications', () {
      when(() => notificationService.firstInitialization(userId))
          .thenAnswer((_) async => {});
      blocToTest.initializeNotification(currentUserId: userId);
      verify(() => notificationService.firstInitialization(userId)).called(1);
    });

    test('Get interested users to notify', () async {
      when(() => userRepository.getInterestedUsersToNotify(
          newGroupEventInterests: [])).thenAnswer((_) async => []);

      expect(await blocToTest.getInterestedUsersToNotify(newGroupEventInterests: []),
          []);
      verify(() => userRepository
          .getInterestedUsersToNotify(newGroupEventInterests: [])).called(1);
    });

    test('Set on click notifications functions', () {
      when(() => notificationService.setNotificationsBehaviour(
            onClickGroupNotification: any(named: 'onClickGroupNotification'),
            onClickEventNotification: any(named: 'onClickEventNotification'),
            onClickChatGroupNotification:
                any(named: 'onClickChatGroupNotification'),
            onClickChatEventNotification:
                any(named: 'onClickChatEventNotification'),
            onClickPublicGroupNotification:
                any(named: 'onClickPublicGroupNotification'),
          )).thenAnswer((_) async => {});

      blocToTest.setOnClickNotifications(
          onClickGroupNotification: () {},
          onClickEventNotification: () {},
          onClickChatGroupNotification: () {},
          onClickChatEventNotification: () {},
          onClickPublicGroupNotification: () {});

      verify(() => notificationService.setNotificationsBehaviour(
            onClickGroupNotification: any(named: 'onClickGroupNotification'),
            onClickEventNotification: any(named: 'onClickEventNotification'),
            onClickChatGroupNotification:
                any(named: 'onClickChatGroupNotification'),
            onClickChatEventNotification:
                any(named: 'onClickChatEventNotification'),
            onClickPublicGroupNotification:
                any(named: 'onClickPublicGroupNotification'),
          )).called(1);
    });

    test('Send Push Notification', () async {
      when(() => notificationService.getTokenOfUser(userId))
          .thenAnswer((_) async => ['token']);
      when(() => notificationService.sendPushMessage(
            token: any(named: 'token'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => {});

      await blocToTest.sendPushNotification(
          id: userId, title: 'title', body: 'body');

      verify(() => notificationService.getTokenOfUser(userId)).called(1);
      verify(() => notificationService.sendPushMessage(
            token: any(named: 'token'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).called(1);
    });

    // notificationsEventChat is true
    test('Send Push Notification to Users', () async {
      when(() => notificationService.getTokenOfUser(userId))
          .thenAnswer((_) async => ['token']);
      when(() => notificationService.sendPushMessage(
            token: any(named: 'token'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => {});
      when(() => userRepository.getUserData(userId))
          .thenAnswer((_) async => userMock);

      when(() => userMock.notificationsEventChat).thenReturn(true);
      when(() => userMock.notificationsGroupChat).thenReturn(true);
      when(() => userMock.notificationsInviteEvent).thenReturn(true);
      when(() => userMock.notificationsJoinGroup).thenReturn(true);
      when(() => userMock.notificationsPublicEvent).thenReturn(true);
      when(() => userMock.notificationsPublicGroup).thenReturn(true);
      when(() => userMock.notificationsPush).thenReturn(true);

      await blocToTest.sendPushNotificationsToUsers(
          userIdsToNotify: [userId],
          title: 'title',
          body: 'body',
          notificationsEventChat: true);

      verify(() => notificationService.getTokenOfUser(userId)).called(1);
    });

    // notificationsGroupChat is true
    test('Send Push Notification to Users', () async {
      when(() => notificationService.getTokenOfUser(userId))
          .thenAnswer((_) async => ['token']);
      when(() => notificationService.sendPushMessage(
            token: any(named: 'token'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => {});
      when(() => userRepository.getUserData(userId))
          .thenAnswer((_) async => userMock);

      when(() => userMock.notificationsEventChat).thenReturn(true);
      when(() => userMock.notificationsGroupChat).thenReturn(true);
      when(() => userMock.notificationsInviteEvent).thenReturn(true);
      when(() => userMock.notificationsJoinGroup).thenReturn(true);
      when(() => userMock.notificationsPublicEvent).thenReturn(true);
      when(() => userMock.notificationsPublicGroup).thenReturn(true);
      when(() => userMock.notificationsPush).thenReturn(true);

      await blocToTest.sendPushNotificationsToUsers(
          userIdsToNotify: [userId],
          title: 'title',
          body: 'body',
          notificationsGroupChat: true);

      verify(() => notificationService.getTokenOfUser(userId)).called(1);
    });

    // notificationsInviteEvent is true
    test('Send Push Notification to Users', () async {
      when(() => notificationService.getTokenOfUser(userId))
          .thenAnswer((_) async => ['token']);
      when(() => notificationService.sendPushMessage(
            token: any(named: 'token'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => {});
      when(() => userRepository.getUserData(userId))
          .thenAnswer((_) async => userMock);

      when(() => userMock.notificationsEventChat).thenReturn(true);
      when(() => userMock.notificationsGroupChat).thenReturn(true);
      when(() => userMock.notificationsInviteEvent).thenReturn(true);
      when(() => userMock.notificationsJoinGroup).thenReturn(true);
      when(() => userMock.notificationsPublicEvent).thenReturn(true);
      when(() => userMock.notificationsPublicGroup).thenReturn(true);
      when(() => userMock.notificationsPush).thenReturn(true);

      await blocToTest.sendPushNotificationsToUsers(
          userIdsToNotify: [userId],
          title: 'title',
          body: 'body',
          notificationsInviteEvent: true);

      verify(() => notificationService.getTokenOfUser(userId)).called(1);
    });

    // notificationsJoinGroup is true
    test('Send Push Notification to Users', () async {
      when(() => notificationService.getTokenOfUser(userId))
          .thenAnswer((_) async => ['token']);
      when(() => notificationService.sendPushMessage(
            token: any(named: 'token'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => {});
      when(() => userRepository.getUserData(userId))
          .thenAnswer((_) async => userMock);

      when(() => userMock.notificationsEventChat).thenReturn(true);
      when(() => userMock.notificationsGroupChat).thenReturn(true);
      when(() => userMock.notificationsInviteEvent).thenReturn(true);
      when(() => userMock.notificationsJoinGroup).thenReturn(true);
      when(() => userMock.notificationsPublicEvent).thenReturn(true);
      when(() => userMock.notificationsPublicGroup).thenReturn(true);
      when(() => userMock.notificationsPush).thenReturn(true);

      await blocToTest.sendPushNotificationsToUsers(
          userIdsToNotify: [userId],
          title: 'title',
          body: 'body',
          notificationsJoinGroup: true);

      verify(() => notificationService.getTokenOfUser(userId)).called(1);
    });

    // notificationsPublicEvent is true
    test('Send Push Notification to Users', () async {
      when(() => notificationService.getTokenOfUser(userId))
          .thenAnswer((_) async => ['token']);
      when(() => notificationService.sendPushMessage(
            token: any(named: 'token'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => {});
      when(() => userRepository.getUserData(userId))
          .thenAnswer((_) async => userMock);

      when(() => userMock.notificationsEventChat).thenReturn(true);
      when(() => userMock.notificationsGroupChat).thenReturn(true);
      when(() => userMock.notificationsInviteEvent).thenReturn(true);
      when(() => userMock.notificationsJoinGroup).thenReturn(true);
      when(() => userMock.notificationsPublicEvent).thenReturn(true);
      when(() => userMock.notificationsPublicGroup).thenReturn(true);
      when(() => userMock.notificationsPush).thenReturn(true);

      await blocToTest.sendPushNotificationsToUsers(
          userIdsToNotify: [userId],
          title: 'title',
          body: 'body',
          notificationsPublicEvent: true);

      verify(() => notificationService.getTokenOfUser(userId)).called(1);
    });

    // notificationsPublicGroup is true
    test('Send Push Notification to Users', () async {
      when(() => notificationService.getTokenOfUser(userId))
          .thenAnswer((_) async => ['token']);
      when(() => notificationService.sendPushMessage(
            token: any(named: 'token'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => {});
      when(() => userRepository.getUserData(userId))
          .thenAnswer((_) async => userMock);

      when(() => userMock.notificationsEventChat).thenReturn(true);
      when(() => userMock.notificationsGroupChat).thenReturn(true);
      when(() => userMock.notificationsInviteEvent).thenReturn(true);
      when(() => userMock.notificationsJoinGroup).thenReturn(true);
      when(() => userMock.notificationsPublicEvent).thenReturn(true);
      when(() => userMock.notificationsPublicGroup).thenReturn(true);
      when(() => userMock.notificationsPush).thenReturn(true);

      await blocToTest.sendPushNotificationsToUsers(
          userIdsToNotify: [userId],
          title: 'title',
          body: 'body',
          notificationsPublicGroup: true);

      verify(() => notificationService.getTokenOfUser(userId)).called(1);
    });
  });
}
