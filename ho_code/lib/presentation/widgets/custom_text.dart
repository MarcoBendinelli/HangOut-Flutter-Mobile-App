import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';

class CustomText extends StatelessWidget {
  final Color? color;
  final String text;
  final double size;
  final TextOverflow? overflow;
  final int? maxLines;
  final String fontFamily;
  final FontWeight fontWeight;
  final TextDecoration? textDecoration;

  ///A default Raleway semiBold text
  const CustomText(
      {super.key,
      required this.text,
      this.color,
      this.maxLines,
      this.overflow,
      this.size = 12,
      this.fontWeight = Fonts.regular,
      this.fontFamily = "Inter",
      this.textDecoration});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
          fontFamily: fontFamily,
          //figma semibold
          fontWeight: fontWeight,
          color: color,
          fontSize: size,
          decoration: textDecoration),
    );
  }
}
