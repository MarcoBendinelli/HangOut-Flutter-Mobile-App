import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';

typedef StringCallback = void Function(List<String> val);

class GroupSelector extends StatefulWidget {
  final StringCallback callback;

  const GroupSelector({super.key, required this.callback});

  @override
  State<GroupSelector> createState() => _GroupSelectorState();
}

class _GroupSelectorState extends State<GroupSelector> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    String currentUserId =
        context.select((UserBloc bloc) => bloc.state.user.id);
    return BlocBuilder<MembersBloc, MembersState>(
      builder: (context, state) {
        if (state is GroupsLoaded) {
          if (getSize(context) == ScreenSize.normal) {
            return _buildLoadedGroupselector(state, currentUserId);
          }
          return _buildTabletLoadedGroupselector(state, currentUserId);
        } else {
          return const OurCircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildLoadedGroupselector(GroupsLoaded state, String currentUserId) {
    return SizedBox(
      height: Constants.interestsListViewHeight,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        scrollDirection: Axis.horizontal,
        itemCount: state.groups.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(index, state.groups, currentUserId);
        },
      ),
    );
  }

  Widget _buildTabletLoadedGroupselector(
      GroupsLoaded state, String currentUserId) {
    return SizedBox(
      height: PopupTabletConstants.interestsListViewHeight(),
      child: ListView.builder(
        padding:
            EdgeInsets.symmetric(horizontal: PopupTabletConstants.resize(2)),
        scrollDirection: Axis.horizontal,
        itemCount: state.groups.length,
        itemBuilder: (context, index) {
          return _buildTabletCategoryItem(index, state.groups, currentUserId);
        },
      ),
    );
  }

  Widget _buildCategoryItem(
      int index, List<Group> groups, String currentUserId) {
    return Padding(
      padding: EdgeInsets.only(right: Constants.spaceBtwElementsInListView),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: index == selectedIndex
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
              radius: Constants.avatarDimensionNewGroup,
              child: CircleAvatar(
                backgroundImage: groups[index].photo != ""
                    ? ImageManager.getImageProvider(groups[index].photo!)
                    : const AssetImage("assets/images/group_no_image.png"),
                radius: Constants.avatarDimensionNewGroup - 2,
                backgroundColor: AppColors.whiteColor,

                /// Here we must not use the theme
              ),
            ),
            SizedBox(
              width: Constants.avatarDimensionNewGroup * 2,
              child: Center(
                child: CustomText(
                  text: groups[index].name,
                  overflow: TextOverflow.ellipsis,
                  size: 10.r,
                  fontFamily: "Inter",
                  fontWeight: Fonts.regular,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _selectGroup(groups, index, currentUserId);
        },
      ),
    );
  }

  void _selectGroup(List<Group> groups, int index, String currentUserId) {
    if (selectedIndex == index) {
      List<String> members = [];
      widget.callback(members);
      setState(() {
        selectedIndex = -1;
      });
    } else {
      List<String> members = groups[index].members!;
      members.remove(currentUserId);
      widget.callback(members);
      setState(() {
        selectedIndex = index;
      });
    }
  }

  Widget _buildTabletCategoryItem(
      int index, List<Group> groups, String currentUserId) {
    return Padding(
      padding: EdgeInsets.only(
          right: PopupTabletConstants.spaceBtwElementsInListView()),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: index == selectedIndex
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
              radius: PopupTabletConstants.avatarDimensionNewGroup(),
              child: CircleAvatar(
                backgroundImage: groups[index].photo != ""
                    ? ImageManager.getImageProvider(groups[index].photo!)
                    : const AssetImage("assets/images/group_no_image.png"),
                radius: PopupTabletConstants.avatarDimensionNewGroup() - 2,
                backgroundColor: AppColors.whiteColor,

                /// Here we must not use the theme
              ),
            ),
            SizedBox(
              width: PopupTabletConstants.avatarDimensionNewGroup() * 2,
              child: Center(
                child: CustomText(
                  text: groups[index].name,
                  overflow: TextOverflow.ellipsis,
                  size: PopupTabletConstants.textDimensionCategory(),
                  fontFamily: "Inter",
                  fontWeight: Fonts.regular,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _selectGroup(groups, index, currentUserId);
        },
      ),
    );
  }
}
