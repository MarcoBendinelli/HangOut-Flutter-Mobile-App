import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/profile/profile_bloc.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupsRepository extends Mock implements MyGroupsRepository {}

class MockGroup extends Mock implements Group {}

void main() {
  group('ProfileBloc', () {
    final Group mockGroup = MockGroup();
    final List<Group> testGroups = [mockGroup];
    const String userId1 = "userId1";
    const String userId2 = "userId2";
    late MyGroupsRepository myGroupsRepository;
    setUp(() {
      myGroupsRepository = MockGroupsRepository();
    });

    test('initial state is CommonGroupsLoading', () {
      expect(
        ProfileBloc(groupsRepository: myGroupsRepository).state,
        CommonGroupsLoading(),
      );
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [CommonGroupsLoaded] when LoadGroupsInCommon is added',
      build: () {
        final Stream<List<Group>> testGroupsStream = Stream.value(testGroups);

        when(() => myGroupsRepository.getCommonGroups(userId1, userId2))
            .thenAnswer((_) async => testGroupsStream);
        return ProfileBloc(groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc
          .add(const LoadGroupsInCommon(firstId: userId1, secondId: userId2)),
      expect: () => [CommonGroupsLoaded(groups: testGroups)],
      verify: (_) {
        verify(() => myGroupsRepository.getCommonGroups(userId1, userId2))
            .called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [CommonGroupsLoaded] when LoadGroupsInCommon is added and zero common groups',
      build: () {
        final Stream<List<Group>> testGroupsStream = Stream.value([]);

        when(() => myGroupsRepository.getCommonGroups(userId1, userId2))
            .thenAnswer((_) async => testGroupsStream);
        return ProfileBloc(groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc
          .add(const LoadGroupsInCommon(firstId: userId1, secondId: userId2)),
      expect: () => [const CommonGroupsLoaded(groups: [])],
      verify: (_) {
        verify(() => myGroupsRepository.getCommonGroups(userId1, userId2))
            .called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [CommonGroupsError] when groups repository throws error',
      build: () {
        final Stream<List<Group>> testGroupsStreamError = Stream.error(Error());

        when(() => myGroupsRepository.getCommonGroups(userId1, userId2))
            .thenAnswer((_) async => testGroupsStreamError);
        return ProfileBloc(groupsRepository: myGroupsRepository);
      },
      act: (bloc) => bloc
          .add(const LoadGroupsInCommon(firstId: userId1, secondId: userId2)),
      expect: () => [CommonGroupsError()],
    );
  });
}
