import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class PrivacySelectorRow extends StatefulWidget {
  final Function setPrivacyCallback;
  final bool oldPrivacy;

  const PrivacySelectorRow(
      {Key? key, required this.setPrivacyCallback, this.oldPrivacy = true})
      : super(key: key);

  @override
  State<PrivacySelectorRow> createState() => _PrivacySelectorRowState();
}

class _PrivacySelectorRowState extends State<PrivacySelectorRow> {
  bool private = true;

  @override
  void initState() {
    super.initState();
    private = widget.oldPrivacy;
  }

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildRow(context);
    }
    return _buildTabletRow(context);
  }

  Widget _buildRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "Public/Private:",
          fontFamily: "Raleway",
          size: Constants.textDimensionTitle,
          fontWeight: Fonts.bold,
        ),
        Row(
          children: [
            GestureDetector(
              key: const Key("public-selector"),
              child: Icon(
                private ? AppIcons.publicOutlined : AppIcons.public,
                size: Constants.iconDimension,
              ),
              onTap: () {
                _setPrivacy(false);
              },
            ),
            GestureDetector(
              key: const Key("private-selector"),
              child: Icon(
                private ? AppIcons.private : AppIcons.privateOutlined,
                size: Constants.iconDimension,
              ),
              onTap: () {
                _setPrivacy(true);
              },
            ),
          ],
        ),
      ],
    );
  }

  void _setPrivacy(bool privateValue) {
    setState(() {
      private = privateValue;
    });
    widget.setPrivacyCallback(private);
  }

  Widget _buildTabletRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "Public/Private:",
          fontFamily: "Raleway",
          size: PopupTabletConstants.textDimensionTitle(),
          fontWeight: Fonts.bold,
        ),
        Row(
          children: [
            GestureDetector(
              key: const Key("public-selector"),
              child: Icon(
                private ? AppIcons.publicOutlined : AppIcons.public,
                size: PopupTabletConstants.iconDimension(),
              ),
              onTap: () {
                _setPrivacy(false);
              },
            ),
            GestureDetector(
              key: const Key("private-selector"),
              child: Icon(
                private ? AppIcons.private : AppIcons.privateOutlined,
                size: PopupTabletConstants.iconDimension(),
              ),
              onTap: () {
                _setPrivacy(true);
              },
            ),
          ],
        ),
      ],
    );
  }
}
