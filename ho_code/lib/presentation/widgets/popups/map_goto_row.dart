import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/map_utils.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class MapGoToRow extends StatelessWidget {
  final String locationName;
  final GeoPoint location;
  const MapGoToRow(
      {super.key, required this.location, required this.locationName});

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildGoToRow();
    }
    return _buildTabletGoToRow();
  }

  void _onTapOnLocation() {
    locationName == ""
        ? null
        : MapUtils.openMap(location.latitude, location.longitude);
  }

  Widget _buildGoToRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Location:',
          size: Constants.textDimensionTitle,
          fontWeight: Fonts.bold,
          fontFamily: "Raleway",
        ),
        Padding(
          padding: EdgeInsets.only(top: Constants.spaceBtwTitleNListView),
          child: GestureDetector(
            onTap: _onTapOnLocation,
            child: Container(
              height: 36.h,
              width: 272.w,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.blackColor),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: Constants.mapSearchPadding,
                child: Row(
                  children: [
                    const Icon(AppIcons.pin),
                    const SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      width: 215.w,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: CustomText(
                          text: locationName == ""
                              ? "This event has no location"
                              : locationName,
                          size: Constants.textDimensionTitle,
                          fontWeight: Fonts.bold,
                          fontFamily: "Raleway",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletGoToRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'Location:',
          size: PopupTabletConstants.textDimensionTitle(),
          fontWeight: Fonts.bold,
          fontFamily: "Raleway",
        ),
        Padding(
          padding: EdgeInsets.only(top: Constants.spaceBtwTitleNListView),
          child: GestureDetector(
            onTap: _onTapOnLocation,
            child: Container(
              height: PopupTabletConstants.resize(40),
              // width: 300.r,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.blackColor),
                borderRadius:
                    BorderRadius.circular(PopupTabletConstants.resize(20)),
              ),
              child: Padding(
                padding: PopupTabletConstants.mapSearchPadding(),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.pin,
                      size: PopupTabletConstants.iconDimension(),
                    ),
                    SizedBox(
                      width: PopupTabletConstants.resize(5),
                    ),
                    SizedBox(
                      width: PopupTabletConstants.resize(220),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: CustomText(
                          text: locationName == ""
                              ? "This event has no location"
                              : locationName,
                          size: PopupTabletConstants.textDimensionTitle(),
                          fontWeight: Fonts.bold,
                          fontFamily: "Raleway",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
