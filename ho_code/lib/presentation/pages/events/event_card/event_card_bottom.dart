import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class EventCardBottom extends StatelessWidget {
  final Event _eventData;

  const EventCardBottom(
    this._eventData, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      // width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        color: CategoryColors.getColor(_eventData.category),
      ),
      padding: Constants.insideCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: _eventData.name,
            size: 24.r,
            fontFamily: "Raleway",
            fontWeight: Fonts.bold,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            color: _eventData.category == "other"
                ? AppColors.whiteColor
                : AppColors.blackColor,
          ),
          CustomText(
            text: "${_eventData.numParticipants} Participants",
            size: 10.r,
            fontFamily: "Inter",
            fontWeight: Fonts.regular,
            color: _eventData.category == "other"
                ? AppColors.whiteColor
                : AppColors.blackColor,
          ),
        ],
      ),
    );
  }
}
