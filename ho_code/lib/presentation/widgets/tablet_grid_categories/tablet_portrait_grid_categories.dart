import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

typedef StringCallback = void Function(List<String> selectedCategories);

class TabletPortraitGridCategories extends StatefulWidget {
  final StringCallback callback;
  final List<String> interests;

  const TabletPortraitGridCategories(
      {super.key, required this.callback, this.interests = const []});

  @override
  State<TabletPortraitGridCategories> createState() =>
      _TabletPortraitGridCategoriesState();
}

class _TabletPortraitGridCategoriesState
    extends State<TabletPortraitGridCategories> {
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
    widget.callback(selectedIndexs.values.toList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRowCategories(0, 7, false),
        _buildRowCategories(7, 13, true),
      ],
    );
  }

  Widget _buildRowCategories(int start, int end, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: isLast
              ? TabletConstants.spaceBtwElementsInListView()
              : (TabletConstants.halfSpaceBtwElementsInListView())),
      child: Row(
        children: [
          for (int i = start; i < end; i++) _buildCategoryItem(i, i == end - 1),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(int index, bool isLast) {
    MapEntry<String, Color> category =
        CategoryColors.mapper.entries.elementAt(index);
    MapEntry<String, IconData> categoryIcon =
        CategoryIcons.mapper.entries.elementAt(index);
    return Padding(
      padding: EdgeInsets.only(
          right: isLast ? 0 : TabletConstants.spaceBtwElementsInListView()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            child: Container(
              key: const Key("scroll-rectangle"),
              height: TabletConstants.sideSquareInterest(),
              width: TabletConstants.sideSquareInterest(),
              decoration: BoxDecoration(
                border: selectedIndexs.containsKey(index)
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: TabletConstants.resizeW(2))
                    : null,
                color: category.key == "other"
                    ? CategoryColors.otherFilter
                    : category.value,
                borderRadius:
                    BorderRadius.circular(TabletConstants.resizeR(20)),
                boxShadow: [
                  TabletConstants.boxShadow(context),
                ],
              ),
              child: Center(
                child: Icon(
                  categoryIcon.value,
                  color: selectedIndexs.containsKey(index)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  size: TabletConstants.resizeR(30),
                ),
              ),
            ),
            onTap: () {
              setState(() {
                if (selectedIndexs.containsKey(index)) {
                  selectedIndexs.remove(index);
                } else {
                  if (selectedIndexs.length < 10) {
                    selectedIndexs.putIfAbsent(
                        index,
                        () =>
                            CategoryColors.mapper.entries.elementAt(index).key);
                  }
                }
              });
              widget.callback(selectedIndexs.values.toList());
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: TabletConstants.resizeH(10)),
            child: Center(
              child: CustomText(
                text: category.key,
                size: TabletConstants.textDimensionCategory(),
                fontFamily: "Inter",
                fontWeight: Fonts.regular,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
