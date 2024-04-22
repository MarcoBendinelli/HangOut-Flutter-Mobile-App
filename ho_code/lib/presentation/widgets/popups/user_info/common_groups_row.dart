import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/profile/profile_bloc.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';

class CommonGroupsRow extends StatelessWidget {
  const CommonGroupsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is CommonGroupsLoaded) {
          if (state.groups.isEmpty) {
            return const SizedBox();
          } else {
            if (getSize(context) == ScreenSize.normal) {
              return _buildRow(state);
            }
            return _buildTabletRow(state);
          }
        } else if (state is CommonGroupsLoading) {
          return const OurCircularProgressIndicator();
        } else {
          return const Text("Error");
        }
      },
    );
  }

  Widget _buildRow(CommonGroupsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "Groups in common:",
          size: 14.h,
          fontWeight: Fonts.bold,
          fontFamily: "Raleway",
        ),
        Padding(
          padding: EdgeInsets.only(top: Constants.spaceBtwTitleNListView),
          child: SizedBox(
            height: Constants.membersListViewHeightGroups,
            width: Constants.membersListViewWidthGroups,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              scrollDirection: Axis.horizontal,
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                return _buildCommonGroupItem(state.groups[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletRow(CommonGroupsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "Groups in common:",
          size: PopupTabletConstants.textDimensionTitle(),
          fontWeight: Fonts.bold,
          fontFamily: "Raleway",
        ),
        Padding(
          padding: EdgeInsets.only(
              top: PopupTabletConstants.spaceBtwInterestsNMembers()),
          child: SizedBox(
            height: PopupTabletConstants.membersListViewHeightGroups(),
            width: PopupTabletConstants.membersListViewWidthGroupsGeneral(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: PopupTabletConstants.resize(2)),
              scrollDirection: Axis.horizontal,
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                return _buildTabletCommonGroupItem(state.groups[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildCommonGroupItem(Group group) {
  return Padding(
    padding: EdgeInsets.only(right: Constants.spaceBtwElementsInListView),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        group.photo == ""
            ? Constants.noProfileImageInMembersGroup
            : CircleAvatar(
                backgroundImage: ImageManager.getImageProvider(group.photo!),
                radius: Constants.avatarDimensionInMembersGroup,
              ),
        SizedBox(
          width: 40.w,
          child: Center(
            child: CustomText(
              text: group.name,
              size: 10,
              fontFamily: "Inter",
              fontWeight: Fonts.regular,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ],
    ),
  );
}

Widget _buildTabletCommonGroupItem(Group group) {
  return Padding(
    padding: EdgeInsets.only(
        right: PopupTabletConstants.spaceBtwElementsInListView()),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        group.photo == ""
            ? PopupTabletConstants.noProfileImageInMembersGroup()
            : CircleAvatar(
                backgroundImage: ImageManager.getImageProvider(group.photo!),
                radius: PopupTabletConstants.avatarDimensionInMembersGroup(),
              ),
        SizedBox(
          width: PopupTabletConstants.resize(80),
          child: Center(
            child: CustomText(
              text: group.name,
              size: PopupTabletConstants.textDimensionCategory(),
              fontFamily: "Inter",
              fontWeight: Fonts.regular,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ],
    ),
  );
}
