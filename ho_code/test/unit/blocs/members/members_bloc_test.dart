import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockEventsRepository extends Mock implements MyEventsRepository {}

class MockGroupsRepository extends Mock implements MyGroupsRepository {}

class MockuserRepository extends Mock implements UserRepository {}

class MockOtherUser extends Mock implements OtherUser {}

class MockGroup extends Mock implements Group {}

void main() {
  group('MembersBloc', () {
    late MembersBloc membersBloc;
    late MyEventsRepository eventsRepository;
    late MyGroupsRepository groupsRepository;
    late UserRepository userRepository;
    final MockOtherUser user1 = MockOtherUser();
    final MockOtherUser user2 = MockOtherUser();
    final MockOtherUser user3 = MockOtherUser();
    const String id1 = "id1";
    const String id2 = "id2";
    const String id3 = "id3";
    const String name1 = "name1";
    const String name2 = "name2";
    const String name3 = "name3";
    final List<OtherUser> selectedUsers = [user1, user2, user3];
    final Group group1 = MockGroup();
    final Group group2 = MockGroup();
    final Group group3 = MockGroup();
    const String groupId1 = "id1";
    const String groupId2 = "id2";
    const String groupId3 = "id3";
    const String groupName1 = "name1";
    const String groupName2 = "name2";
    const String groupName3 = "name3";
    final List<Group> selectedGroups = [group1, group2, group3];

    const String groupId = "groupId";
    const String eventId = "eventId";
    const String currentUserId = "id1";

    setUp(() {
      eventsRepository = MockEventsRepository();
      groupsRepository = MockGroupsRepository();
      userRepository = MockuserRepository();
      when(() => user1.id).thenReturn(id1);
      when(() => user2.id).thenReturn(id2);
      when(() => user3.id).thenReturn(id3);
      when(() => user1.name).thenReturn(name1);
      when(() => user2.name).thenReturn(name2);
      when(() => user3.name).thenReturn(name3);

      when(() => group1.id).thenReturn(groupId1);
      when(() => group2.id).thenReturn(groupId2);
      when(() => group3.id).thenReturn(groupId3);
      when(() => group1.name).thenReturn(groupName1);
      when(() => group2.name).thenReturn(groupName2);
      when(() => group3.name).thenReturn(groupName3);
      membersBloc = MembersBloc(
        eventsRepository: eventsRepository,
        groupsRepository: groupsRepository,
        userRepository: userRepository,
      );
    });

    test('initial state is MembersLoading', () {
      expect(membersBloc.state, MembersLoading());
    });

    blocTest<MembersBloc, MembersState>(
      'emits MembersInit when GoInInitState is added',
      build: () => membersBloc,
      act: (bloc) => bloc.add(GoInInitState()),
      expect: () => [MembersInit()],
    );

    blocTest<MembersBloc, MembersState>(
      'emits MembersLoaded when LoadSelectedUsers is added and get these users is',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream =
            Stream.value(selectedUsers);
        when(() => userRepository.getTheseUsers(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadSelectedUsers(
          idUsers: [id1, id2, id3],
          currentUserId: currentUserId,
        ),
      ),
      expect: () => [MembersLoaded(members: selectedUsers)],
      verify: (_) {
        verify(() => userRepository.getTheseUsers(const [id1, id2, id3]))
            .called(1);
      },
    );

    blocTest<MembersBloc, MembersState>(
      'emits Memberserror when LoadSelectedUsers fails',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream = Stream.error(Error());
        when(() => userRepository.getTheseUsers(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadSelectedUsers(
          idUsers: [id1, id2, id3],
          currentUserId: currentUserId,
        ),
      ),
      expect: () => [MembersError()],
      verify: (_) {
        verify(() => userRepository.getTheseUsers(const [id1, id2, id3]))
            .called(1);
      },
    );

    blocTest<MembersBloc, MembersState>(
      'emits MembersLoaded when LoadSelectedUsersAndGroupMembers is added and get these users is',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream =
            Stream.value(selectedUsers);
        when(() => groupsRepository.getParticipantsToGroup(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadSelectedUsersAndGroupMembers(
          groupId: groupId,
          currentUserId: currentUserId,
        ),
      ),
      expect: () => [MembersLoaded(members: selectedUsers)],
      verify: (_) {
        verify(() => groupsRepository.getParticipantsToGroup(any())).called(1);
      },
    );
    blocTest<MembersBloc, MembersState>(
      'emits MembersError when LoadSelectedUsersAndGroupMembers fails',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream = Stream.error(Error());
        when(() => groupsRepository.getParticipantsToGroup(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadSelectedUsersAndGroupMembers(
          groupId: groupId,
          currentUserId: currentUserId,
        ),
      ),
      expect: () => [MembersError()],
      verify: (_) {
        verify(() => groupsRepository.getParticipantsToGroup(any())).called(1);
      },
    );
    blocTest<MembersBloc, MembersState>(
      'emits MembersLoaded when LoadMembersInEvent success',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream =
            Stream.value(selectedUsers);
        when(() => eventsRepository.getParticipantsToEvent(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadMembersInEvent(
          eventId: eventId,
        ),
      ),
      expect: () => [MembersLoaded(members: selectedUsers)],
      verify: (_) {
        verify(() => eventsRepository.getParticipantsToEvent(any())).called(1);
      },
    );
    blocTest<MembersBloc, MembersState>(
      'emits MembersError when LoadMembersInEvent fails',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream = Stream.error(Error());
        when(() => eventsRepository.getParticipantsToEvent(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadMembersInEvent(
          eventId: eventId,
        ),
      ),
      expect: () => [MembersError()],
      verify: (_) {
        verify(() => eventsRepository.getParticipantsToEvent(any())).called(1);
      },
    );
    blocTest<MembersBloc, MembersState>(
      'emits MembersLoaded when LoadMembersInGroup success with current id inside',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream =
            Stream.value(selectedUsers);
        when(() => groupsRepository.getParticipantsToGroup(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadMembersInGroup(
          currentUserId: currentUserId,
          groupId: eventId,
        ),
      ),
      expect: () => [MembersLoaded(members: selectedUsers)],
      verify: (_) {
        verify(() => groupsRepository.getParticipantsToGroup(any())).called(1);
      },
    );

    blocTest<MembersBloc, MembersState>(
      'emits MembersLoaded when LoadMembersInGroup success without current id inside',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream =
            Stream.value(selectedUsers);
        when(() => groupsRepository.getParticipantsToGroup(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadMembersInGroup(
          currentUserId: "Random",
          groupId: eventId,
        ),
      ),
      expect: () => [MembersLoaded(members: selectedUsers)],
      verify: (_) {
        verify(() => groupsRepository.getParticipantsToGroup(any())).called(1);
      },
    );

    blocTest<MembersBloc, MembersState>(
      'emits MembersLoaded when LoadMembersInGroup success with current not inside',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream =
            Stream.value(selectedUsers);
        when(() => groupsRepository.getParticipantsToGroup(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadMembersInGroup(
          currentUserId: currentUserId,
          groupId: eventId,
        ),
      ),
      expect: () => [MembersLoaded(members: selectedUsers)],
      verify: (_) {
        verify(() => groupsRepository.getParticipantsToGroup(any())).called(1);
      },
    );
    blocTest<MembersBloc, MembersState>(
      'emits MembersError when LoadMembersInGroup fails',
      setUp: () {
        final Stream<List<OtherUser>> testUserStream = Stream.error(Error());
        when(() => groupsRepository.getParticipantsToGroup(any()))
            .thenAnswer((_) => testUserStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadMembersInGroup(
          currentUserId: currentUserId,
          groupId: groupId,
        ),
      ),
      expect: () => [MembersError()],
      verify: (_) {
        verify(() => groupsRepository.getParticipantsToGroup(any())).called(1);
      },
    );

    blocTest<MembersBloc, MembersState>(
      'emits [GroupsLoaded] when [LoadGroupForUser] success',
      setUp: () {
        final Stream<List<Group>> testGroupStream =
            Stream.value(selectedGroups);
        when(() => groupsRepository.getGroupsOfUser(any()))
            .thenAnswer((_) async => testGroupStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadGroupForUser(
          userId: currentUserId,
        ),
      ),
      expect: () => [GroupsLoaded(groups: selectedGroups)],
      verify: (_) {
        verify(() => groupsRepository.getGroupsOfUser(any())).called(1);
      },
    );

    blocTest<MembersBloc, MembersState>(
      'emits [MembersError] when [LoadGroupForUser] fails',
      setUp: () {
        final Stream<List<Group>> testGroupStream = Stream.error(Error());
        when(() => groupsRepository.getGroupsOfUser(any()))
            .thenAnswer((_) async => testGroupStream);
      },
      build: () => membersBloc,
      act: (bloc) => bloc.add(
        const LoadGroupForUser(
          userId: currentUserId,
        ),
      ),
      expect: () => [MembersError()],
      verify: (_) {
        verify(() => groupsRepository.getGroupsOfUser(any())).called(1);
      },
    );
  });
}
