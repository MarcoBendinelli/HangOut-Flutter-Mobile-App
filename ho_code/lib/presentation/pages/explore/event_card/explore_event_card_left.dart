import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class ExploreEventCardLeft extends StatelessWidget {
  final Event _event;

  const ExploreEventCardLeft({super.key, required Event event})
      : _event = event;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _event.photo != ""
            ? Container(
                width: 204.w,
                height: 87.h,
                color: Colors.transparent,
              )
            : const SizedBox(),
        Container(
          width: 204.w,
          height: _event.photo != "" ? 88.h : 175.h,
          padding: Constants.insideCardPadding,
          decoration: BoxDecoration(
            borderRadius: _event.photo != ""
                ? BorderRadius.only(bottomLeft: Radius.circular(20.r))
                : BorderRadius.horizontal(left: Radius.circular(20.r)),
            color: CategoryColors.getColor(_event.category),
          ),
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              SizedBox(
                width: 150.w,
                child: CustomText(
                  text: _event.name,
                  fontWeight: Fonts.bold,
                  fontFamily: "Raleway",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  size: 24.r,
                  color: _event.category == "other"
                      ? AppColors.whiteColor
                      : AppColors.blackColor,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  _event.private ? AppIcons.private : AppIcons.public,
                  color: _event.category == "other"
                      ? AppColors.whiteColor
                      : AppColors.almostBlackColor,
                  size: Constants.iconDimension,
                ),
              ),
            ],
          ),
        )
      ],
    );
    // : Container(
    //     width: 204.w,
    //     height: 175.h,
    //     padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.h),
    //     decoration: BoxDecoration(
    //       borderRadius:
    //           BorderRadius.horizontal(left: Radius.circular(20.r)),
    //       color: CategoryColors.getColor(event.category),
    //     ),
    //     child: Stack(
    //       children: [
    //         Center(
    //           child: CustomText(
    //             text: event.name,
    //             fontWeight: Fonts.bold,
    //             fontFamily: "Raleway",
    //             size: 24,
    //           ),
    //         ),
    //         Align(
    //           alignment: Alignment.bottomRight,
    //           child: Icon(AppIcons.private),
    //         ),
    //       ],
    //     ),
    //   );
  }
}
