import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class MandatoryNote extends StatelessWidget {
  const MandatoryNote({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildNote(context);
    }
    return _buildTabletNote(context);
  }

  Widget _buildNote(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomText(
          text: "*",
          size: 14.r,
          color: Theme.of(context).hintColor,
        ),
        CustomText(
          text: " required fields",
          size: 12.r,
          color: Theme.of(context).hintColor,
        ),
      ],
    );
  }

  Widget _buildTabletNote(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomText(
          text: "*",
          size: TabletConstants.resizeR(20),
          color: Theme.of(context).hintColor,
        ),
        CustomText(
          text: " required fields",
          size: TabletConstants.resizeR(20),
          color: Theme.of(context).hintColor,
        ),
      ],
    );
  }
}
