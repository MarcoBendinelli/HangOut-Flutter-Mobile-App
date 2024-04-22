import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/pages/explore/event_card/explore_event_card_left.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';

class ExploreEventCard extends StatelessWidget {
  final Event _event;

  const ExploreEventCard({super.key, required Event event}) : _event = event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(bottom: Constants.spaceBtwCards.h),
        height: 175.h,
        decoration: BoxDecoration(
          boxShadow: [
            Constants.boxShadow(context),
          ],
          //
          borderRadius: BorderRadius.circular(20.r),
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
            ExploreEventCardLeft(
              event: _event,
            ),
            Expanded(
              child: Container(
                height: 175.h,
                // color: Colors.white,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(20.r),
                  ),
                  color: Theme.of(context).cardColor,
                ),
                child: Padding(
                  padding: Constants.insideCardPadding,
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
                            size: 36.r,
                            fontFamily: "Inter",
                            fontWeight: Fonts.semiBold,
                          ),
                          CustomText(
                              text: "${_event.getMonth()} ${_event.getYear()}",
                              fontFamily: "Inter",
                              size: 10.r,
                              fontWeight: Fonts.bold),
                          SizedBox(
                            height: 5.0.h,
                          ),
                          CustomText(
                            text: _event.getDayName(),
                            fontFamily: "Inter",
                            size: 10.r,
                            fontWeight: Fonts.light,
                          ),
                          SizedBox(
                            height: 5.0.h,
                          ),
                          CustomText(
                              text: _event.getHour(),
                              fontFamily: "Inter",
                              size: 12.r,
                              fontWeight: Fonts.regular),
                        ],
                      ),
                      CustomText(
                        text: "${_event.numParticipants} Participants",
                        fontWeight: Fonts.regular,
                        size: 10.r,
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
