import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

typedef StringCallback = void Function(List<String> selectedCategories);

class MultiScrollCategory extends StatefulWidget {
  final StringCallback callback;
  final List<String> interests;

  const MultiScrollCategory(
      {super.key,
      required this.callback,
      // this.interests,
      this.interests = const []});

  @override
  State<MultiScrollCategory> createState() => _MultiScrollCategoryState();
}

class _MultiScrollCategoryState extends State<MultiScrollCategory> {
  late Map<int, String> selectedIndexs;

  @override
  void initState() {
    selectedIndexs = <int, String>{};
    var mapper = CategoryColors.mapper;
    for (var i = 0; i < mapper.entries.length; i++) {
      if (widget.interests.contains(mapper.entries.elementAt(i).key)) {
        selectedIndexs.putIfAbsent(i, () => mapper.entries.elementAt(i).key);
      }
    }

    // selectedIndexs = widget.interests ?? <int, String>{};
    widget.callback(selectedIndexs.values.toList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildRow();
    }
    return _buildTabletRow();
  }

  Widget _buildRow() {
    return SizedBox(
      height: Constants.interestsListViewHeight,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        scrollDirection: Axis.horizontal,
        itemCount: CategoryColors.mapper.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(index);
        },
      ),
    );
  }

  Widget _buildTabletRow() {
    return SizedBox(
      height: PopupTabletConstants.interestsListViewHeight(),
      child: ListView.builder(
        padding:
            EdgeInsets.symmetric(horizontal: PopupTabletConstants.resize(2)),
        scrollDirection: Axis.horizontal,
        itemCount: CategoryColors.mapper.length,
        itemBuilder: (context, index) {
          return _buildTabletCategoryItem(index);
        },
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    MapEntry<String, Color> category =
        CategoryColors.mapper.entries.elementAt(index);
    MapEntry<String, IconData> categoryIcon =
        CategoryIcons.mapper.entries.elementAt(index);
    return Padding(
      padding: EdgeInsets.only(right: Constants.spaceBtwElementsInListView),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            child: Container(
              key: const Key("scroll-rectangle"),
              height: Constants.heightInterest,
              width: Constants.widthInterest,
              decoration: BoxDecoration(
                border: selectedIndexs.containsKey(index)
                    ? Border.all(
                        color: Theme.of(context).primaryColor, width: 2.w)
                    : null,
                color: category.key == "other"
                    ? CategoryColors.otherFilter
                    : category.value,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  Constants.boxShadow(context),
                ],
              ),
              child: Center(
                child: Icon(
                  categoryIcon.value,
                  color: selectedIndexs.containsKey(index)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                ),
              ),
            ),
            onTap: () {
              _onTap(index);
            },
          ),
          Center(
            child: CustomText(
              text: category.key,
              size: Constants.textDimensionCategory,
              fontFamily: "Inter",
              fontWeight: Fonts.regular,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletCategoryItem(int index) {
    MapEntry<String, Color> category =
        CategoryColors.mapper.entries.elementAt(index);
    MapEntry<String, IconData> categoryIcon =
        CategoryIcons.mapper.entries.elementAt(index);
    return Padding(
      padding: EdgeInsets.only(
          right: PopupTabletConstants.spaceBtwElementsInListView()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            child: Container(
              key: const Key("scroll-rectangle"),
              height: PopupTabletConstants.heightInterest(),
              width: PopupTabletConstants.widthInterest(),
              decoration: BoxDecoration(
                border: selectedIndexs.containsKey(index)
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: PopupTabletConstants.resize(2))
                    : null,
                color: category.key == "other"
                    ? CategoryColors.otherFilter
                    : category.value,
                borderRadius:
                    BorderRadius.circular(PopupTabletConstants.resize(20)),
                boxShadow: [
                  PopupTabletConstants.boxShadow(context),
                ],
              ),
              child: Center(
                child: Icon(
                  categoryIcon.value,
                  color: selectedIndexs.containsKey(index)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  size: PopupTabletConstants.iconDimension(),
                ),
              ),
            ),
            onTap: () {
              _onTap(index);
            },
          ),
          Center(
            child: CustomText(
              text: category.key,
              size: PopupTabletConstants.textDimensionCategory(),
              fontFamily: "Inter",
              fontWeight: Fonts.regular,
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    setState(() {
      if (selectedIndexs.containsKey(index)) {
        selectedIndexs.remove(index);
      } else {
        if (selectedIndexs.length < 10) {
          selectedIndexs.putIfAbsent(
              index, () => CategoryColors.mapper.entries.elementAt(index).key);
        }
      }
    });
    widget.callback(selectedIndexs.values.toList());
  }
}
