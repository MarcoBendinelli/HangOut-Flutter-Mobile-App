import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/cubits/user/modify_user_cubit.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockUserData extends Mock implements UserData {}

class MockXFile extends Mock implements XFile {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockUserData());
  });
  group("Groups cubits", () {
    late MockUserRepository userRepository;
    final XFile image = MockXFile();
    UserData user = const UserData(
        id: "userId",
        name: "nickname",
        email: "email",
        description: "bio",
        photo: "urlProfileImage",
        interests: [],
        notificationsPush: true,
        notificationsGroupChat: true,
        notificationsEventChat: true,
        notificationsJoinGroup: true,
        notificationsInviteEvent: true,
        notificationsPublicEvent: true,
        notificationsPublicGroup: true);

    setUp(() {
      userRepository = MockUserRepository();
    });

    group("Modify Group Cubit", () {
      test('initial state is initial', () {
        expect(ModifyUserCubit(userRepository: userRepository).state.status,
            ModifyUserStatus.initial);
      });

      blocTest<ModifyUserCubit, ModifyUserState>(
        'emits [success] when [MyGroupsRepository] modify group successfully',
        setUp: () {
          when(
            () => userRepository.modifyUser(
                user: any(named: "user"),
                profileImage: image,
                isNicknameModified: true),
          ).thenAnswer((_) async {});
        },
        build: () => ModifyUserCubit(userRepository: userRepository),
        act: (cubit) => cubit.modifyUser(
            userId: user.id,
            nickname: user.name,
            isNicknameModified: true,
            bio: user.description,
            email: user.email,
            interests: user.interests,
            newProfileImage: image,
            urlProfileImage: user.photo,
            notificationsPush: true,
            notificationsEventChat: true,
            notificationsGroupChat: true,
            notificationsInviteEvent: true,
            notificationsJoinGroup: true,
            notificationsPublicEvent: true,
            notificationsPublicGroup: true),
        expect: () => [
          const ModifyUserState(status: ModifyUserStatus.loading),
          const ModifyUserState(status: ModifyUserStatus.success),
        ],
      );

      blocTest<ModifyUserCubit, ModifyUserState>(
        'emits [success] when [MyGroupsRepository] modify group successfully',
        setUp: () {
          when(
            () => userRepository.modifyUser(
                user: any(named: "user"),
                profileImage: image,
                isNicknameModified: true),
          ).thenThrow(Error());
        },
        build: () => ModifyUserCubit(userRepository: userRepository),
        act: (cubit) => cubit.modifyUser(
            userId: user.id,
            nickname: user.name,
            isNicknameModified: true,
            bio: user.description,
            email: user.email,
            interests: user.interests,
            newProfileImage: image,
            urlProfileImage: user.photo,
            notificationsPush: true,
            notificationsEventChat: true,
            notificationsGroupChat: true,
            notificationsInviteEvent: true,
            notificationsJoinGroup: true,
            notificationsPublicEvent: true,
            notificationsPublicGroup: true),
        expect: () => [
          const ModifyUserState(status: ModifyUserStatus.loading),
          const ModifyUserState(status: ModifyUserStatus.error),
        ],
      );
    });
  });
}
