import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/profile/profile_bloc.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/user_info/user_info.dart';
import 'package:hang_out_app/presentation/utils/animations/from_right_page_route.dart';

class Members extends StatelessWidget {
  final int nParticipants;
  final String text;
  final Widget buttonWidget;
  final bool isForTheGroup;
  final bool isForTheGeneralPopup;

  const Members(
      {super.key,
      required this.nParticipants,
      required this.text,
      this.buttonWidget = const SizedBox(),
      this.isForTheGroup = false,
      this.isForTheGeneralPopup = false});

  @override
  Widget build(BuildContext context) {
    String currentUserId = context.select((AppBloc bloc) => bloc.state.user.id);
    if (getSize(context) == ScreenSize.normal) {
      return _builMembers(currentUserId);
    }
    return _buildTabletMembers(currentUserId);
  }

  void _onTap(BuildContext context, String currentUserId, OtherUser user) {
    if (context.mounted) {
      if (currentUserId != user.id) {
        Navigator.of(context).push(
          FromRightPageRoute(
            builder: (BuildContext context) => BlocProvider(
              create: (context) => ProfileBloc(
                  groupsRepository: context.read<MyGroupsRepository>())
                ..add(LoadGroupsInCommon(
                    firstId: currentUserId, secondId: user.id)),
              child: UserInfo(heroTag: 'heroTag', user: user),
            ),
          ),
        );
      }
    }
  }

  Widget _builMembers(String currentUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: '$nParticipants $text:',
              size: Constants.textDimensionTitle,
              fontWeight: Fonts.bold,
              fontFamily: "Raleway",
            ),
          ],
        ),
        SizedBox(
          height: Constants.spaceBtwTitleNListView,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<MembersBloc, MembersState>(
              builder: (context, state) {
                if (state is MembersLoaded) {
                  return SizedBox(
                    height: isForTheGroup
                        ? Constants.membersListViewHeightGroups
                        : Constants.membersListViewHeight,
                    width: isForTheGeneralPopup
                        ? Constants.membersListViewWidth
                        : isForTheGroup
                            ? Constants.membersListViewWidthGroups
                            : Constants.membersListViewWidth,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.members.length,
                      itemBuilder: (context, index) {
                        return _buildMemberItem(
                            state.members[index], currentUserId);
                      },
                    ),
                  );
                } else if (state is MembersLoading) {
                  return const OurCircularProgressIndicator();
                } else {
                  return SizedBox(height: 62.h);
                }
              },
            ),
            buttonWidget
          ],
        ),
      ],
    );
  }

  Widget _buildTabletMembers(String currentUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: '$nParticipants $text:',
              size: PopupTabletConstants.textDimensionTitle(),
              fontWeight: Fonts.bold,
              fontFamily: "Raleway",
            ),
          ],
        ),
        SizedBox(
          height: PopupTabletConstants.spaceBtwTitleNListView(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<MembersBloc, MembersState>(
              builder: (context, state) {
                if (state is MembersLoaded) {
                  return SizedBox(
                    height: isForTheGroup
                        ? PopupTabletConstants.membersListViewHeightGroups()
                        : PopupTabletConstants.membersListViewHeight(),
                    width: isForTheGeneralPopup
                        ? PopupTabletConstants
                            .membersListViewWidthGroupsGeneral()
                        : isForTheGroup
                            ? PopupTabletConstants
                                .membersListViewWidthGroupsAddModify()
                            : PopupTabletConstants.membersListViewWidth(),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.members.length,
                      itemBuilder: (context, index) {
                        return _buildTabletMemberItem(
                            state.members[index], currentUserId);
                      },
                    ),
                  );
                } else if (state is MembersLoading) {
                  return const OurCircularProgressIndicator();
                } else {
                  return SizedBox(height: PopupTabletConstants.resize(62));
                }
              },
            ),
            buttonWidget
          ],
        ),
      ],
    );
  }

  Widget _buildMemberItem(OtherUser user, String currentUserId) {
    return Builder(builder: (context) {
      return InkWell(
        child: Padding(
          padding: EdgeInsets.only(
              right: isForTheGroup
                  ? Constants.spaceBtwElementsInListViewGroup
                  : Constants.spaceBtwElementsInListView),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              user.photo == ""
                  ? isForTheGroup
                      ? Constants.noProfileImageInMembersGroup
                      : Constants.noProfileImageInMembers
                  : CircleAvatar(
                      backgroundImage:
                          ImageManager.getImageProvider(user.photo),
                      radius: isForTheGroup
                          ? Constants.avatarDimensionInMembersGroup
                          : Constants.avatarDimensionInMembers,
                    ),
              SizedBox(
                width: 40.w,
                child: Center(
                  child: CustomText(
                    text: user.name,
                    size: 10,
                    fontFamily: "Inter",
                    fontWeight: Fonts.regular,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          _onTap(context, currentUserId, user);
        },
      );
    });
  }

  Widget _buildTabletMemberItem(OtherUser user, String currentUserId) {
    return Builder(builder: (context) {
      return InkWell(
        child: Padding(
          padding: EdgeInsets.only(
              right: isForTheGroup
                  ? PopupTabletConstants.spaceBtwElementsInListViewGroup()
                  : PopupTabletConstants.spaceBtwElementsInListView()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              user.photo == ""
                  ? isForTheGroup
                      ? PopupTabletConstants.noProfileImageInMembersGroup()
                      : PopupTabletConstants.noProfileImageInMembers()
                  : CircleAvatar(
                      backgroundImage:
                          ImageManager.getImageProvider(user.photo),
                      radius: isForTheGroup
                          ? PopupTabletConstants.avatarDimensionInMembersGroup()
                          : PopupTabletConstants.avatarDimensionInMembers(),
                    ),
              SizedBox(
                width: PopupTabletConstants.resize(90),
                child: Center(
                  child: CustomText(
                    text: user.name,
                    size: PopupTabletConstants.textDimensionCategory(),
                    fontFamily: "Inter",
                    fontWeight: Fonts.regular,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          _onTap(context, currentUserId, user);
        },
      );
    });
  }
}
