import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hang_out_app/business_logic/blocs/my_groups/groups_bloc.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/presentation/pages/groups/group_card/group_tablet_card.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/chat_tablet_popup.dart';
import 'group_card/group_card.dart';

class GroupCards extends StatelessWidget {
  const GroupCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        if (state is GroupsLoading) {
          return const Center(
            child: OurCircularProgressIndicator(),
          );
        } else if (state is GroupsLoaded) {
          if (state.groups.isEmpty) {
            return const Center(
              child: CustomText(
                text: "You don't have any groups yet!",
              ),
            );
          } else {
            state.groups.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
            if (getSize(context) == ScreenSize.normal) {
              return _buildGroupCards(state.groups);
            }
            return _buildTabletGroupCards(state.groups);
          }
        } else {
          return const Center(
            child: Text("An error occurred while loading cards"),
          );
        }
      },
    );
  }

  Widget _buildGroupCards(List<Group> groups) {
    return MasonryGridView.count(
      scrollDirection: Axis.vertical,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _buildGroupItem(index, groups[index]);
      },
      crossAxisCount: 2,
      mainAxisSpacing: Constants.spaceBtwCards.r,
      crossAxisSpacing: Constants.spaceBtwCards.r,
    );
  }

  Widget _buildTabletGroupCards(List<Group> groups) {
    return OrientationBuilder(builder: (context, orientation) {
      int crossAxisCount;

      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        crossAxisCount = 3;
      } else {
        crossAxisCount = 4;
      }
      return MasonryGridView.count(
        scrollDirection: Axis.vertical,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return _buildTabletGroupItem(index, groups[index]);
        },
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: TabletConstants.spaceBtwCardsGroupsPage(),
        crossAxisSpacing: TabletConstants.spaceBtwCardsGroupsPage(),
      );
    });
  }

  Widget _buildGroupItem(int index, Group group) {
    return Builder(builder: (context) {
      return InkWell(
        child: GroupCard(groupData: group),
        onTap: () async {
          if (context.mounted) {
            Navigator.push(
                context,
                CupertinoPageRoute<bool>(
                    builder: (_) => ChatView(
                          id: group.id,
                          isForTheGroup: true,
                          chatName: group.name,
                        )));
          }
        },
      );
    });
  }

  Widget _buildTabletGroupItem(int index, Group group) {
    return Builder(builder: (context) {
      return InkWell(
        child: GroupTabletCard(groupData: group),
        onTap: () async {
          if (context.mounted) {
            Navigator.of(context).push(HeroDialogRoute(
                builder: (newContext) => ChatTabletPopup(
                      heroTag: 'Chat view Popup',
                      id: group.id,
                      isForTheGroup: true,
                      chatName: group.name,
                    )));
          }
        },
      );
    });
  }
}

/*
To have the shade effect:

return ShaderMask(
  shaderCallback: (Rect rect) {
    return Constants.blurLinearGradient.createShader(rect);
  },
  // blendMode: BlendMode.darken,
  blendMode: BlendMode.dstOut,
  child: MasonryGridView.count(
    scrollDirection: Axis.vertical,
    itemCount: state.groups.length,
    itemBuilder: (context, index) {
      return _buildGroupItem(index, state.groups[index]);
    },
    crossAxisCount: 2,
    mainAxisSpacing: Constants.spaceBtwCards.h,
    crossAxisSpacing: Constants.spaceBtwCards.w,
  ),
);
*/