import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/other_user.dart';

import 'package:hang_out_app/data/repositories/my_groups_repository.dart';

part 'delete_join_leave_group_state.dart';

class DeleteJoinLeaveGroupCubit extends Cubit<DeleteJoinLeaveGroupState> {
  final MyGroupsRepository _groupsRepository;

  DeleteJoinLeaveGroupCubit({required MyGroupsRepository groupsRepository})
      : _groupsRepository = groupsRepository,
        super(const DeleteJoinLeaveGroupState());

  Future<void> deleteGroup({required String groupId}) async {
    emit(state.copyWith(status: DeleteJoinLeaveGroupStatus.loading));
    try {
      await _groupsRepository.deleteGroupWithId(groupId: groupId);
      emit(state.copyWith(status: DeleteJoinLeaveGroupStatus.success));
    } catch (_) {
      emit(state.copyWith(status: DeleteJoinLeaveGroupStatus.error));
    }
  }

  Future<void> joinGroup(
      {required String groupId, required OtherUser user}) async {
    emit(state.copyWith(status: DeleteJoinLeaveGroupStatus.loading));
    try {
      await _groupsRepository.joinGroup(groupId: groupId, user: user);
      emit(state.copyWith(status: DeleteJoinLeaveGroupStatus.success));
    } catch (_) {
      emit(state.copyWith(status: DeleteJoinLeaveGroupStatus.error));
    }
  }

  Future<void> leaveGroup(
      {required String groupId, required String userId}) async {
    emit(state.copyWith(status: DeleteJoinLeaveGroupStatus.loading));
    try {
      await _groupsRepository.leaveGroup(groupId: groupId, userId: userId);
      emit(state.copyWith(status: DeleteJoinLeaveGroupStatus.success));
    } catch (_) {
      emit(state.copyWith(status: DeleteJoinLeaveGroupStatus.error));
    }
  }
}
