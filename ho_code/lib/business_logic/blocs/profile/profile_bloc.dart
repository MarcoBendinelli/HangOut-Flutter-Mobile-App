import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final MyGroupsRepository _groupsRepository;

  ProfileBloc({required MyGroupsRepository groupsRepository})
      : _groupsRepository = groupsRepository,
        super(CommonGroupsLoading()) {
    on<LoadGroupsInCommon>(_onLoadGroupsInCommon);
  }

  Future<void> _onLoadGroupsInCommon(
    LoadGroupsInCommon event,
    Emitter<ProfileState> emit,
  ) async {
    await emit.forEach(
      await _groupsRepository.getCommonGroups(event.firstId, event.secondId),
      onData: (List<Group> groupsData) =>
          CommonGroupsLoaded(groups: groupsData),
      onError: (_, __) => CommonGroupsError(),
    );
  }
}
