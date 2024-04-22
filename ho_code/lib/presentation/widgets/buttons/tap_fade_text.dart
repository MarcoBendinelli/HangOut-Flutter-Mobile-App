import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

/// A tappable text button that fades colors when tapped and held.
class TapFadeText extends StatefulWidget {
  const TapFadeText(
      {Key? key,
      required this.onTap,
      required this.buttonColor,
      required this.titleButton,
      this.widthButton = 104,
      this.heightButton = 36,
      this.textSize = 20,
      this.disabled = false})
      : super(key: key);

  /// Callback to handle tap.
  final VoidCallback onTap;

  /// Color of the button.
  final Color buttonColor;

  /// Text of the button
  final String titleButton;

  /// Button's dimension
  final double widthButton;
  final double heightButton;

  /// Dimension of the text in the button
  final double textSize;

  /// True if the button must be disabled (grey)
  final bool disabled;

  @override
  State<TapFadeText> createState() => _TapFadeTextState();
}

class _TapFadeTextState extends State<TapFadeText> {
  late Color color = widget.buttonColor;

  void handleTapDown(TapDownDetails _) {
    setState(() {
      color = widget.buttonColor.withOpacity(0.6);
    });
  }

  void handleTapUp(TapUpDetails _) {
    setState(() {
      color = widget.buttonColor;
    });

    widget.onTap(); // Execute callback.
  }

  void handleVerticalDragStart(DragStartDetails _) {
    setState(() {
      color = widget.buttonColor.withOpacity(0.6);
    });
  }

  void handleVerticalDragEnd(DragEndDetails _) {
    setState(() {
      color = widget.buttonColor;
    });
    widget.onTap();
  }

  void doNothing(_) {}

  @override
  void didUpdateWidget(covariant TapFadeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.buttonColor != widget.buttonColor) {
      color = widget.buttonColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled ? doNothing : handleTapDown,
      onTapUp: widget.disabled ? doNothing : handleTapUp,
      onVerticalDragStart:
          widget.disabled ? doNothing : handleVerticalDragStart,
      onVerticalDragEnd: widget.disabled ? doNothing : handleVerticalDragEnd,
      child: getSize(context) == ScreenSize.normal
          ? _buildContainer(context)
          : _buildTabletContainer(context),
    );
  }

  _buildContainer(BuildContext context) {
    return Container(
      key: const Key("tap-fade-text-key"),
      width: widget.widthButton.w,
      height: widget.heightButton.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Theme.of(context).iconTheme.color!),
          color: widget.disabled ? Theme.of(context).cardColor : color),
      child: Center(
        child: CustomText(
          text: widget.titleButton,
          color: widget.disabled
              ? Theme.of(context).iconTheme.color!
              : Theme.of(context).cardColor,
          size: widget.textSize.r,
          fontFamily: "Inter",
          fontWeight: Fonts.medium,
        ),
      ),
    );
  }

  _buildTabletContainer(BuildContext context) {
    return Container(
      key: const Key("tap-fade-text-key"),
      width: PopupTabletConstants.resize(widget.widthButton),
      height: PopupTabletConstants.resize(widget.heightButton),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PopupTabletConstants.resize(20)),
          border: Border.all(color: Theme.of(context).iconTheme.color!),
          color: widget.disabled ? Theme.of(context).cardColor : color),
      child: Center(
        child: CustomText(
          text: widget.titleButton,
          color: widget.disabled
              ? Theme.of(context).iconTheme.color!
              : Theme.of(context).cardColor,
          size: PopupTabletConstants.resize(widget.textSize),
          fontFamily: "Inter",
          fontWeight: Fonts.medium,
        ),
      ),
    );
  }
}
