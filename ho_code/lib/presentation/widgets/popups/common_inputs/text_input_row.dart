import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class TextInputRow extends StatefulWidget {
  final Function setTextCallback;
  final String oldText;
  final String inputName;
  final String hintText;
  final bool required;
  final bool enabled;

  const TextInputRow({
    Key? key,
    required this.setTextCallback,
    required this.inputName,
    this.hintText = "",
    this.oldText = "",
    this.required = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<TextInputRow> createState() => _TextInputRowState();
}

class _TextInputRowState extends State<TextInputRow> {
  int maxLengthCaption = Constants.maxLengthGroupCaption;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController(text: widget.oldText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildTextInputRow(context);
    }
    return _buildTabletTextInputRoww(context);
  }

  Widget _buildTextInputRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text: '${widget.inputName}:',
              size: Constants.textDimensionTitle,
              fontWeight: Fonts.bold,
              fontFamily: "Raleway",
            ),
            widget.required
                ? CustomText(
                    text: ' *',
                    size: Constants.textDimensionTitle,
                    fontWeight: Fonts.regular,
                    fontFamily: "Inter",
                  )
                : const SizedBox(),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: Constants.spaceBtwTitleNTextField),
          child: SizedBox(
            width: Constants.groupCaptionFieldWidth,
            child: TextField(
              key: const Key("Input_Row_Text_Field"),
              enabled: widget.enabled,
              controller: _textEditingController,
              decoration: InputDecoration(
                isDense: true,
                // hintText: "Write the caption's group here",
                hintText: widget.hintText,
                border: InputBorder.none,
                counterText: "",
                labelStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                ),
              ),
              textAlign: TextAlign.start,
              onChanged: (groupCaption) {
                widget.setTextCallback(groupCaption);
              },
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: Fonts.regular,
                // color: Theme.of(context).hintColor,
                fontSize: Constants.textDimensionCaptionName,
              ),
              maxLength: maxLengthCaption,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletTextInputRoww(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text: '${widget.inputName}:',
              size: PopupTabletConstants.textDimensionTitle(),
              fontWeight: Fonts.bold,
              fontFamily: "Raleway",
            ),
            widget.required
                ? CustomText(
                    text: ' *',
                    size: PopupTabletConstants.textDimensionTitle(),
                    fontWeight: Fonts.regular,
                    fontFamily: "Inter",
                  )
                : const SizedBox(),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: Constants.spaceBtwTitleNTextField),
          child: SizedBox(
            width: PopupTabletConstants.groupCaptionFieldWidth(),
            child: TextField(
              key: const Key("Input_Row_Text_Field"),
              enabled: widget.enabled,
              controller: _textEditingController,
              decoration: InputDecoration(
                isDense: true,
                // hintText: "Write the caption's group here",
                hintText: widget.hintText,
                border: InputBorder.none,
                counterText: "",
                labelStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                ),
              ),
              textAlign: TextAlign.start,
              onChanged: (groupCaption) {
                widget.setTextCallback(groupCaption);
              },
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: Fonts.regular,
                // color: Theme.of(context).hintColor,
                fontSize: PopupTabletConstants.textDimensionCaptionName(),
              ),
              maxLength: maxLengthCaption,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
        ),
      ],
    );
  }
}
