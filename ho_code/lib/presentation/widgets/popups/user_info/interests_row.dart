import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class InterestsRow extends StatelessWidget {
  final OtherUser user;

  const InterestsRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildRow(user);
    }
    return _buildTabletRow(user);
  }

  Widget _buildRow(OtherUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 15.0.h,
        ),
        CustomText(
          text: "My interests:",
          size: Constants.textDimensionTitle,
          fontWeight: Fonts.bold,
          fontFamily: "Raleway",
        ),
        SizedBox(
          height: Constants.spaceBtwInterestsNMembers,
        ),
        SizedBox(
          height: Constants.interestsListViewHeight,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            scrollDirection: Axis.horizontal,
            itemCount: user.interests.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(user.interests[index], context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabletRow(OtherUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: PopupTabletConstants.resize(15),
        ),
        CustomText(
          text: "My interests:",
          size: PopupTabletConstants.textDimensionTitle(),
          fontWeight: Fonts.bold,
          fontFamily: "Raleway",
        ),
        SizedBox(
          height: PopupTabletConstants.spaceBtwInterestsNMembers(),
        ),
        SizedBox(
          height: PopupTabletConstants.interestsListViewHeight(),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
                horizontal: PopupTabletConstants.resize(2)),
            scrollDirection: Axis.horizontal,
            itemCount: user.interests.length,
            itemBuilder: (context, index) {
              return _buildTabletCategoryItem(user.interests[index], context);
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildCategoryItem(String interest, BuildContext context) {
  Color colorCategory = CategoryColors.getColor(interest);
  IconData iconCategory = CategoryIcons.mapper[interest]!;

  return Padding(
    padding: EdgeInsets.only(right: Constants.spaceBtwElementsInListView),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: Constants.heightInterest,
          width: Constants.widthInterest,
          decoration: BoxDecoration(
            color: colorCategory,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              Constants.boxShadow(context),
            ],
          ),
          child: Center(
            child: Icon(
              iconCategory,
              color: AppColors.whiteColor,
            ),
          ),
        ),
        Center(
          child: CustomText(
            text: interest,
            size: Constants.textDimensionCategory,
            fontFamily: "Inter",
            fontWeight: Fonts.regular,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTabletCategoryItem(String interest, BuildContext context) {
  Color colorCategory = CategoryColors.getColor(interest);
  IconData iconCategory = CategoryIcons.mapper[interest]!;

  return Padding(
    padding: EdgeInsets.only(
        right: PopupTabletConstants.spaceBtwElementsInListView()),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: PopupTabletConstants.heightInterest(),
          width: PopupTabletConstants.widthInterest(),
          decoration: BoxDecoration(
            color: colorCategory,
            borderRadius:
                BorderRadius.circular(PopupTabletConstants.resize(20)),
            boxShadow: [
              Constants.boxShadow(context),
            ],
          ),
          child: Center(
            child: Icon(
              iconCategory,
              color: AppColors.whiteColor,
              size: PopupTabletConstants.iconDimension(),
            ),
          ),
        ),
        Center(
          child: CustomText(
            text: interest,
            size: PopupTabletConstants.textDimensionCategory(),
            fontFamily: "Inter",
            fontWeight: Fonts.regular,
          ),
        ),
      ],
    ),
  );
}
