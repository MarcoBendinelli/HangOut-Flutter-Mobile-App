import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class EventCardTop extends StatelessWidget {
  final Event _eventData;

  const EventCardTop(this._eventData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      padding: Constants.insideCardPadding,
      // width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: _eventData.getDay(),
                size: 36.r,
                fontFamily: "Inter",
              ),
              Icon(
                _eventData.private ? AppIcons.private : AppIcons.public,
                size: Constants.iconDimension,
              ),
            ],
          ),
          CustomText(
            text: "${_eventData.getMonth()} ${_eventData.getYear()}",
            fontFamily: "Inter",
            size: 10.r,
            fontWeight: Fonts.bold,
          ),
          CustomText(
            text: _eventData.getDayName(),
            fontFamily: "Inter",
            size: 10.r,
            fontWeight: Fonts.light,
          ),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              CustomText(
                text: _eventData.getHour(),
                fontFamily: "Inter",
                size: 12.r,
                fontWeight: Fonts.bold,
              ),
            ],
          )
        ],
      ),
    );
  }
}
