import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';

class OurDivider extends StatelessWidget {
  const OurDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0.h),
        child: Divider(
          color: Theme.of(context).dividerColor,
          thickness: 0.2,
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: TabletConstants.resizeH(15)),
      child: Divider(
        color: Theme.of(context).dividerColor,
        thickness: 0.2,
      ),
    );
  }
}
