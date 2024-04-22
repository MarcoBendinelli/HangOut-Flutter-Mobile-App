import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/scroll_category/multi_scroll_category.dart';

class MultiCategoryInputRow extends StatefulWidget {
  final Function groupInterestsCallback;
  final List<String> oldGroupInterests;
  final String inputName;
  final bool required;

  const MultiCategoryInputRow(
      {Key? key,
      required this.groupInterestsCallback,
      required this.inputName,
      this.oldGroupInterests = const [],
      this.required = false})
      : super(key: key);

  @override
  State<MultiCategoryInputRow> createState() => _MultiCategoryInputRowState();
}

class _MultiCategoryInputRowState extends State<MultiCategoryInputRow> {
  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildRow(context);
    }
    return _buildTabletRow(context);
  }

  Widget _buildRow(BuildContext context) {
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
          padding: EdgeInsets.only(top: Constants.spaceBtwTitleNListView),
          child: MultiScrollCategory(
            callback: (List<String> selectedCategories) {
              widget.groupInterestsCallback(selectedCategories);
            },
            interests: widget.oldGroupInterests,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletRow(BuildContext context) {
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
          padding: EdgeInsets.only(
              top: PopupTabletConstants.spaceBtwTitleNListView()),
          child: MultiScrollCategory(
            callback: (List<String> selectedCategories) {
              widget.groupInterestsCallback(selectedCategories);
            },
            interests: widget.oldGroupInterests,
          ),
        ),
      ],
    );
  }
}
