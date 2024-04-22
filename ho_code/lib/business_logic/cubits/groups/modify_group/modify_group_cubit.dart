import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:image_picker/image_picker.dart';

part 'modify_group_state.dart';

class ModifyGroupCubit extends Cubit<ModifyGroupState> {
  final MyGroupsRepository _groupsRepository;

  ModifyGroupCubit({required MyGroupsRepository groupsRepository})
      : _groupsRepository = groupsRepository,
        super(const ModifyGroupState());

  Future<void> modifyGroup(
      {required String groupId,
      required String groupName,
      required String groupCreatorId,
      required String groupCaption,
      required bool isPrivate,
      required List<String> interests,
      required List<OtherUser> members,
      required List<String> groupInterests,
      required String creatorId,
      required XFile? image}) async {
    emit(state.copyWith(status: ModifyGroupStatus.loading));
    try {
      await _groupsRepository.modifyGroup(
          group: Group(
              id: groupId,
              name: groupName,
              caption: groupCaption,
              creatorId: groupCreatorId,
              isPrivate: isPrivate,
              interests: groupInterests),
          newMembers: members,
          creatorId: creatorId,
          imageFile: image);
      emit(state.copyWith(status: ModifyGroupStatus.success));
    } catch (_) {
      emit(state.copyWith(status: ModifyGroupStatus.error));
    }
  }
}
