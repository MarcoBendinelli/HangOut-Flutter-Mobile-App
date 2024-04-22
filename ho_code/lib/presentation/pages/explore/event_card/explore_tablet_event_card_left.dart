import 'package:flutter/material.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class ExploreTabletEventCardLeft extends StatelessWidget {
  final Event _event;

  const ExploreTabletEventCardLeft({super.key, required Event event})
      : _event = event;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _event.photo != ""
            ? Container(
                width: TabletConstants.resizeW(250),
                height: TabletConstants.resizeH(107.5),
                color: Colors.transparent,
              )
            : const SizedBox(),
        Container(
          width: TabletConstants.resizeW(250),
          height: _event.photo != ""
              ? TabletConstants.resizeH(107.5)
              : TabletConstants.resizeH(215),
          padding: TabletConstants.insideCardPadding(),
          decoration: BoxDecoration(
            borderRadius: _event.photo != ""
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(TabletConstants.resizeR(20)))
                : BorderRadius.horizontal(
                    left: Radius.circular(TabletConstants.resizeR(20))),
            color: CategoryColors.getColor(_event.category),
          ),
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              SizedBox(
                width: TabletConstants.resizeW(150),
                child: CustomText(
                  text: _event.name,
                  fontWeight: Fonts.bold,
                  fontFamily: "Raleway",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  size: TabletConstants.resizeR(24),
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
                  size: TabletConstants.privateIconExploreCardDimension(),
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
