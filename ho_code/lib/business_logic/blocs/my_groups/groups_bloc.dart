import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';

part 'groups_event.dart';

part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final MyGroupsRepository _groupsRepository;

  GroupsBloc({required MyGroupsRepository groupsRepository})
      : _groupsRepository = groupsRepository,
      super(GroupsLoading()) {
    on<LoadGroups>(_onLoadGroups);
  }

  Future<void> _onLoadGroups(
    LoadGroups event,
    Emitter<GroupsState> emit,
  ) async {
    await emit.forEach(
      await _groupsRepository.getGroupsOfUser(event.userId),
      onData: (List<Group> groupData) => GroupsLoaded(groups: groupData),
      onError: (_, __) => GroupsError(),
    );
  }
}
