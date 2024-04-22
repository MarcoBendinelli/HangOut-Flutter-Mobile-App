import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';

import 'custom_text.dart';

class DateInNotificationsAndChat extends StatelessWidget {
  final String date;
  final bool hasBottomBorder;
  final double sizedBoxHeight;

  const DateInNotificationsAndChat({
    Key? key,
    required this.date,
    this.hasBottomBorder = true,
    this.sizedBoxHeight = 90.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return Container(
        decoration: BoxDecoration(
          border: hasBottomBorder
              ? Border(
                  bottom: BorderSide(
                    color: Theme.of(context).hintColor,
                    width: 1.0,
                  ),
                )
              : null,
        ),
        height: sizedBoxHeight.h,
        child: Center(
          child: CustomText(
            text: date,
            size: 12.r,
            fontFamily: "Raleway",
            fontWeight: Fonts.regular,
            textDecoration: TextDecoration.underline,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: hasBottomBorder
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).hintColor,
                  width: 1.0,
                ),
              )
            : null,
      ),
      height: PopupTabletConstants.resize(sizedBoxHeight),
      child: Center(
        child: CustomText(
          text: date,
          size: PopupTabletConstants.resize(14),
          fontFamily: "Raleway",
          fontWeight: Fonts.regular,
          textDecoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
