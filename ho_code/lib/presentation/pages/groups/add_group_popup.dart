import 'package:flutter/material.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/groups/add_group/add_group_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/notification/notification_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/required_fields/required_fields_cubit.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_return_and_name.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
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
class AddGroupPopup extends StatefulWidget {
  final String heroTag;

  const AddGroupPopup({Key? key, required this.heroTag}) : super(key: key);

  @override
  State<AddGroupPopup> createState() => _AddGroupPopupState();
}

class _AddGroupPopupState extends State<AddGroupPopup> {
  String newGroupName = "";
  String newGroupCaption = "";
  List<String> newGroupInterests = [];
  XFile? newGroupImage;
  bool newGroupPrivate = true;
  String newGroupId = "";

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AddGroupCubit>(
          create: (context) => AddGroupCubit(
              groupsRepository: context.read<MyGroupsRepository>()),
        ),
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(
              notificationsRepository: context.read<NotificationsRepository>(),
              userRepository: context.read<UserRepository>()),
        ),
        BlocProvider<RequiredFieldsCubit>(
          create: (context) => RequiredFieldsCubit(isForTheEvent: false),
        ),
      ],
      child: Builder(builder: (context) {
        UserData userData = context.select((UserBloc bloc) => bloc.state.user);
        OtherUser currentUser = OtherUser(
            id: userData.id,
            name: userData.name,
            photo: userData.photo,
            interests: userData.interests,
            description: userData.description);
        if (getSize(context) == ScreenSize.normal) {
          return _buildAddGroupPopup(context, currentUser);
        }
        return _buildTabletAddGroupPopup(context, currentUser);
      }),
    );
  }

  Widget _buildAddGroupPopup(BuildContext context, OtherUser currentUser) {
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
                      title: 'New Group',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: Constants.contentPopupPadding,
                          child: Column(
                            children: [
                              TextPhotoRow(
                                inputName: "Group Name",
                                setNameCallback: (insertedGroupName) {
                                  newGroupName = insertedGroupName;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateName(inputName: newGroupName);
                                },
                                setImagePickedCallback: (choseImage) {
                                  newGroupImage = choseImage;
                                },
                                required: true,
                                borderRadius: 60,
                              ),
                              const OurDivider(),
                              TextInputRow(
                                inputName: "Caption",
                                hintText: Constants.groupCaptionHint,
                                setTextCallback: (insertedGroupCaption) {
                                  newGroupCaption = insertedGroupCaption;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateCaption(
                                          inputCaption: newGroupCaption);
                                },
                                required: true,
                              ),
                              const OurDivider(),
                              const GroupMembersRow(),
                              const OurDivider(),
                              MultiCategoryInputRow(
                                inputName: "Our interests",
                                groupInterestsCallback: (selectedInterests) {
                                  newGroupInterests = selectedInterests;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateInterests(
                                          inputInterests: newGroupInterests);
                                },
                                required: true,
                              ),
                              const OurDivider(),
                              PrivacySelectorRow(setPrivacyCallback: (privacy) {
                                newGroupPrivate = privacy;
                              }),
                              const OurDivider(),
                              const MandatoryNote(),
                              SizedBox(
                                height: PopupTabletConstants
                                    .distanceBtwDoneNElement(),
                              ),
                              BlocConsumer<AddGroupCubit, AddGroupState>(
                                listener: (context, state) async {
                                  if (state.status == AddGroupStatus.success) {
                                    List<String> userIds =
                                        BlocProvider.of<MembersBloc>(context)
                                            .selectedUsers
                                            .map((e) => e.id)
                                            .toList();

                                    userIds.remove(currentUser.id);

                                    DateTime now = DateTime.now();
                                    int timeStamp = now.millisecondsSinceEpoch;
                                    List<String> splitDateHour =
                                        now.toString().split(".")[0].split(":");
                                    String dateHour =
                                        "${splitDateHour[0]}:${splitDateHour[1]}";

                                    if (userIds.isNotEmpty) {
                                      /// Add a notification in the popup notifications
                                      await BlocProvider.of<NotificationCubit>(
                                              context)
                                          .addNewNotification(
                                              public: false,
                                              userIdsToNotify: userIds,
                                              sourceName: currentUser.name,
                                              thingToOpenId: newGroupId,
                                              thingToNotifyName: newGroupName,
                                              dateHour: dateHour,
                                              timestamp: timeStamp,
                                              notificationsJoinGroup: true);

                                      /// Send a Push Notification to added users
                                      if (mounted) {
                                        await BlocProvider.of<UserBloc>(context)
                                            .sendPushNotificationsToUsers(
                                                userIdsToNotify: userIds,
                                                title: currentUser.name +
                                                    Constants
                                                        .titleNotificationGroup,
                                                body: Constants
                                                        .bodyNotificationGroup +
                                                    newGroupName,
                                                notificationsJoinGroup: true);
                                      }
                                    }

                                    if (!newGroupPrivate && mounted) {
                                      /// Add a notification for the interested users

                                      List<String> interestedIds =
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .getInterestedUsersToNotify(
                                                  newGroupEventInterests:
                                                      newGroupInterests);
                                      interestedIds = interestedIds
                                          .where((id) =>
                                              !BlocProvider.of<MembersBloc>(
                                                      context)
                                                  .selectedUsers
                                                  .map((e) => e.id)
                                                  .contains(id))
                                          .toList();

                                      if (mounted && interestedIds.isNotEmpty) {
                                        await BlocProvider.of<
                                                NotificationCubit>(context)
                                            .addNewNotification(
                                                public: true,
                                                userIdsToNotify: interestedIds,
                                                sourceName: currentUser.name,
                                                thingToOpenId: newGroupId,
                                                thingToNotifyName: newGroupName,
                                                dateHour: dateHour,
                                                timestamp: timeStamp,
                                                notificationsPublicGroup: true);
                                        if (mounted) {
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .sendPushNotificationsToUsers(
                                                  userIdsToNotify:
                                                      interestedIds,
                                                  title: currentUser.name +
                                                      Constants
                                                          .titleNotificationPublicGroup,
                                                  body: Constants
                                                          .bodyNotificationPublicGroup +
                                                      newGroupName,
                                                  notificationsPublicGroup:
                                                      true);
                                        }
                                      }
                                    }
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status == AddGroupStatus.initial) {
                                    return Center(
                                      child: BlocBuilder<RequiredFieldsCubit,
                                              RequiredFieldsState>(
                                          builder: (context, state) {
                                        if (state.status ==
                                            RequiredFieldsStatus.completed) {
                                          return TapFadeText(
                                            key: const Key("activeDone"),
                                            onTap: () async {
                                              await _tapDone(
                                                  context, currentUser);
                                            },
                                            buttonColor: Theme.of(context)
                                                .iconTheme
                                                .color!,
                                            titleButton: 'done',
                                            disabled: false,
                                          );
                                        } else {
                                          return TapFadeText(
                                            key: const Key("disabledDone"),
                                            onTap: () {},
                                            buttonColor: Theme.of(context)
                                                .iconTheme
                                                .color!,
                                            titleButton: 'done',
                                            disabled: true,
                                          );
                                        }
                                      }),
                                    );
                                  } else if (state.status ==
                                      AddGroupStatus.error) {
                                    return const Center(
                                      child: CustomText(
                                        text: "An Error occured",
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: OurCircularProgressIndicator(),
                                    );
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

  Future<void> _tapDone(BuildContext context, OtherUser currentUser) async {
    newGroupId = await BlocProvider.of<AddGroupCubit>(context).addGroup(
        groupCreator: currentUser,
        groupName: newGroupName,
        groupCaption: newGroupCaption,
        groupInterests: newGroupInterests,
        isPrivate: newGroupPrivate,
        image: newGroupImage,
        members: BlocProvider.of<MembersBloc>(context).selectedUsers);
  }

  Widget _buildTabletAddGroupPopup(
      BuildContext context, OtherUser currentUser) {
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
                      title: 'New Group',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: PopupTabletConstants.contentPopupPadding(),
                          child: Column(
                            children: [
                              TextPhotoRow(
                                inputName: "Group Name",
                                setNameCallback: (insertedGroupName) {
                                  newGroupName = insertedGroupName;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateName(inputName: newGroupName);
                                },
                                setImagePickedCallback: (choseImage) {
                                  newGroupImage = choseImage;
                                },
                                required: true,
                                borderRadius: 100,
                              ),
                              const OurDivider(),
                              TextInputRow(
                                inputName: "Caption",
                                hintText: Constants.groupCaptionHint,
                                setTextCallback: (insertedGroupCaption) {
                                  newGroupCaption = insertedGroupCaption;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateCaption(
                                          inputCaption: newGroupCaption);
                                },
                                required: true,
                              ),
                              const OurDivider(),
                              const GroupMembersRow(),
                              const OurDivider(),
                              MultiCategoryInputRow(
                                inputName: "Our interests",
                                groupInterestsCallback: (selectedInterests) {
                                  newGroupInterests = selectedInterests;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateInterests(
                                          inputInterests: newGroupInterests);
                                },
                                required: true,
                              ),
                              const OurDivider(),
                              PrivacySelectorRow(setPrivacyCallback: (privacy) {
                                newGroupPrivate = privacy;
                              }),
                              const OurDivider(),
                              const MandatoryNote(),
                              SizedBox(
                                height: Constants.distanceBtwDoneNElement,
                              ),
                              BlocConsumer<AddGroupCubit, AddGroupState>(
                                listener: (context, state) async {
                                  if (state.status == AddGroupStatus.success) {
                                    List<String> userIds =
                                        BlocProvider.of<MembersBloc>(context)
                                            .selectedUsers
                                            .map((e) => e.id)
                                            .toList();

                                    userIds.remove(currentUser.id);

                                    DateTime now = DateTime.now();
                                    int timeStamp = now.millisecondsSinceEpoch;
                                    List<String> splitDateHour =
                                        now.toString().split(".")[0].split(":");
                                    String dateHour =
                                        "${splitDateHour[0]}:${splitDateHour[1]}";

                                    if (userIds.isNotEmpty) {
                                      /// Add a notification in the popup notifications
                                      await BlocProvider.of<NotificationCubit>(
                                              context)
                                          .addNewNotification(
                                              public: false,
                                              userIdsToNotify: userIds,
                                              sourceName: currentUser.name,
                                              thingToOpenId: newGroupId,
                                              thingToNotifyName: newGroupName,
                                              dateHour: dateHour,
                                              timestamp: timeStamp,
                                              notificationsJoinGroup: true);

                                      /// Send a Push Notification to added users
                                      if (mounted) {
                                        await BlocProvider.of<UserBloc>(context)
                                            .sendPushNotificationsToUsers(
                                                userIdsToNotify: userIds,
                                                title: currentUser.name +
                                                    Constants
                                                        .titleNotificationGroup,
                                                body: Constants
                                                        .bodyNotificationGroup +
                                                    newGroupName,
                                                notificationsJoinGroup: true);
                                      }
                                    }

                                    if (!newGroupPrivate && mounted) {
                                      /// Add a notification for the interested users

                                      List<String> interestedIds =
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .getInterestedUsersToNotify(
                                                  newGroupEventInterests:
                                                      newGroupInterests);
                                      interestedIds = interestedIds
                                          .where((id) =>
                                              !BlocProvider.of<MembersBloc>(
                                                      context)
                                                  .selectedUsers
                                                  .map((e) => e.id)
                                                  .contains(id))
                                          .toList();

                                      if (mounted && interestedIds.isNotEmpty) {
                                        await BlocProvider.of<
                                                NotificationCubit>(context)
                                            .addNewNotification(
                                                public: true,
                                                userIdsToNotify: interestedIds,
                                                sourceName: currentUser.name,
                                                thingToOpenId: newGroupId,
                                                thingToNotifyName: newGroupName,
                                                dateHour: dateHour,
                                                timestamp: timeStamp,
                                                notificationsPublicGroup: true);
                                        if (mounted) {
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .sendPushNotificationsToUsers(
                                                  userIdsToNotify:
                                                      interestedIds,
                                                  title: currentUser.name +
                                                      Constants
                                                          .titleNotificationPublicGroup,
                                                  body: Constants
                                                          .bodyNotificationPublicGroup +
                                                      newGroupName,
                                                  notificationsPublicGroup:
                                                      true);
                                        }
                                      }
                                    }
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status == AddGroupStatus.initial) {
                                    return Center(
                                      child: BlocBuilder<RequiredFieldsCubit,
                                              RequiredFieldsState>(
                                          builder: (context, state) {
                                        if (state.status ==
                                            RequiredFieldsStatus.completed) {
                                          return TapFadeText(
                                            key: const Key("activeDone"),
                                            onTap: () async {
                                              await _tapDone(
                                                  context, currentUser);
                                            },
                                            buttonColor: Theme.of(context)
                                                .iconTheme
                                                .color!,
                                            titleButton: 'done',
                                            disabled: false,
                                          );
                                        } else {
                                          return TapFadeText(
                                            key: const Key("disabledDone"),
                                            onTap: () {},
                                            buttonColor: Theme.of(context)
                                                .iconTheme
                                                .color!,
                                            titleButton: 'done',
                                            disabled: true,
                                          );
                                        }
                                      }),
                                    );
                                  } else if (state.status ==
                                      AddGroupStatus.error) {
                                    return const Center(
                                      child: CustomText(
                                        text: "An Error occured",
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: OurCircularProgressIndicator(),
                                    );
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
