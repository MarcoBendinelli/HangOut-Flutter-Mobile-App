import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:image_picker/image_picker.dart';

part 'modify_user_state.dart';

class ModifyUserCubit extends Cubit<ModifyUserState> {
  final UserRepository _userRepository;

  ModifyUserCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const ModifyUserState());

  Future<void> modifyUser({
    required String userId,
    required String nickname,
    required bool isNicknameModified,
    required String bio,
    required String email,
    required List<String> interests,
    required XFile? newProfileImage,
    required String urlProfileImage,
    required bool notificationsPush,
    required bool notificationsEventChat,
    required bool notificationsGroupChat,
    required bool notificationsInviteEvent,
    required bool notificationsJoinGroup,
    required bool notificationsPublicEvent,
    required bool notificationsPublicGroup,
  }) async {
    UserData user = UserData(
        id: userId,
        name: nickname,
        email: email,
        description: bio,
        photo: urlProfileImage,
        interests: interests,
        notificationsPush: notificationsPush,
        notificationsGroupChat: notificationsGroupChat,
        notificationsEventChat: notificationsEventChat,
        notificationsJoinGroup: notificationsJoinGroup,
        notificationsInviteEvent: notificationsInviteEvent,
        notificationsPublicEvent: notificationsPublicEvent,
        notificationsPublicGroup: notificationsPublicGroup);
    emit(state.copyWith(status: ModifyUserStatus.loading, userUpdated: user));
    try {
      await _userRepository.modifyUser(
          user: user,
          profileImage: newProfileImage,
          isNicknameModified: isNicknameModified);
      emit(state.copyWith(status: ModifyUserStatus.success, userUpdated: user));
    } catch (_) {
      emit(state.copyWith(status: ModifyUserStatus.error, userUpdated: user));
    }
  }
}
