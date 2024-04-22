import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/cubits/groups/add_group/add_group_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/groups/delete_join_leave_group/delete_join_leave_group_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/groups/modify_group/modify_group_cubit.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../blocs/profile/profile_bloc_test.dart';

class MockGroupsRepository extends Mock implements MyGroupsRepository {}

class MockEvent extends Mock implements Group {}

class MockOtherUser extends Mock implements OtherUser {}

class MockXFile extends Mock implements XFile {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockGroup());
  });
  group("Groups cubits", () {
    final OtherUser groupCreator = MockOtherUser();
    const String creatorId = "creatorId";
    final List<OtherUser> members = [];
    final XFile image = MockXFile();
    const String groupId = "";
    const String groupName = "groupName";
    const String groupCaption = "groupCaption";
    const bool isPrivate = true;
    const List<String> interests = ["food", "music"];

    late MockGroupsRepository myGroupsRepository;
    setUp(() {
      when(() => groupCreator.id).thenReturn(creatorId);
      myGroupsRepository = MockGroupsRepository();
    });
    group("Add Group Cubit", () {
      test('initial state is initial', () {
        expect(AddGroupCubit(groupsRepository: myGroupsRepository).state.status,
            AddGroupStatus.initial);
      });

      blocTest<AddGroupCubit, AddGroupState>(
        'emits [success] when [MyGroupsRepository] saves group successfully',
        setUp: () {
          when(() => groupCreator.id).thenReturn(creatorId);
          when(
            () => myGroupsRepository.saveNewGroup(
                group: any(named: "group"),
                creator: groupCreator,
                imageFile: image,
                members: members),
          ).thenAnswer((_) async => groupId);
        },
        build: () => AddGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.addGroup(
          groupCreator: groupCreator,
          groupName: groupName,
          groupCaption: groupCaption,
          isPrivate: isPrivate,
          groupInterests: interests,
          image: image,
          members: members,
        ),
        expect: () => [
          const AddGroupState(status: AddGroupStatus.loading),
          const AddGroupState(status: AddGroupStatus.success),
        ],
      );
      blocTest<AddGroupCubit, AddGroupState>(
        'emits [error] when [MyGroupsRepository] saves group throws error',
        setUp: () {
          when(() => groupCreator.id).thenReturn(creatorId);
          when(
            () => myGroupsRepository.saveNewGroup(
                group: any(named: "group"),
                creator: groupCreator,
                imageFile: image,
                members: members),
          ).thenThrow(Error());
        },
        build: () => AddGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.addGroup(
          groupCreator: groupCreator,
          groupName: groupName,
          groupCaption: groupCaption,
          isPrivate: isPrivate,
          groupInterests: interests,
          image: image,
          members: members,
        ),
        expect: () => [
          const AddGroupState(status: AddGroupStatus.loading),
          const AddGroupState(status: AddGroupStatus.error),
        ],
      );
    });

    group("delete_join_leave_group_cubit", () {
      test('initial state is initial', () {
        expect(
            DeleteJoinLeaveGroupCubit(groupsRepository: myGroupsRepository)
                .state
                .status,
            DeleteJoinLeaveGroupStatus.initial);
      });

      blocTest<DeleteJoinLeaveGroupCubit, DeleteJoinLeaveGroupState>(
        'emits [success] when [MyGroupsRepository] join group successfully',
        setUp: () {
          when(
            () => myGroupsRepository.joinGroup(
                user: groupCreator, groupId: groupId),
          ).thenAnswer((_) async => {});
        },
        build: () =>
            DeleteJoinLeaveGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.joinGroup(
          groupId: groupId,
          user: groupCreator,
        ),
        expect: () => [
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.loading),
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.success),
        ],
      );
      blocTest<DeleteJoinLeaveGroupCubit, DeleteJoinLeaveGroupState>(
        'emits [error] when [MyGroupsRepository] join group throws error',
        setUp: () {
          when(
            () => myGroupsRepository.joinGroup(
                user: groupCreator, groupId: groupId),
          ).thenThrow(Error());
        },
        build: () =>
            DeleteJoinLeaveGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.joinGroup(
          groupId: groupId,
          user: groupCreator,
        ),
        expect: () => [
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.loading),
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.error),
        ],
      );

      blocTest<DeleteJoinLeaveGroupCubit, DeleteJoinLeaveGroupState>(
        'emits [success] when [MyGroupsRepository] leave group successfully',
        setUp: () {
          when(
            () => myGroupsRepository.leaveGroup(
                userId: creatorId, groupId: groupId),
          ).thenAnswer((_) async => {});
        },
        build: () =>
            DeleteJoinLeaveGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.leaveGroup(
          groupId: groupId,
          userId: creatorId,
        ),
        expect: () => [
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.loading),
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.success),
        ],
      );
      blocTest<DeleteJoinLeaveGroupCubit, DeleteJoinLeaveGroupState>(
        'emits [error] when [MyGroupsRepository] leave group throws error',
        setUp: () {
          when(
            () => myGroupsRepository.leaveGroup(
                userId: creatorId, groupId: groupId),
          ).thenThrow(Error());
        },
        build: () =>
            DeleteJoinLeaveGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.leaveGroup(
          groupId: groupId,
          userId: creatorId,
        ),
        expect: () => [
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.loading),
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.error),
        ],
      );

      blocTest<DeleteJoinLeaveGroupCubit, DeleteJoinLeaveGroupState>(
        'emits [success] when [MyGroupsRepository] delete group successfully',
        setUp: () {
          when(
            () => myGroupsRepository.deleteGroupWithId(groupId: groupId),
          ).thenAnswer((_) async => {});
        },
        build: () =>
            DeleteJoinLeaveGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.deleteGroup(
          groupId: groupId,
        ),
        expect: () => [
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.loading),
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.success),
        ],
      );
      blocTest<DeleteJoinLeaveGroupCubit, DeleteJoinLeaveGroupState>(
        'emits [error] when [MyGroupsRepository] delete group throws error',
        setUp: () {
          when(
            () => myGroupsRepository.deleteGroupWithId(groupId: groupId),
          ).thenThrow(Error());
        },
        build: () =>
            DeleteJoinLeaveGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.deleteGroup(
          groupId: groupId,
        ),
        expect: () => [
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.loading),
          const DeleteJoinLeaveGroupState(
              status: DeleteJoinLeaveGroupStatus.error),
        ],
      );
    });

    group("Modify Group Cubit", () {
      test('initial state is initial', () {
        expect(
            ModifyGroupCubit(groupsRepository: myGroupsRepository).state.status,
            ModifyGroupStatus.initial);
      });

      blocTest<ModifyGroupCubit, ModifyGroupState>(
        'emits [success] when [MyGroupsRepository] modify group successfully',
        setUp: () {
          when(
            () => myGroupsRepository.modifyGroup(
              group: any(named: "group"),
              creatorId: creatorId,
              imageFile: image,
              newMembers: members,
            ),
          ).thenAnswer((_) async {});
        },
        build: () => ModifyGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.modifyGroup(
          groupId: groupId,
          groupName: groupName,
          groupCaption: groupCaption,
          groupCreatorId: creatorId,
          isPrivate: isPrivate,
          groupInterests: interests,
          image: image,
          members: members,
          creatorId: creatorId,
          interests: interests,
        ),
        expect: () => [
          const ModifyGroupState(status: ModifyGroupStatus.loading),
          const ModifyGroupState(status: ModifyGroupStatus.success),
        ],
      );

      blocTest<ModifyGroupCubit, ModifyGroupState>(
        'emits [error] when [MyGroupsRepository] modify group with error',
        setUp: () {
          when(
            () => myGroupsRepository.modifyGroup(
              group: any(named: "group"),
              creatorId: creatorId,
              imageFile: image,
              newMembers: members,
            ),
          ).thenThrow(Error());
        },
        build: () => ModifyGroupCubit(groupsRepository: myGroupsRepository),
        act: (cubit) => cubit.modifyGroup(
          groupId: groupId,
          groupName: groupName,
          groupCaption: groupCaption,
          groupCreatorId: creatorId,
          isPrivate: isPrivate,
          groupInterests: interests,
          image: image,
          members: members,
          creatorId: creatorId,
          interests: interests,
        ),
        expect: () => [
          const ModifyGroupState(status: ModifyGroupStatus.loading),
          const ModifyGroupState(status: ModifyGroupStatus.error),
        ],
      );
    });
  });
}
