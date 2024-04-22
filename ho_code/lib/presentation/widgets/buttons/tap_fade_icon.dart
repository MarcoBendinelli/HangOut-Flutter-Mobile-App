import 'package:flutter/material.dart';

/// A tappable icon that fades colors when tapped and held.
class TapFadeIcon extends StatefulWidget {
  const TapFadeIcon({
    Key? key,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    this.size = 0,
  }) : super(key: key);

  /// Callback to handle tap.
  final VoidCallback onTap;

  /// Color of the icon.
  final Color iconColor;

  /// Type of icon.
  final IconData icon;

  /// Icon size.
  final double size;

  @override
  State<TapFadeIcon> createState() => _TapFadeIconState();
}

class _TapFadeIconState extends State<TapFadeIcon> {
  late Color color = widget.iconColor;

  void handleTapDown(TapDownDetails _) {
    setState(() {
      color = widget.iconColor.withOpacity(0.6);
    });
  }

  void handleTapUp(TapUpDetails _) {
    setState(() {
      color = widget.iconColor;
    });

    widget.onTap(); // Execute callback.
  }

  void handleVerticalDragStart(DragStartDetails _) {
    setState(() {
      color = widget.iconColor.withOpacity(0.6);
    });
  }

  void handleVerticalDragEnd(DragEndDetails _) {
    setState(() {
      color = widget.iconColor;
    });
    widget.onTap();
  }

  @override
  void didUpdateWidget(covariant TapFadeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconColor != widget.iconColor) {
      color = widget.iconColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: handleTapDown,
      onTapUp: handleTapUp,
      onVerticalDragStart: handleVerticalDragStart,
      onVerticalDragEnd: handleVerticalDragEnd,
      child: Icon(
        widget.icon,
        color: color,
        size: widget.size,
      ),
    );
  }
}
