import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';

class OurCircularProgressIndicator extends StatelessWidget {
  const OurCircularProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      strokeWidth: 2.0,
      color: AppColors.almostBlackColor,
    );
  }
}
