import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';

part 'members_event.dart';

part 'members_state.dart';

class MembersBloc extends Bloc<MembersEvent, MembersState> {
  final MyEventsRepository _eventsRepository;
  final MyGroupsRepository _groupsRepository;
  final UserRepository _userRepository;
  List<OtherUser> selectedUsers = [];

  MembersBloc({
    required MyEventsRepository eventsRepository,
    required MyGroupsRepository groupsRepository,
    required UserRepository userRepository,
  })  : _groupsRepository = groupsRepository,
        _eventsRepository = eventsRepository,
        _userRepository = userRepository,
        super(MembersLoading()) {
    on<GoInInitState>(_onGoInInitState);
    on<LoadMembersInEvent>(_onLoadFromEvent);
    on<LoadMembersInGroup>(_onLoadFromGroup);
    on<LoadGroupForUser>(_onLoadGroupForUser);
    on<LoadSelectedUsers>(_onLoadSelectedUsers);
    on<LoadSelectedUsersAndGroupMembers>(_onLoadSelectedUsersAndGroupMembers);
  }

  Future<void> _onGoInInitState(
    GoInInitState event,
    Emitter<MembersState> emit,
  ) async {
    emit(MembersInit());
  }

  Future<void> _onLoadSelectedUsers(
    LoadSelectedUsers event,
    Emitter<MembersState> emit,
  ) async {
    await emit.forEach(
      _userRepository.getTheseUsers(event.idUsers),
      onData: (List<OtherUser> membersData) {
        OtherUser currentUser = membersData
            .firstWhere((element) => element.id == event.currentUserId);
        membersData.remove(currentUser);
        membersData.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        membersData.insert(0, currentUser);
        selectedUsers = membersData;
        return MembersLoaded(members: selectedUsers);
      },
      onError: (_, __) => MembersError(),
    );
  }

  Future<void> _onLoadSelectedUsersAndGroupMembers(
    LoadSelectedUsersAndGroupMembers event,
    Emitter<MembersState> emit,
  ) async {
    await emit.forEach(
      _groupsRepository.getParticipantsToGroup(event.groupId),
      onData: (List<OtherUser> membersData) {
        OtherUser currentUser = membersData
            .firstWhere((element) => element.id == event.currentUserId);
        membersData.remove(currentUser);
        membersData.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        membersData.insert(0, currentUser);
        selectedUsers = membersData;
        return MembersLoaded(members: selectedUsers);
      },
      onError: (_, __) => MembersError(),
    );
  }

  Future<void> _onLoadFromEvent(
    LoadMembersInEvent event,
    Emitter<MembersState> emit,
  ) async {
    await emit.forEach(
      _eventsRepository.getParticipantsToEvent(event.eventId),
      onData: (List<OtherUser> membersData) {
        membersData.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return MembersLoaded(members: membersData);
      },
      onError: (_, __) => MembersError(),
    );
  }

  Future<void> _onLoadFromGroup(
    LoadMembersInGroup event,
    Emitter<MembersState> emit,
  ) async {
    await emit.forEach(
      _groupsRepository.getParticipantsToGroup(event.groupId),
      onData: (List<OtherUser> membersData) {
        if (membersData.map((e) => e.id).contains(event.currentUserId)) {
          OtherUser currentUser = membersData
              .firstWhere((element) => element.id == event.currentUserId);
          membersData.remove(currentUser);
          membersData.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          membersData.insert(0, currentUser);
          return MembersLoaded(members: membersData);
        } else {
          membersData.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          return MembersLoaded(members: membersData);
        }
      },
      onError: (_, __) => MembersError(),
    );
  }

  Future<void> _onLoadGroupForUser(
    LoadGroupForUser event,
    Emitter<MembersState> emit,
  ) async {
    await emit.forEach(
      await _groupsRepository.getGroupsOfUser(event.userId),
      onData: (List<Group> groupsData) {
        groupsData.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return GroupsLoaded(groups: groupsData);
      },
      onError: (_, __) => MembersError(),
    );
  }
}
