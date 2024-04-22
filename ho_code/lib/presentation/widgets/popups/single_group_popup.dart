import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/specific_group_event/specific_group_event_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/groups/delete_join_leave_group/delete_join_leave_group_cubit.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/animations/from_right_page_route.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/members.dart';
import 'package:hang_out_app/presentation/widgets/our_divider.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/presentation/utils/animations/custom_rect_tween.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/modify_group_popup.dart';

/// Popup card to see the info of the [Group]. Should be used in conjunction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroShowGroup].
class SingleGroupPopup extends StatefulWidget {
  final String heroTag;
  final String groupId;

  /// if the user is arriving from explore page join button is showed...else leave-delete
  final bool fromExplore;
  final bool fromNotification;

  const SingleGroupPopup({
    Key? key,
    required this.heroTag,
    required this.groupId,
    this.fromExplore = false,
    this.fromNotification = false,
  }) : super(key: key);

  @override
  State<SingleGroupPopup> createState() => _SingleGroupPopupState();
}

class _SingleGroupPopupState extends State<SingleGroupPopup> {
  bool alreadyPop = false;
  @override
  Widget build(BuildContext context) {
    UserData userData = context.select((UserBloc bloc) => bloc.state.user);
    OtherUser currentUser = OtherUser(
        id: userData.id,
        name: userData.name,
        photo: userData.photo,
        interests: userData.interests,
        description: userData.description);
    // String currentUserId = currentUser.id;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SpecificGroupEventBloc(
              eventsRepository: context.read<MyEventsRepository>(),
              groupsRepository: context.read<MyGroupsRepository>())
            ..add(LoadSpecificGroup(groupId: widget.groupId)),
        ),
        BlocProvider(
          create: (context) => DeleteJoinLeaveGroupCubit(
              groupsRepository: context.read<MyGroupsRepository>()),
        ),
        BlocProvider(
          create: (context) => MembersBloc(
              eventsRepository: context.read<MyEventsRepository>(),
              groupsRepository: context.read<MyGroupsRepository>(),
              userRepository: context.read<UserRepository>())
            ..add(LoadMembersInGroup(
                groupId: widget.groupId, currentUserId: currentUser.id)),
        )
      ],
      child: BlocConsumer<SpecificGroupEventBloc, SpecificGroupEventState>(
        listener: (context, state) {
          if (state is SpecificGroupEventError) {
            if (context.mounted) {
              alreadyPop = true;
              Navigator.of(context).pop();
              widget.fromExplore ? null : Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          if (state is SpecificGroupEventLoaded) {
            if (getSize(context) == ScreenSize.normal) {
              return _buildLoadedCard(state.group!, currentUser);
            }
            return _buildTabletLoadedCard(state.group!, currentUser);
          } else {
            return const Center(
              child: OurCircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadedCard(Group group, OtherUser currentUser) {
    return SafeArea(
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
                  borderRadius: BorderRadius.circular(Constants.borderRadius)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: Constants.contentPopupPadding,
                  child: SizedBox(
                    height: Constants.heightPopup,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TapFadeIcon(
                                              iconColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon:
                                                  AppIcons.arrowIosBackOutline,
                                              size: Constants.iconDimension),
                                          Row(
                                            children: [
                                              group.creatorId == currentUser.id
                                                  ? TapFadeIcon(
                                                      iconColor:
                                                          Theme.of(context)
                                                              .iconTheme
                                                              .color!,
                                                      onTap: () {
                                                        _tapOnEdit(context,
                                                            currentUser, group);
                                                      },
                                                      icon:
                                                          AppIcons.edit2Outline,
                                                      size: Constants
                                                          .iconDimension)
                                                  : SizedBox(
                                                      height: Constants
                                                          .iconDimension,
                                                      width: Constants
                                                          .iconDimension,
                                                    ),
                                              SizedBox(
                                                width: 5.0.w,
                                              ),
                                              Icon(
                                                  group.isPrivate
                                                      ? AppIcons.private
                                                      : AppIcons.public,
                                                  size: Constants.iconDimension)
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: Constants.spaceBtwTopNName,
                                      ),
                                      CustomText(
                                        text: group.name,
                                        size: 24.r,
                                        fontWeight: Fonts.bold,
                                        fontFamily: 'Raleway',
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15.0.w),
                                      child: group.photo == ""
                                          ? Constants.noImageInGroupPopup
                                          : CircleAvatar(
                                              backgroundImage:
                                                  ImageManager.getImageProvider(
                                                      group.photo!),
                                              radius: Constants
                                                  .avatarDimensionInPopup,
                                            ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15.0.h,
                            ),
                            CustomText(
                              text: group.caption,
                              size: 14.r,
                              fontWeight: Fonts.regular,
                              fontFamily: 'Inter',
                            ),
                            const OurDivider(),
                            CustomText(
                              text: 'Our interests:',
                              size: Constants.textDimensionTitle,
                              fontWeight: Fonts.bold,
                              fontFamily: "Raleway",
                            ),
                            SizedBox(
                              height: Constants.spaceBtwInterestsNMembers,
                            ),
                            SizedBox(
                              height: Constants.interestsListViewHeight,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                scrollDirection: Axis.horizontal,
                                itemCount: group.interests.length,
                                itemBuilder: (context, index) {
                                  return _buildCategoryItem(
                                      group.interests[index], context);
                                },
                              ),
                            ),
                            SizedBox(
                              height: Constants.spaceBtwInterestsNMembers,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: Constants.spaceBtwTitleNListView),
                              child: Members(
                                  nParticipants: group.numParticipants!,
                                  text: 'Members',
                                  isForTheGroup: true,
                                  isForTheGeneralPopup: true),
                            ),
                          ],
                        ),
                        BlocListener<DeleteJoinLeaveGroupCubit,
                            DeleteJoinLeaveGroupState>(
                          listener: (context, state) {
                            if (context.mounted && !alreadyPop) {
                              if (state.status ==
                                  DeleteJoinLeaveGroupStatus.success) {
                                Navigator.of(context).pop();
                                widget.fromExplore
                                    ? null
                                    : Navigator.of(context).pop();
                              }
                            }
                          },
                          child: widget.fromNotification
                              ? group.members!.contains(currentUser.id)
                                  ? Center(
                                      child: BlocBuilder<
                                          DeleteJoinLeaveGroupCubit,
                                          DeleteJoinLeaveGroupState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .initial) {
                                            return TapFadeText(
                                              onTap: () async {
                                                await _tapDeleteLeave(
                                                    currentUser,
                                                    group,
                                                    context);
                                              },
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'leave',
                                            );
                                          } else if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .loading) {
                                            return const OurCircularProgressIndicator();
                                          } else if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .success) {
                                            return const OurCircularProgressIndicator();
                                          } else {
                                            return const CustomText(
                                                text: "An error occurred");
                                          }
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: BlocBuilder<
                                          DeleteJoinLeaveGroupCubit,
                                          DeleteJoinLeaveGroupState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .initial) {
                                            return TapFadeText(
                                              onTap: () async {
                                                _tapJoin(context, currentUser);
                                              },
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'join',
                                            );
                                          } else if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .loading) {
                                            return const OurCircularProgressIndicator();
                                          } else if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .success) {
                                            return const OurCircularProgressIndicator();
                                          } else {
                                            return const CustomText(
                                                text: "An error occurred");
                                          }
                                        },
                                      ),
                                    )
                              : widget.fromExplore
                                  ? Center(
                                      child: BlocBuilder<
                                          DeleteJoinLeaveGroupCubit,
                                          DeleteJoinLeaveGroupState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .initial) {
                                            return TapFadeText(
                                              onTap: () async {
                                                _tapJoin(context, currentUser);
                                              },
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'join',
                                            );
                                          } else if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .loading) {
                                            return const OurCircularProgressIndicator();
                                          } else if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .success) {
                                            return const OurCircularProgressIndicator();
                                          } else {
                                            return const CustomText(
                                                text: "An error occurred");
                                          }
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: BlocBuilder<
                                          DeleteJoinLeaveGroupCubit,
                                          DeleteJoinLeaveGroupState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .initial) {
                                            return Center(
                                              child: TapFadeText(
                                                onTap: () async {
                                                  await _tapDeleteLeave(
                                                      currentUser,
                                                      group,
                                                      context);
                                                },
                                                buttonColor: Theme.of(context)
                                                    .iconTheme
                                                    .color!,
                                                titleButton: currentUser.id ==
                                                        group.creatorId
                                                    ? 'delete'
                                                    : "leave",
                                              ),
                                            );
                                          } else if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .loading) {
                                            return const OurCircularProgressIndicator();
                                          } else if (state.status ==
                                              DeleteJoinLeaveGroupStatus
                                                  .success) {
                                            return const OurCircularProgressIndicator();
                                          } else {
                                            return const CustomText(
                                                text: "An error occurred");
                                          }
                                        },
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
        ),
      ),
    );
  }

  Future<void> _tapDeleteLeave(
      OtherUser currentUser, Group group, BuildContext context) async {
    currentUser.id == group.creatorId
        ? await BlocProvider.of<DeleteJoinLeaveGroupCubit>(context)
            .deleteGroup(groupId: widget.groupId)
        : await BlocProvider.of<DeleteJoinLeaveGroupCubit>(context)
            .leaveGroup(groupId: widget.groupId, userId: currentUser.id);
  }

  void _tapJoin(BuildContext context, OtherUser currentUser) {
    BlocProvider.of<DeleteJoinLeaveGroupCubit>(context)
        .joinGroup(groupId: widget.groupId, user: currentUser);
    BlocProvider.of<ExploreBloc>(context)
        .add(LoadExploreGroups(userId: currentUser.id));
  }

  Widget _buildTabletLoadedCard(Group group, OtherUser currentUser) {
    // return OrientationBuilder(builder: (context, orientation) {
    //   // if (orientation == Orientation.portrait) {
    //   //   ScreenUtil.init(context, designSize: tabletPortraitSize);
    //   // } else {
    //   //   ScreenUtil.init(
    //   //     context,
    //   //     designSize: tabletLandscapeSize,
    //   //   );
    //   // }
    return SafeArea(
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
              child: Padding(
                // padding: Constants.contentPopupPadding,
                padding: PopupTabletConstants.contentPopupPadding(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TapFadeIcon(
                                      //   iconColor: Theme.of(context)
                                      //       .iconTheme
                                      //       .color!,
                                      //   onTap: () {
                                      //     Navigator.of(context).pop();
                                      //   },
                                      //   icon: AppIcons.arrowIosBackOutline,
                                      //   size: PopupTabletConstants
                                      //       .iconDimension(),
                                      // ),
                                      // Row(
                                      //   children: [
                                      group.creatorId == currentUser.id
                                          ? TapFadeIcon(
                                              iconColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              onTap: () {
                                                _tapOnEdit(context, currentUser,
                                                    group);
                                              },
                                              icon: AppIcons.edit2Outline,
                                              size: PopupTabletConstants
                                                  .iconDimension(),
                                            )
                                          : SizedBox(
                                              height: PopupTabletConstants
                                                  .iconDimension(),
                                              width: PopupTabletConstants
                                                  .iconDimension(),
                                            ),
                                      // SizedBox(
                                      //   width: PopupTabletConstants.resize(5),
                                      // ),
                                      Icon(
                                        group.isPrivate
                                            ? AppIcons.private
                                            : AppIcons.public,
                                        size: PopupTabletConstants
                                            .iconDimension(),
                                      )
                                    ],
                                    //   ),
                                    // ],
                                  ),
                                  SizedBox(
                                    height:
                                        PopupTabletConstants.spaceBtwTopNName(),
                                  ),
                                  CustomText(
                                    text: group.name,
                                    size: PopupTabletConstants
                                        .textDimensionBigTitle(),
                                    fontWeight: Fonts.bold,
                                    fontFamily: 'Raleway',
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: PopupTabletConstants.resize(15)),
                                  child: group.photo == ""
                                      ? PopupTabletConstants
                                          .noImageInGroupPopup()
                                      : CircleAvatar(
                                          backgroundImage:
                                              ImageManager.getImageProvider(
                                                  group.photo!),
                                          radius: PopupTabletConstants
                                              .avatarDimensionInPopup(),
                                        ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: PopupTabletConstants.resize(10),
                        ),
                        CustomText(
                          text: group.caption,
                          size: PopupTabletConstants.textDimensionDescription(),
                          fontWeight: Fonts.regular,
                          fontFamily: 'Inter',
                        ),
                        // const OurDivider(),
                        SizedBox(
                          height:
                              PopupTabletConstants.spaceBtwInterestsNMembers(),
                        ),
                        CustomText(
                          text: 'Our interests:',
                          size: PopupTabletConstants.textDimensionTitle(),
                          fontWeight: Fonts.bold,
                          fontFamily: "Raleway",
                        ),
                        SizedBox(
                          height:
                              PopupTabletConstants.spaceBtwInterestsNMembers(),
                        ),
                        SizedBox(
                          // height: 110.h,
                          height:
                              PopupTabletConstants.interestsListViewHeight(),
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: PopupTabletConstants.resize(2)),
                            scrollDirection: Axis.horizontal,
                            itemCount: group.interests.length,
                            itemBuilder: (context, index) {
                              return _buildTabletCategoryItem(
                                  group.interests[index], context);
                            },
                          ),
                        ),
                        SizedBox(
                          height:
                              PopupTabletConstants.spaceBtwInterestsNMembers(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: Constants.spaceBtwTitleNListView),
                          child: Members(
                              nParticipants: group.numParticipants!,
                              text: 'Members',
                              isForTheGroup: true,
                              isForTheGeneralPopup: true),
                        ),
                      ],
                    ),
                    BlocListener<DeleteJoinLeaveGroupCubit,
                        DeleteJoinLeaveGroupState>(
                      listener: (context, state) {
                        if (context.mounted && !alreadyPop) {
                          if (state.status ==
                              DeleteJoinLeaveGroupStatus.success) {
                            Navigator.of(context).pop();
                            widget.fromExplore
                                ? null
                                : Navigator.of(context).pop();
                          }
                        }
                      },
                      child: widget.fromNotification
                          ? group.members!.contains(currentUser.id)
                              ? Center(
                                  child: BlocBuilder<DeleteJoinLeaveGroupCubit,
                                      DeleteJoinLeaveGroupState>(
                                    builder: (context, state) {
                                      if (state.status ==
                                          DeleteJoinLeaveGroupStatus.initial) {
                                        return TapFadeText(
                                          onTap: () async {
                                            await _tapDeleteLeave(
                                                currentUser, group, context);
                                          },
                                          buttonColor: Theme.of(context)
                                              .iconTheme
                                              .color!,
                                          titleButton: 'leave',
                                        );
                                      } else if (state.status ==
                                          DeleteJoinLeaveGroupStatus.loading) {
                                        return const OurCircularProgressIndicator();
                                      } else if (state.status ==
                                          DeleteJoinLeaveGroupStatus.success) {
                                        return const OurCircularProgressIndicator();
                                      } else {
                                        return const CustomText(
                                            text: "An error occurred");
                                      }
                                    },
                                  ),
                                )
                              : Center(
                                  child: BlocBuilder<DeleteJoinLeaveGroupCubit,
                                      DeleteJoinLeaveGroupState>(
                                    builder: (context, state) {
                                      if (state.status ==
                                          DeleteJoinLeaveGroupStatus.initial) {
                                        return TapFadeText(
                                          onTap: () async {
                                            _tapJoin(context, currentUser);
                                          },
                                          buttonColor: Theme.of(context)
                                              .iconTheme
                                              .color!,
                                          titleButton: 'join',
                                        );
                                      } else if (state.status ==
                                          DeleteJoinLeaveGroupStatus.loading) {
                                        return const OurCircularProgressIndicator();
                                      } else if (state.status ==
                                          DeleteJoinLeaveGroupStatus.success) {
                                        return const OurCircularProgressIndicator();
                                      } else {
                                        return const CustomText(
                                            text: "An error occurred");
                                      }
                                    },
                                  ),
                                )
                          : widget.fromExplore
                              ? Center(
                                  child: BlocBuilder<DeleteJoinLeaveGroupCubit,
                                      DeleteJoinLeaveGroupState>(
                                    builder: (context, state) {
                                      if (state.status ==
                                          DeleteJoinLeaveGroupStatus.initial) {
                                        return TapFadeText(
                                          onTap: () async {
                                            _tapJoin(context, currentUser);
                                          },
                                          buttonColor: Theme.of(context)
                                              .iconTheme
                                              .color!,
                                          titleButton: 'join',
                                        );
                                      } else if (state.status ==
                                          DeleteJoinLeaveGroupStatus.loading) {
                                        return const OurCircularProgressIndicator();
                                      } else if (state.status ==
                                          DeleteJoinLeaveGroupStatus.success) {
                                        return const OurCircularProgressIndicator();
                                      } else {
                                        return const CustomText(
                                            text: "An error occurred");
                                      }
                                    },
                                  ),
                                )
                              : Center(
                                  child: BlocBuilder<DeleteJoinLeaveGroupCubit,
                                      DeleteJoinLeaveGroupState>(
                                    builder: (context, state) {
                                      if (state.status ==
                                          DeleteJoinLeaveGroupStatus.initial) {
                                        return Center(
                                          child: TapFadeText(
                                            onTap: () async {
                                              await _tapDeleteLeave(
                                                  currentUser, group, context);
                                            },
                                            buttonColor: Theme.of(context)
                                                .iconTheme
                                                .color!,
                                            titleButton: currentUser.id ==
                                                    group.creatorId
                                                ? 'delete'
                                                : "leave",
                                          ),
                                        );
                                      } else if (state.status ==
                                          DeleteJoinLeaveGroupStatus.loading) {
                                        return const OurCircularProgressIndicator();
                                      } else if (state.status ==
                                          DeleteJoinLeaveGroupStatus.success) {
                                        return const OurCircularProgressIndicator();
                                      } else {
                                        return const CustomText(
                                            text: "An error occurred");
                                      }
                                    },
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
    // });
  }

  void _tapOnEdit(BuildContext context, OtherUser currentUser, Group group) {
    Navigator.of(context).push(FromRightPageRoute(
        builder: (BuildContext context) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => MembersBloc(
                    eventsRepository: context.read<MyEventsRepository>(),
                    groupsRepository: context.read<MyGroupsRepository>(),
                    userRepository: context.read<UserRepository>(),
                  )..add(
                      LoadSelectedUsersAndGroupMembers(
                          groupId: widget.groupId,
                          currentUserId: currentUser.id),
                    ),
                ),
              ],
              child: ModifyGroupPopup(
                heroTag: 'ModifyGroup',
                currentGroup: group,
              ),
            )));
  }
}

