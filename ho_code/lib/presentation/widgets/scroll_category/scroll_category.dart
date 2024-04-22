import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

typedef StringCallback = void Function(String val);

class ScrollCategory extends StatefulWidget {
  final StringCallback callback;
  final int index;

  const ScrollCategory({super.key, required this.callback, this.index = 0});

  @override
  State<ScrollCategory> createState() => _ScrollCategoryState();
}

class _ScrollCategoryState extends State<ScrollCategory> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.index;
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
              height: Constants.heightInterest,
              width: Constants.widthInterest,
              decoration: BoxDecoration(
                border: index == selectedIndex
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
                  color: index == selectedIndex
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                ),
              ),
            ),
            onTap: () {
              _onTap(category, index);
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

  void _onTap(MapEntry<String, Color> category, int index) {
    widget.callback(category.key);
    setState(() {
      selectedIndex = index;
    });
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
              height: PopupTabletConstants.heightInterest(),
              width: PopupTabletConstants.widthInterest(),
              decoration: BoxDecoration(
                border: index == selectedIndex
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
                  color: index == selectedIndex
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  size: PopupTabletConstants.iconDimension(),
                ),
              ),
            ),
            onTap: () {
              _onTap(category, index);
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
}
