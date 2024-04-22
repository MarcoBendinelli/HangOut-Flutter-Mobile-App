import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/cubits/notification/notification_cubit.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class MockuserRepository extends Mock implements UserRepository {}

class MockNotification extends Mock implements OurNotification {}

class MockUserData extends Mock implements UserData {}

void main() {
  group('notifications_cubit', () {
    late NotificationsRepository notificationsRepository;
    late UserRepository userRepository;
    late UserData userMock;
    const String id = "id";

    setUp(() {
      notificationsRepository = MockNotificationsRepository();
      userRepository = MockuserRepository();
      userMock = MockUserData();
      registerFallbackValue(OurNotification(
          notificationId: 'notificationId',
          userIds: ['id'],
          thingToOpenId: 'thingToOpenId',
          thingToNotifyName: 'thingToNotifyName',
          sourceName: 'sourceName',
          dateHour: 'dateHour',
          timestamp: 123,
          chatMessage: 'chatMessage',
          eventCategory: 'eventCategory',
          public: false));
    });

    test('initial state is initial', () {
      expect(
          NotificationCubit(
                  notificationsRepository: notificationsRepository,
                  userRepository: userRepository)
              .state
              .status,
          NotificationStatus.initial);
    });

    // Add notificaion error
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
                idUser: any(named: 'idUser'),
                idNotification: any(named: 'idNotification')))
            .thenAnswer((_) async => {});
        when(() => notificationsRepository.addNewNotification(
            notification: any(named: 'notification'))).thenThrow(Error());
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) => cubit.addNewNotification(
          public: false,
          userIdsToNotify: [id],
          sourceName: "sourceName",
          thingToOpenId: "thingToOpenId",
          thingToNotifyName: "thingToNotifyName",
          dateHour: "dateHour",
          timestamp: 123,
          chatMessage: "message",
          eventCategory: "category",
          notificationsEventChat: true),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.error),
      ],
    );

    // Delete notification error
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
            idUser: any(named: 'idUser'),
            idNotification: any(named: 'idNotification'))).thenThrow(Error());
        when(() => notificationsRepository.addNewNotification(
                notification: any(named: 'notification')))
            .thenAnswer((_) async => {});
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) =>
          cubit.deleteNotification(currentUserId: id, idNotification: ''),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.error),
      ],
    );

    // Delete notification
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
                idUser: any(named: 'idUser'),
                idNotification: any(named: 'idNotification')))
            .thenAnswer((_) async => {});
        when(() => notificationsRepository.addNewNotification(
                notification: any(named: 'notification')))
            .thenAnswer((_) async => {});
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) =>
          cubit.deleteNotification(currentUserId: id, idNotification: ''),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success),
      ],
    );

    // Notification sent for a new event message
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
                idUser: any(named: 'idUser'),
                idNotification: any(named: 'idNotification')))
            .thenAnswer((_) async => {});
        when(() => notificationsRepository.addNewNotification(
                notification: any(named: 'notification')))
            .thenAnswer((_) async => {});
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) => cubit.addNewNotification(
          public: false,
          userIdsToNotify: [id],
          sourceName: "sourceName",
          thingToOpenId: "thingToOpenId",
          thingToNotifyName: "thingToNotifyName",
          dateHour: "dateHour",
          timestamp: 123,
          chatMessage: "message",
          eventCategory: "category",
          notificationsEventChat: true),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success),
      ],
    );

    // Notification sent for a new group message
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
                idUser: any(named: 'idUser'),
                idNotification: any(named: 'idNotification')))
            .thenAnswer((_) async => {});
        when(() => notificationsRepository.addNewNotification(
                notification: any(named: 'notification')))
            .thenAnswer((_) async => {});
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) => cubit.addNewNotification(
          public: false,
          userIdsToNotify: [id],
          sourceName: "sourceName",
          chatMessage: "message",
          thingToOpenId: "thingToOpenId",
          thingToNotifyName: "thingToNotifyName",
          dateHour: "dateHour",
          timestamp: 123,
          notificationsGroupChat: true),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success),
      ],
    );

    // Notification sent for a new group
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
                idUser: any(named: 'idUser'),
                idNotification: any(named: 'idNotification')))
            .thenAnswer((_) async => {});
        when(() => notificationsRepository.addNewNotification(
                notification: any(named: 'notification')))
            .thenAnswer((_) async => {});
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) => cubit.addNewNotification(
        public: false,
        userIdsToNotify: [id],
        sourceName: "sourceName",
        thingToOpenId: "thingToOpenId",
        thingToNotifyName: "thingToNotifyName",
        dateHour: "dateHour",
        timestamp: 123,
        notificationsJoinGroup: true,
      ),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success),
      ],
    );

    // Notification sent for a new event
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
                idUser: any(named: 'idUser'),
                idNotification: any(named: 'idNotification')))
            .thenAnswer((_) async => {});
        when(() => notificationsRepository.addNewNotification(
                notification: any(named: 'notification')))
            .thenAnswer((_) async => {});
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) => cubit.addNewNotification(
          public: false,
          userIdsToNotify: [id],
          sourceName: "sourceName",
          thingToOpenId: "thingToOpenId",
          eventCategory: "category",
          thingToNotifyName: "thingToNotifyName",
          dateHour: "dateHour",
          timestamp: 123,
          notificationsInviteEvent: true),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success),
      ],
    );

    // Notification sent for a new public event
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
                idUser: any(named: 'idUser'),
                idNotification: any(named: 'idNotification')))
            .thenAnswer((_) async => {});
        when(() => notificationsRepository.addNewNotification(
                notification: any(named: 'notification')))
            .thenAnswer((_) async => {});
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) => cubit.addNewNotification(
          public: false,
          userIdsToNotify: [id],
          sourceName: "sourceName",
          thingToOpenId: "thingToOpenId",
          thingToNotifyName: "thingToNotifyName",
          eventCategory: "category",
          dateHour: "dateHour",
          timestamp: 123,
          notificationsPublicEvent: true),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success),
      ],
    );

    // Notification sent for a new public group
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
                idUser: any(named: 'idUser'),
                idNotification: any(named: 'idNotification')))
            .thenAnswer((_) async => {});
        when(() => notificationsRepository.addNewNotification(
                notification: any(named: 'notification')))
            .thenAnswer((_) async => {});
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) => cubit.addNewNotification(
          public: false,
          userIdsToNotify: [id],
          sourceName: "sourceName",
          thingToOpenId: "thingToOpenId",
          thingToNotifyName: "thingToNotifyName",
          dateHour: "dateHour",
          timestamp: 123,
          notificationsPublicGroup: true),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success),
      ],
    );

    // New notification with empty ids list
    blocTest<NotificationCubit, NotificationState>(
      'emits [success] when add [newOurNotification] is with success',
      setUp: () {
        when(() => notificationsRepository.removeUserFromNotification(
                idUser: any(named: 'idUser'),
                idNotification: any(named: 'idNotification')))
            .thenAnswer((_) async => {});
        when(() => notificationsRepository.addNewNotification(
                notification: any(named: 'notification')))
            .thenAnswer((_) async => {});
        when(() => userRepository.getUserData(id))
            .thenAnswer((_) async => userMock);
        when(() => userMock.notificationsEventChat).thenReturn(true);
        when(() => userMock.notificationsGroupChat).thenReturn(true);
        when(() => userMock.notificationsInviteEvent).thenReturn(true);
        when(() => userMock.notificationsJoinGroup).thenReturn(true);
        when(() => userMock.notificationsPublicEvent).thenReturn(true);
        when(() => userMock.notificationsPublicGroup).thenReturn(true);
        when(() => userMock.notificationsPush).thenReturn(true);
      },
      build: () => NotificationCubit(
          notificationsRepository: notificationsRepository,
          userRepository: userRepository),
      act: (cubit) => cubit.addNewNotification(
          public: false,
          userIdsToNotify: [],
          sourceName: "sourceName",
          thingToOpenId: "thingToOpenId",
          thingToNotifyName: "thingToNotifyName",
          dateHour: "dateHour",
          timestamp: 123,
          chatMessage: "message",
          eventCategory: "category",
          notificationsEventChat: true),
      expect: () => const <NotificationState>[
        NotificationState(status: NotificationStatus.loading),
        NotificationState(status: NotificationStatus.success),
      ],
    );
  });
}
