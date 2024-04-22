import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/pages/explore/event_card/explore_event_card.dart';
import 'package:hang_out_app/presentation/pages/explore/event_card/explore_tablet_event_card.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class ExploreEventCards extends StatelessWidget {
  final List<Event> _events;
  final String insertedUserLetters;
  final bool isPortrait;

  const ExploreEventCards(
      {super.key,
      required List<Event> events,
      required this.insertedUserLetters,
      this.isPortrait = false})
      : _events = events;

  @override
  Widget build(BuildContext context) {
    List<Event> filteredEvents = _events
        .where((event) => event.name.contains(insertedUserLetters))
        .toList();

    if (getSize(context) == ScreenSize.normal) {
      return _buildEventCards(filteredEvents);
    }
    return _buildTabletEventCards(filteredEvents);
  }

  Widget _buildEventCards(List<Event> filteredEvents) {
    if (filteredEvents.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: Constants.heightError),
        child: CustomText(
          size: 12.r,
          text: "No event found",
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            return ExploreEventCard(event: filteredEvents[index]);
          },
        ),
      );
    }
  }

  Widget _buildTabletEventCards(List<Event> filteredEvents) {
    if (filteredEvents.isEmpty) {
      return Padding(
        padding: isPortrait
            ? EdgeInsets.symmetric(
                vertical: TabletConstants.resizeH(250),
                horizontal: TabletConstants.resizeW(150))
            : EdgeInsets.only(left: TabletConstants.resizeW(390)),
        child: Center(
          child: CustomText(
            size: TabletConstants.resizeR(14),
            text: "No event found",
          ),
        ),
      );
    } else {
      return Expanded(
        child: MasonryGridView.count(
          scrollDirection: Axis.vertical,
          crossAxisCount: 2,
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            return ExploreTabletEventCard(event: filteredEvents[index]);
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
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        return ExploreEventCard(event: filteredEvents[index]);
      },
    ),
  ),
);
*/
