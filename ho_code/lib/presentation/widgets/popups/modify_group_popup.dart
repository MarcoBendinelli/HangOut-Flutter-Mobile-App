import 'package:flutter/material.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/groups/modify_group/modify_group_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/notification/notification_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/required_fields/required_fields_cubit.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_return_and_name.dart';
import 'package:hang_out_app/presentation/widgets/mandatory_note.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/privacy_selector_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_photo_row.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hang_out_app/presentation/utils/animations/custom_rect_tween.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';
import 'package:hang_out_app/presentation/widgets/our_divider.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/multi_category_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/new_or_modify_group_widgets/group_members_row.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';

/// Popup card to add a new [Group]. Should be used in conjunction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAddGroup].
class ModifyGroupPopup extends StatefulWidget {
  final String heroTag;
  final Group currentGroup;

  const ModifyGroupPopup(
      {Key? key, required this.heroTag, required this.currentGroup})
      : super(key: key);

  @override
  State<ModifyGroupPopup> createState() => _ModifyGroupPopupState();
}

class _ModifyGroupPopupState extends State<ModifyGroupPopup> {
  String groupName = "";
  String groupCaption = "";
  String groupId = "";
  int groupNumParticipants = 0;
  List<String> groupInterests = [];
  List<String> oldIdMembers = [];
  XFile? groupImage;
  bool groupPrivate = true;

