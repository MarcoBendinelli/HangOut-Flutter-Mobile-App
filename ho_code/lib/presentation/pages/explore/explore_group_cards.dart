import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/presentation/pages/explore/group_card/explore_group_card.dart';
import 'package:hang_out_app/presentation/pages/explore/group_card/explore_tablet_group_card.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class ExploreGroupCards extends StatelessWidget {
  final List<Group> _groups;
  final String insertedUserLetters;
  final bool isPortrait;

  const ExploreGroupCards({
    super.key,
    required List<Group> groups,
    required this.insertedUserLetters,
    this.isPortrait = false,
  }) : _groups = groups;

  @override
  Widget build(BuildContext context) {
    List<Group> filteredGroups = _groups
        .where((group) => group.name.contains(insertedUserLetters))
        .toList();

    if (getSize(context) == ScreenSize.normal) {
      return _buildGroupCards(filteredGroups);
    }
    return _buildTabletGroupCards(filteredGroups);
  }

  Widget _buildGroupCards(List<Group> filteredGroups) {
    if (filteredGroups.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: Constants.heightError),
        child: CustomText(
          size: 12.r,
          text: "No group found",
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: filteredGroups.length,
          itemBuilder: (context, index) {
            return ExploreGroupCard(group: filteredGroups[index]);
          },
        ),
      );
    }
  }

  Widget _buildTabletGroupCards(List<Group> filteredGroups) {
    if (filteredGroups.isEmpty) {
      return Padding(
        padding: isPortrait
            ? EdgeInsets.symmetric(
                vertical: TabletConstants.resizeH(250),
                horizontal: TabletConstants.resizeW(150))
            : EdgeInsets.only(left: TabletConstants.resizeW(390)),
        child: Center(
          child: CustomText(
            size: TabletConstants.resizeR(14),
            text: "No group found",
          ),
        ),
      );
    } else {
      return Expanded(
        child: MasonryGridView.count(
          scrollDirection: Axis.vertical,
          crossAxisCount: 2,
          itemCount: filteredGroups.length,
          itemBuilder: (context, index) {
            return ExploreTabletGroupCard(group: filteredGroups[index]);
          },
          mainAxisSpacing: TabletConstants.spaceBtwCards(),
          crossAxisSpacing: TabletConstants.spaceBtwCards(),
        ),
      );
    }
  }
}


/*
To apply the shade effect:

return Expanded(
  child: ShaderMask(
    shaderCallback: (Rect rect) {
      return Constants.blurLinearGradient.createShader(rect);
    },
    // blendMode: BlendMode.darken,
    blendMode: BlendMode.dstOut,
    child: ListView.builder(
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        return ExploreGroupCard(group: filteredGroups[index]);
      },
    ),
  ),
);
*/
