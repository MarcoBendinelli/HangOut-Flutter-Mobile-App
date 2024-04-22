import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/choose_photo.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class TextPhotoRow extends StatefulWidget {
  final Function setNameCallback;
  final Function setImagePickedCallback;
  final String inputName;
  final String oldName;
  final String oldPhoto;
  final bool required;
  final int borderRadius;

  const TextPhotoRow(
      {Key? key,
      required this.setNameCallback,
      required this.inputName,
      required this.setImagePickedCallback,
      this.oldName = "",
      this.oldPhoto = "",
      this.required = false,
      this.borderRadius = 20})
      : super(key: key);

  @override
  State<TextPhotoRow> createState() => _TextPhotoRowState();
}

class _TextPhotoRowState extends State<TextPhotoRow> {
  int maxLengthGroupName = Constants.maxLengthGroupName;
  late final TextEditingController _textEditingController;
  int textLengthGroupName = 0;

  @override
  void initState() {
    _textEditingController = TextEditingController(text: widget.oldName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildTextPhotoRow(context);
    }
    return _buildTabletTextPhotoRow(context);
  }

  Widget _buildTextPhotoRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
                width: Constants.groupNameFieldWidth,
                child: TextField(
                  key: const Key("text-photo-textInput"),
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Max $maxLengthGroupName characters',
                    border: InputBorder.none,
                    counterText: "",
                  ),
                  textAlign: TextAlign.start,
                  onChanged: (groupName) {
                    widget.setNameCallback(groupName);
                    textLengthGroupName = groupName.length;
                  },
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: Fonts.bold,
                    // color: AppColors.blackColor,
                    fontSize: Constants.textDimensionGroupName,
                  ),
                  maxLength: maxLengthGroupName,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
            ),
          ],
        ),
        ChoosePhoto(
          oldPhoto: widget.oldPhoto,
          choosePhotoCallback: (image) {
            widget.setImagePickedCallback(image);
          },
          borderRadius: widget.borderRadius,
        ),
      ],
    );
  }

  Widget _buildTabletTextPhotoRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
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
                width: PopupTabletConstants.groupNameFieldWidth(),
                child: TextField(
                  key: const Key("text-photo-textInput"),
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Max $maxLengthGroupName characters',
                    border: InputBorder.none,
                    counterText: "",
                  ),
                  textAlign: TextAlign.start,
                  onChanged: (groupName) {
                    widget.setNameCallback(groupName);
                    textLengthGroupName = groupName.length;
                  },
                  style: const TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: Fonts.bold,
                    // color: AppColors.blackColor,
                    fontSize: Constants.textDimensionGroupName,
                  ),
                  maxLength: maxLengthGroupName,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
            ),
          ],
        ),
        ChoosePhoto(
          oldPhoto: widget.oldPhoto,
          choosePhotoCallback: (image) {
            widget.setImagePickedCallback(image);
          },
          borderRadius: widget.borderRadius,
        ),
      ],
    );
  }
}
