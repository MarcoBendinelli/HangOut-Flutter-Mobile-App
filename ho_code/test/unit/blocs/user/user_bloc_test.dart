import 'package:bloc_test/bloc_test.dart';
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
    final Stream<UserData> testUserDataStream = Stream.value(userMock);
    final Stream<UserData> testUserDataStreamError = Stream.error(Error());
    const String userId = "userId";
    late UserRepository userRepository;
    late NotificationService notificationService;

    setUp(() {
      userRepository = MockUserRepository();
      notificationService = MockNotificationService();
    });

    test('initial state is userLoading', () {
      expect(
        UserBloc(
                userRepository: userRepository,
                notificationService: notificationService)
            .state,
        UserLoading(),
      );
    });

    blocTest<UserBloc, UserState>(
      'getUser success',
      setUp: () => when(() => userRepository.getUserDataStream(userId))
          .thenAnswer((_) => testUserDataStream),
      build: () => UserBloc(
          userRepository: userRepository,
          notificationService: notificationService),
      act: (bloc) => bloc.add(const LoadUser(userId: userId)),
      expect: () => [
        UserLoaded(user: userMock),
      ],
      verify: (_) {
        verify(() => userRepository.getUserDataStream(userId)).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'getUser error',
      setUp: () => when(() => userRepository.getUserDataStream(userId))
          .thenAnswer((_) => testUserDataStreamError),
      build: () => UserBloc(
          userRepository: userRepository,
          notificationService: notificationService),
      act: (bloc) => bloc.add(const LoadUser(userId: userId)),
      expect: () => [UserLoadingError()],
      verify: (_) {
        verify(() => userRepository.getUserDataStream(userId)).called(1);
      },
    );
  });
}
