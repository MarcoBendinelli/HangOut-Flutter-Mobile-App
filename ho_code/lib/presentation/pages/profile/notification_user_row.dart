import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class NotificationUserRow extends StatefulWidget {
  final String notificationText;
  final bool initEnabled;
  final Function callback;
  final String notificationDescriptionFirstRow;
  final String notificationDescriptionSecondRow;

  const NotificationUserRow(
      {super.key,
      required this.notificationText,
      required this.callback,
      required this.initEnabled,
      this.notificationDescriptionFirstRow = "",
      this.notificationDescriptionSecondRow = ""});

  @override
  State<NotificationUserRow> createState() => _NotificationUserRowState();
}

class _NotificationUserRowState extends State<NotificationUserRow> {
  bool isEnabled = false;

  @override
  void initState() {
    isEnabled = widget.initEnabled;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildNotificationRow();
    }
    return _buildTabletNotificationRow();
  }

  Widget _buildNotificationRow() {
    return Padding(
      padding: EdgeInsets.only(top: Constants.spaceBtwTitleNTextField),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: widget.notificationText,
                size: 12,
                fontWeight: Fonts.regular,
                fontFamily: "Inter",
              ),
              widget.notificationDescriptionFirstRow == ""
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: widget.notificationDescriptionFirstRow,
                          size: 9,
                          fontWeight: Fonts.regular,
                          fontFamily: "Inter",
                        ),
                        CustomText(
                          text: widget.notificationDescriptionSecondRow,
                          size: 9,
                          fontWeight: Fonts.regular,
                          fontFamily: "Inter",
                        ),
                      ],
                    ),
            ],
          ),
          IconButton(
            key: UniqueKey(),
            padding: EdgeInsets.zero,
            iconSize: Constants.iconDimension,
            constraints: const BoxConstraints(),
            enableFeedback: false,
            onPressed: () {
              setState(() {
                isEnabled = !isEnabled;
              });
              widget.callback(isEnabled);
            },
            icon: isEnabled
                ? Icon(
                    AppIcons.radioButtonOn,
                    size: Constants.iconDimension,
                  )
                : Icon(
                    AppIcons.radioButtonOffOutline,
                    size: Constants.iconDimension,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletNotificationRow() {
    return Padding(
      padding: EdgeInsets.only(top: TabletConstants.spaceBtwTitleNTextField()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: widget.notificationText,
                size: TabletConstants.resizeR(20),
                fontWeight: Fonts.regular,
                fontFamily: "Inter",
              ),
              widget.notificationDescriptionFirstRow == ""
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: widget.notificationDescriptionFirstRow,
                          size: TabletConstants.resizeR(18),
                          fontWeight: Fonts.regular,
                          fontFamily: "Inter",
                        ),
                        CustomText(
                          text: widget.notificationDescriptionSecondRow,
                          size: TabletConstants.resizeR(18),
                          fontWeight: Fonts.regular,
                          fontFamily: "Inter",
                        ),
                      ],
                    ),
            ],
          ),
          IconButton(
            key: UniqueKey(),
            padding: EdgeInsets.zero,
            iconSize: TabletConstants.iconDimension(),
            constraints: const BoxConstraints(),
            enableFeedback: false,
            onPressed: () {
              setState(() {
                isEnabled = !isEnabled;
              });
              widget.callback(isEnabled);
            },
            icon: isEnabled
                ? Icon(
                    AppIcons.radioButtonOn,
                    size: TabletConstants.iconDimension(),
                  )
                : Icon(
                    AppIcons.radioButtonOffOutline,
                    size: TabletConstants.iconDimension(),
                  ),
          ),
        ],
      ),
    );
  }
}
