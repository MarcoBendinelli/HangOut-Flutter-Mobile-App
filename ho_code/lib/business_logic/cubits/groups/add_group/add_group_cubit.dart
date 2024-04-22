import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';

part 'add_group_state.dart';

class AddGroupCubit extends Cubit<AddGroupState> {
  final MyGroupsRepository _groupsRepository;

  AddGroupCubit({required MyGroupsRepository groupsRepository})
      : _groupsRepository = groupsRepository,
        super(const AddGroupState());

  Future<String> addGroup(
      {required OtherUser groupCreator,
      required String groupName,
      required String groupCaption,
      required bool isPrivate,
      required List<String> groupInterests,
      required XFile? image,
      required List<OtherUser> members}) async {
    emit(state.copyWith(status: AddGroupStatus.loading));
    try {
      String groupId = await _groupsRepository.saveNewGroup(
          group: Group(
              id: "",
              name: groupName,
              caption: groupCaption,
              creatorId: groupCreator.id,
              numParticipants: members.length,
              isPrivate: isPrivate,
              interests: groupInterests,
              photo: ""),
          creator: groupCreator,
          imageFile: image,
          members: members);
      emit(state.copyWith(status: AddGroupStatus.success));
      return groupId;
    } catch (_) {
      emit(state.copyWith(status: AddGroupStatus.error));
      return "";
    }
  }
}
