import 'package:bloc_test/bloc_test.dart';

import 'package:hang_out_app/business_logic/blocs/my_groups/groups_bloc.dart';

import 'package:hang_out_app/data/models/group.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupsRepository extends Mock implements MyGroupsRepository {}

class MockGroup extends Mock implements Group {}

void main() {
  group('GroupsBloc', () {
    final groupMock = MockGroup();
    final List<Group> testGroups = [groupMock];
    final Stream<List<Group>> testGroupsStream = Stream.value(testGroups);
    final Stream<List<Group>> testGroupsStreamError = Stream.error(Error());
    const String userId = "userId";
    late MyGroupsRepository myGroupsRepository;

    setUp(() {
      myGroupsRepository = MockGroupsRepository();
    });

    test('initial state is GroupsLoading', () {
      expect(
        GroupsBloc(groupsRepository: myGroupsRepository).state,
        GroupsLoading(),
      );
    });

    blocTest<GroupsBloc, GroupsState>(
      'getGroupsOfUser success',
      setUp: () => when(() => myGroupsRepository.getGroupsOfUser(userId))
          .thenAnswer((_) async => testGroupsStream),
      build: () => GroupsBloc(
        groupsRepository: myGroupsRepository,
      ),
      act: (bloc) => bloc.add(const LoadGroups(userId: userId)),
      expect: () => [
        GroupsLoaded(groups: testGroups),
      ],
      verify: (_) {
        verify(() => myGroupsRepository.getGroupsOfUser(userId)).called(1);
      },
    );

    blocTest<GroupsBloc, GroupsState>(
      'getGroupsOfUser error',
      setUp: () =>
          when(() => myGroupsRepository.getGroupsOfUser(userId)).thenAnswer(
        (_) async => testGroupsStreamError,
      ),
      build: () => GroupsBloc(
        groupsRepository: myGroupsRepository,
      ),
      act: (bloc) => bloc.add(const LoadGroups(userId: userId)),
      expect: () => [
        GroupsError(),
      ],
      verify: (_) {
        verify(() => myGroupsRepository.getGroupsOfUser(userId)).called(1);
      },
    );
  });
}
