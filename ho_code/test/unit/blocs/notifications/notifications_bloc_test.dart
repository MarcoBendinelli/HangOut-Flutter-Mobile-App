import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';
import 'package:hang_out_app/data/models/our_notification.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class MockNotification extends Mock implements OurNotification {}

void main() {
  group('GroupsBloc', () {
    final notificationMock = MockNotification();
    final List<OurNotification> testNotifications = [notificationMock];
    final Stream<List<OurNotification>> testNotificationsStream =
        Stream.value(testNotifications);
    final Stream<List<OurNotification>> testNotificationsStreamError =
        Stream.error(Error());
    const String userId = "userId";
    late NotificationsRepository notificationsRepository;

    setUp(() {
      notificationsRepository = MockNotificationsRepository();
    });

    test('initial state is GroupsLoading', () {
      expect(
        NotificationsBloc(notificationsRepository: notificationsRepository)
            .state,
        NotificationsLoading(),
      );
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'getNotifications success',
      setUp: () => when(() => notificationsRepository.getNotifications(userId))
          .thenAnswer((_) async => testNotificationsStream),
      build: () => NotificationsBloc(
        notificationsRepository: notificationsRepository,
      ),
      act: (bloc) => bloc.add(const LoadNotifications(userId: userId)),
      expect: () => [
        NotificationsLoaded(notifications: testNotifications),
      ],
      verify: (_) {
        verify(() => notificationsRepository.getNotifications(userId))
            .called(1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'getNotifications error',
      setUp: () => when(() => notificationsRepository.getNotifications(userId))
          .thenAnswer(
        (_) async => testNotificationsStreamError,
      ),
      build: () => NotificationsBloc(
        notificationsRepository: notificationsRepository,
      ),
      act: (bloc) => bloc.add(const LoadNotifications(userId: userId)),
      expect: () => [
        NotificationsError(),
      ],
      verify: (_) {
        verify(() => notificationsRepository.getNotifications(userId))
            .called(1);
      },
    );
  });
}
