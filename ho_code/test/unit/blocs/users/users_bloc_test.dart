import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/users/users_bloc.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUser extends Mock implements UserData {}

void main() {
  group('UsersBloc', () {
    final mockUser = MockUser();
    final List<UserData> testUsers = [mockUser];
    late UserRepository myUserRepository;
    setUp(() {
      myUserRepository = MockUserRepository();
    });

    test('initial state is UsersLoading', () {
      expect(
        UsersBloc(userRepository: myUserRepository).state,
        UsersLoading(),
      );
    });

    blocTest<UsersBloc, UsersState>(
      'emits [ExploreEventsLoaded] when LoadExploreEvents is added',
      build: () {
        final Stream<List<UserData>> testUsersStream = Stream.value(testUsers);

        when(() => myUserRepository.getAllUsers())
            .thenAnswer((_) => testUsersStream);
        return UsersBloc(
          userRepository: myUserRepository,
        );
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [UsersLoaded(users: testUsers)],
      verify: (_) {
        verify(() => myUserRepository.getAllUsers()).called(1);
      },
    );
    blocTest<UsersBloc, UsersState>(
      'emits [UsersError] when users repository throws error',
      build: () {
        final Stream<List<UserData>> testUsersStream = Stream.error(Error());

        when(() => myUserRepository.getAllUsers())
            .thenAnswer((_) => testUsersStream);
        return UsersBloc(
          userRepository: myUserRepository,
        );
      },
      act: (bloc) => bloc.add(const LoadUsers()),
      expect: () => [UsersError()],
      verify: (_) {
        verify(() => myUserRepository.getAllUsers()).called(1);
      },
    );
  });
}