  @override
  initState() {
    super.initState();
    groupId = widget.currentGroup.id;
    groupName = widget.currentGroup.name;
    groupCaption = widget.currentGroup.caption;
    groupInterests = widget.currentGroup.interests;
    groupPrivate = widget.currentGroup.isPrivate;
    oldIdMembers = widget.currentGroup.members!;
    groupNumParticipants = widget.currentGroup.numParticipants!;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ModifyGroupCubit>(
          create: (context) => ModifyGroupCubit(
              groupsRepository: context.read<MyGroupsRepository>()),
        ),
        BlocProvider<RequiredFieldsCubit>(
          create: (context) => RequiredFieldsCubit(isForTheEvent: false),
        ),
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(
              notificationsRepository: context.read<NotificationsRepository>(),
              userRepository: context.read<UserRepository>()),
        ),
      ],
      child: Builder(builder: (context) {
        UserData currentUser =
            context.select((UserBloc bloc) => bloc.state.user);
        BlocProvider.of<RequiredFieldsCubit>(context)
            .updateName(inputName: groupName);
        BlocProvider.of<RequiredFieldsCubit>(context)
            .updateCaption(inputCaption: groupCaption);
        BlocProvider.of<RequiredFieldsCubit>(context)
            .updateInterests(inputInterests: groupInterests);
        if (getSize(context) == ScreenSize.normal) {
          return _buildModifyGroup(context, currentUser);
        }
        return _buildTabletModifyGroup(context, currentUser);
      }),
    );
  }

  Widget _buildModifyGroup(BuildContext context, UserData currentUser) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: Constants.popupDimensionPadding,
            child: Hero(
              tag: widget.heroTag,
              createRectTween: (begin, end) {
                return CustomRectTween(begin: begin!, end: end!);
              },
              child: Material(
                color: Theme.of(context).cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Constants.borderRadius)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TopBarReturnAndName(
                      title: 'Modify Group',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: Constants.contentPopupPadding,
                          child: Column(
                            children: [
                              TextPhotoRow(
                                setNameCallback: (insertedGroupName) {
                                  groupName = insertedGroupName;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateName(inputName: groupName);
                                },
                                inputName: "Group Name",
                                setImagePickedCallback: (choseImage) {
                                  groupImage = choseImage;
                                },
                                oldName: groupName,
                                oldPhoto: widget.currentGroup.photo!,
                                required: true,
                                borderRadius: 60,
                              ),
                              const OurDivider(),
                              TextInputRow(
                                inputName: "Caption",
                                hintText: Constants.groupCaptionHint,
                                setTextCallback: (insertedGroupCaption) {
                                  groupCaption = insertedGroupCaption;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateCaption(
                                          inputCaption: groupCaption);
                                },
                                oldText: groupCaption,
                                required: true,
                              ),
                              const OurDivider(),
                              GroupMembersRow(
                                numberOfMembers: groupNumParticipants,
                              ),
                              const OurDivider(),
                              MultiCategoryInputRow(
                                inputName: "Our interests",
                                groupInterestsCallback: (selectedInterests) {
                                  groupInterests = selectedInterests;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateInterests(
                                          inputInterests: groupInterests);
                                },
                                oldGroupInterests: groupInterests,
                                required: true,
                              ),
                              const OurDivider(),
                              PrivacySelectorRow(
                                  setPrivacyCallback: (privacy) {
                                    groupPrivate = privacy;
                                  },
                                  oldPrivacy: groupPrivate),
                              const OurDivider(),
                              const MandatoryNote(),
                              SizedBox(
                                height: Constants.distanceBtwDoneNElement,
                              ),
                              BlocConsumer<ModifyGroupCubit, ModifyGroupState>(
                                listener: (context, state) {
                                  if (state.status ==
                                      ModifyGroupStatus.success) {
                                    Navigator.of(context).pop();

                                    List<String> membersToNotify = [];

                                    List<String> selectedUserIds =
                                        BlocProvider.of<MembersBloc>(context)
                                            .selectedUsers
                                            .map((e) => e.id)
                                            .toList();

                                    for (String id in selectedUserIds) {
                                      if (!oldIdMembers.contains(id) &&
                                          id != currentUser.id) {
                                        membersToNotify.add(id);
                                      }
                                    }

                                    if (membersToNotify.isNotEmpty) {
                                      DateTime now = DateTime.now();
                                      int timeStamp =
                                          now.millisecondsSinceEpoch;
                                      List<String> splitDateHour = now
                                          .toString()
                                          .split(".")[0]
                                          .split(":");
                                      String dateHour =
                                          "${splitDateHour[0]}:${splitDateHour[1]}";

                                      /// Add a notification in the popup notifications
                                      BlocProvider.of<NotificationCubit>(
                                              context)
                                          .addNewNotification(
                                        userIdsToNotify: membersToNotify,
                                        sourceName: currentUser.name,
                                        thingToOpenId: groupId,
                                        thingToNotifyName: groupName,
                                        dateHour: dateHour,
                                        timestamp: timeStamp,
                                        notificationsJoinGroup: true,
                                        public: false,
                                      );

                                      /// Send a Push Notification to added users
                                      BlocProvider.of<UserBloc>(context)
                                          .sendPushNotificationsToUsers(
                                        userIdsToNotify: membersToNotify,
                                        title: currentUser.name +
                                            Constants.titleNotificationGroup,
                                        body: Constants.bodyNotificationGroup +
                                            groupName,
                                        notificationsJoinGroup: true,
                                      );
                                    }
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status ==
                                      ModifyGroupStatus.initial) {
                                    return Center(
                                      child: BlocBuilder<RequiredFieldsCubit,
                                          RequiredFieldsState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              RequiredFieldsStatus.completed) {
                                            return TapFadeText(
                                              onTap: () async {
                                                await _tapDone(
                                                    context, currentUser);
                                              },
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                            );
                                          } else {
                                            return TapFadeText(
                                              onTap: () {},
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                              disabled: true,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  } else if (state.status ==
                                      ModifyGroupStatus.error) {
                                    return const Center(
                                      child:
                                          CustomText(text: "An error occured"),
                                    );
                                  } else {
                                    return const Center(
                                        child: OurCircularProgressIndicator());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _tapDone(BuildContext context, UserData currentUser) async {
    await BlocProvider.of<ModifyGroupCubit>(context).modifyGroup(
        groupId: groupId,
        groupCreatorId: currentUser.id,
        groupName: groupName,
        groupCaption: groupCaption,
        groupInterests: groupInterests,
        isPrivate: groupPrivate,
        members: BlocProvider.of<MembersBloc>(context).selectedUsers,
        interests: groupInterests,
        creatorId: currentUser.id,
        image: groupImage);
  }

  Widget _buildTabletModifyGroup(BuildContext context, UserData currentUser) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Center(
          child: Hero(
            tag: widget.heroTag,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: Material(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.borderRadius)),
              child: SizedBox(
                height: PopupTabletConstants.popupDimension(),
                width: PopupTabletConstants.popupDimension(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TopBarReturnAndName(
                      title: 'Modify Group',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: PopupTabletConstants.contentPopupPadding(),
                          child: Column(
                            children: [
                              TextPhotoRow(
                                setNameCallback: (insertedGroupName) {
                                  groupName = insertedGroupName;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateName(inputName: groupName);
                                },
                                inputName: "Group Name",
                                setImagePickedCallback: (choseImage) {
                                  groupImage = choseImage;
                                },
                                oldName: groupName,
                                oldPhoto: widget.currentGroup.photo!,
                                required: true,
                                borderRadius: 100,
                              ),
                              const OurDivider(),
                              TextInputRow(
                                inputName: "Caption",
                                hintText: Constants.groupCaptionHint,
                                setTextCallback: (insertedGroupCaption) {
                                  groupCaption = insertedGroupCaption;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateCaption(
                                          inputCaption: groupCaption);
                                },
                                oldText: groupCaption,
                                required: true,
                              ),
                              const OurDivider(),
                              GroupMembersRow(
                                numberOfMembers: groupNumParticipants,
                              ),
                              const OurDivider(),
                              MultiCategoryInputRow(
                                inputName: "Our interests",
                                groupInterestsCallback: (selectedInterests) {
                                  groupInterests = selectedInterests;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateInterests(
                                          inputInterests: groupInterests);
                                },
                                oldGroupInterests: groupInterests,
                                required: true,
                              ),
                              const OurDivider(),
                              PrivacySelectorRow(
                                  setPrivacyCallback: (privacy) {
                                    groupPrivate = privacy;
                                  },
                                  oldPrivacy: groupPrivate),
                              const OurDivider(),
                              const MandatoryNote(),
                              SizedBox(
                                height: PopupTabletConstants
                                    .distanceBtwDoneNElement(),
                              ),
                              BlocConsumer<ModifyGroupCubit, ModifyGroupState>(
                                listener: (context, state) {
                                  if (state.status ==
                                      ModifyGroupStatus.success) {
                                    Navigator.of(context).pop();

                                    List<String> membersToNotify = [];

                                    List<String> selectedUserIds =
                                        BlocProvider.of<MembersBloc>(context)
                                            .selectedUsers
                                            .map((e) => e.id)
                                            .toList();

                                    for (String id in selectedUserIds) {
                                      if (!oldIdMembers.contains(id) &&
                                          id != currentUser.id) {
                                        membersToNotify.add(id);
                                      }
                                    }

                                    if (membersToNotify.isNotEmpty) {
                                      DateTime now = DateTime.now();
                                      int timeStamp =
                                          now.millisecondsSinceEpoch;
                                      List<String> splitDateHour = now
                                          .toString()
                                          .split(".")[0]
                                          .split(":");
                                      String dateHour =
                                          "${splitDateHour[0]}:${splitDateHour[1]}";

                                      /// Add a notification in the popup notifications
                                      BlocProvider.of<NotificationCubit>(
                                              context)
                                          .addNewNotification(
                                        userIdsToNotify: membersToNotify,
                                        sourceName: currentUser.name,
                                        thingToOpenId: groupId,
                                        thingToNotifyName: groupName,
                                        dateHour: dateHour,
                                        timestamp: timeStamp,
                                        notificationsJoinGroup: true,
                                        public: false,
                                      );

                                      /// Send a Push Notification to added users
                                      BlocProvider.of<UserBloc>(context)
                                          .sendPushNotificationsToUsers(
                                        userIdsToNotify: membersToNotify,
                                        title: currentUser.name +
                                            Constants.titleNotificationGroup,
                                        body: Constants.bodyNotificationGroup +
                                            groupName,
                                        notificationsJoinGroup: true,
                                      );
                                    }
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status ==
                                      ModifyGroupStatus.initial) {
                                    return Center(
                                      child: BlocBuilder<RequiredFieldsCubit,
                                          RequiredFieldsState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              RequiredFieldsStatus.completed) {
                                            return TapFadeText(
                                              onTap: () async {
                                                await _tapDone(
                                                    context, currentUser);
                                              },
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                            );
                                          } else {
                                            return TapFadeText(
                                              onTap: () {},
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                              disabled: true,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  } else if (state.status ==
                                      ModifyGroupStatus.error) {
                                    return const Center(
                                      child:
                                          CustomText(text: "An error occured"),
                                    );
                                  } else {
                                    return const Center(
                                        child: OurCircularProgressIndicator());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