Widget _buildCategoryItem(String interest, BuildContext context) {
  Color colorCategory = CategoryColors.getColor(interest);
  IconData iconCategory = CategoryIcons.mapper[interest]!;

  return Padding(
    padding: EdgeInsets.only(right: Constants.spaceBtwElementsInListView),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: Constants.heightInterest,
          width: Constants.widthInterest,
          decoration: BoxDecoration(
            color: colorCategory,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              Constants.boxShadow(context),
            ],
          ),
          child: Center(
            child: Icon(
              iconCategory,
              color: AppColors.whiteColor,
            ),
          ),
        ),
        Center(
          child: CustomText(
            text: interest,
            size: Constants.textDimensionCategory,
            fontFamily: "Inter",
            fontWeight: Fonts.regular,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTabletCategoryItem(String interest, BuildContext context) {
  Color colorCategory = CategoryColors.getColor(interest);
  IconData iconCategory = CategoryIcons.mapper[interest]!;

  return Padding(
    padding: EdgeInsets.only(
        right: PopupTabletConstants.spaceBtwElementsInListView()),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: PopupTabletConstants.heightInterest(),
          width: PopupTabletConstants.widthInterest(),
          decoration: BoxDecoration(
            color: colorCategory,
            borderRadius:
                BorderRadius.circular(PopupTabletConstants.resize(20)),
            boxShadow: [
              PopupTabletConstants.boxShadow(context),
            ],
          ),
          child: Center(
            child: Icon(
              iconCategory,
              color: AppColors.whiteColor,
              size: PopupTabletConstants.iconDimension(),
            ),
          ),
        ),
        Center(
          child: CustomText(
            text: interest,
            size: PopupTabletConstants.textDimensionCategory(),
            fontFamily: "Inter",
            fontWeight: Fonts.regular,
          ),
        ),
      ],
    ),
  );
}
