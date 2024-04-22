import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/cubits/map/map_cubit.dart';
import 'package:hang_out_app/presentation/pages/maps/search_map_page.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

typedef MapCallback = void Function({
  double latitude,
  double longitude,
  String locationName,
});

class MapInputRow extends StatefulWidget {
  final MapCallback callback;
  final GeoPoint? oldLocation;
  final String? oldLocationName;

  const MapInputRow({
    super.key,
    required this.callback,
    this.oldLocation,
    this.oldLocationName,
  });

  @override
  State<MapInputRow> createState() => _MapInputRowState();
}

class _MapInputRowState extends State<MapInputRow> {
  @override
  Widget build(BuildContext context) {
    if (widget.oldLocation != null && widget.oldLocationName != "") {
      BlocProvider.of<MapCubit>(context).addPosition(
          latitude: widget.oldLocation!.latitude,
          longitude: widget.oldLocation!.longitude,
          locationName: widget.oldLocationName!);
    }
    if (getSize(context) == ScreenSize.normal) {
      return _buildRow(context);
    }
    return _buildTabletRow(context);
  }

  Widget _buildRow(BuildContext context) {
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
              key: const Key("search-map-button"),
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
                      BlocBuilder<MapCubit, MapState>(
                          builder: (context, state) {
                        if (state.status == MapStatus.initial) {
                          return const Icon(AppIcons.pinOutline);
                        } else if (state.status == MapStatus.success) {
                          return const Icon(AppIcons.pin);
                        } else {
                          return const Icon(
                            AppIcons.pinError,
                            color: AppColors.error,
                          );
                        }
                      }),
                      SizedBox(
                        width: 5.w,
                      ),
                      BlocConsumer<MapCubit, MapState>(
                        builder: (context, state) {
                          if (state.status == MapStatus.initial) {
                            return CustomText(
                              text: 'Search on the map',
                              size: Constants.textDimensionTitle,
                              fontWeight: Fonts.bold,
                              fontFamily: "Raleway",
                            );
                          } else if (state.status == MapStatus.success) {
                            return SizedBox(
                              width: 215.w,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: CustomText(
                                  text: state.locationName,
                                  size: Constants.textDimensionTitle,
                                  fontWeight: Fonts.bold,
                                  fontFamily: "Raleway",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          } else {
                            return CustomText(
                              text: 'Invalid Location',
                              size: Constants.textDimensionTitle,
                              fontWeight: Fonts.bold,
                              fontFamily: "Raleway",
                              color: Colors.red,
                            );
                          }
                        },
                        listener: (context, state) {
                          widget.callback(
                              locationName: state.locationName,
                              latitude: state.latitude,
                              longitude: state.longitude);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                _onTap(context);
              }),
        ),
      ],
    );
  }

  Widget _buildTabletRow(BuildContext context) {
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
          padding: EdgeInsets.only(
              top: PopupTabletConstants.spaceBtwTitleNListView()),
          child: GestureDetector(
              key: const Key("search-map-button"),
              child: Container(
                height: PopupTabletConstants.resize(45),
                width: PopupTabletConstants.popupDimension() -
                    PopupTabletConstants.contentPopupPaddingValue(),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.blackColor),
                  borderRadius:
                      BorderRadius.circular(PopupTabletConstants.resize(20)),
                ),
                child: Padding(
                  padding: PopupTabletConstants.mapSearchPadding(),
                  child: Row(
                    children: [
                      BlocBuilder<MapCubit, MapState>(
                          builder: (context, state) {
                        if (state.status == MapStatus.initial) {
                          return Icon(
                            AppIcons.pinOutline,
                            size: PopupTabletConstants.iconDimension(),
                          );
                        } else if (state.status == MapStatus.success) {
                          return Icon(
                            AppIcons.pin,
                            size: PopupTabletConstants.iconDimension(),
                          );
                        } else {
                          return Icon(
                            AppIcons.pinError,
                            color: AppColors.error,
                            size: PopupTabletConstants.iconDimension(),
                          );
                        }
                      }),
                      SizedBox(
                        width: PopupTabletConstants.resize(5),
                      ),
                      BlocConsumer<MapCubit, MapState>(
                        builder: (context, state) {
                          if (state.status == MapStatus.initial) {
                            return CustomText(
                              text: 'Search on the map',
                              size: PopupTabletConstants.textDimensionTitle(),
                              fontWeight: Fonts.bold,
                              fontFamily: "Raleway",
                            );
                          } else if (state.status == MapStatus.success) {
                            return SizedBox(
                              width: PopupTabletConstants.resize(600),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: CustomText(
                                  text: state.locationName,
                                  size:
                                      PopupTabletConstants.textDimensionTitle(),
                                  fontWeight: Fonts.bold,
                                  fontFamily: "Raleway",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          } else {
                            return CustomText(
                              text: 'Invalid Location',
                              size: PopupTabletConstants.textDimensionTitle(),
                              fontWeight: Fonts.bold,
                              fontFamily: "Raleway",
                              color: Colors.red,
                            );
                          }
                        },
                        // listenWhen: (context, state) {
                        //   return state.status == MapStatus.success;
                        // },
                        listener: (context, state) {
                          widget.callback(
                              locationName: state.locationName,
                              latitude: state.latitude,
                              longitude: state.longitude);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                _onTap(context);
              }),
        ),
      ],
    );
  }

  void _onTap(BuildContext context) {
    //This unfocus is a must have to fix a bug with textfield open before map selection
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: BlocProvider.of<MapCubit>(context),
          child: const SearchMapPage(),
          // child: const TapMapPage(),
        ),
      ),
    );
  }
}
