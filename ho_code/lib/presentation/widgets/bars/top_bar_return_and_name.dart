import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class TopBarReturnAndName extends StatelessWidget {
  final String title;

  const TopBarReturnAndName({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildTopBar(context);
    }
    return _buildTabletTopBar(context);
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 90.0.h,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Constants.borderRadius),
            topRight: Radius.circular(Constants.borderRadius)),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Constants.borderRadius),
              topRight: Radius.circular(Constants.borderRadius)),
          // color: AppColors.whiteColor,
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20.0.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TapFadeIcon(
                    key: const Key("close-popup"),
                    iconColor: Theme.of(context).iconTheme.color!,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    icon: AppIcons.arrowIosBackOutline,
                    size: Constants.iconDimension),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: CustomText(
                text: title,
                size: 20.r,
                fontFamily: 'Raleway',
                fontWeight: Fonts.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletTopBar(BuildContext context) {
    return Container(
      height: PopupTabletConstants.resize(90),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Constants.borderRadius),
            topRight: Radius.circular(Constants.borderRadius)),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(PopupTabletConstants.borderRadius()),
            topRight: Radius.circular(PopupTabletConstants.borderRadius()),
            // color: AppColors.whiteColor,
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Padding(
            //   padding: EdgeInsets.only(left: PopupTabletConstants.resize(20)),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: TapFadeIcon(
            //         iconColor: Theme.of(context).iconTheme.color!,
            //         onTap: () {
            //           Navigator.of(context).pop();
            //         },
            //         icon: AppIcons.arrowIosBackOutline,
            //         size: PopupTabletConstants.iconDimension()),
            //   ),
            // ),
            Align(
              alignment: Alignment.center,
              child: CustomText(
                text: title,
                size: PopupTabletConstants.resize(30),
                fontFamily: 'Raleway',
                fontWeight: Fonts.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
