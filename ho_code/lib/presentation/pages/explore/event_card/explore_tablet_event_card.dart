import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/pages/explore/event_card/explore_tablet_event_card_left.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';

class ExploreTabletEventCard extends StatelessWidget {
  final Event _event;

  const ExploreTabletEventCard({super.key, required Event event})
      : _event = event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: TabletConstants.resizeH(215),
        decoration: BoxDecoration(
          boxShadow: [
            TabletConstants.boxShadow(context),
          ],
          //
          borderRadius: BorderRadius.circular(TabletConstants.resizeR(20)),
          image: _event.photo != ""
              ? DecorationImage(
                  fit: BoxFit.cover,
                  image: ImageManager.getImageProvider(_event.photo!),
                )
              : null,
        ),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ExploreTabletEventCardLeft(
              event: _event,
            ),
            Expanded(
              child: Container(
                height: TabletConstants.resizeH(215),
                // color: Colors.white,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(TabletConstants.resizeR(20)),
                  ),
                  color: Theme.of(context).cardColor,
                ),
                child: Padding(
                  padding: TabletConstants.insideCardPadding(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: _event.getDay(),
                            size: TabletConstants.resizeR(36),
                            fontFamily: "Inter",
                            fontWeight: Fonts.semiBold,
                          ),
                          CustomText(
                              text: "${_event.getMonth()} ${_event.getYear()}",
                              fontFamily: "Inter",
                              size: TabletConstants.resizeR(12),
                              fontWeight: Fonts.bold),
                          SizedBox(
                            height: TabletConstants.resizeH(5),
                          ),
                          CustomText(
                            text: _event.getDayName(),
                            fontFamily: "Inter",
                            size: TabletConstants.resizeR(12),
                            fontWeight: Fonts.light,
                          ),
                          SizedBox(
                            height: TabletConstants.resizeH(20),
                          ),
                          CustomText(
                              text: _event.getHour(),
                              fontFamily: "Inter",
                              size: TabletConstants.resizeR(16),
                              fontWeight: Fonts.regular),
                        ],
                      ),
                      CustomText(
                        text: "${_event.numParticipants} Participants",
                        fontWeight: Fonts.regular,
                        size: TabletConstants.resizeR(12),
                        fontFamily: "Inter",
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (newContext) => BlocProvider.value(
              value: BlocProvider.of<ExploreBloc>(context),
              child: SingleEventPopup(
                heroTag: 'exploreEventPopup',
                eventId: _event.id,
                fromExplore: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
