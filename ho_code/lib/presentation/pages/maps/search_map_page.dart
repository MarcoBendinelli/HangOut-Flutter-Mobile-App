import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hang_out_app/business_logic/cubits/map/map_cubit.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class SearchMapPage extends StatefulWidget {
  final bool isForTest;
  const SearchMapPage({super.key, this.isForTest = false});

  @override
  State<StatefulWidget> createState() => _SearchMapPageState();
}

class _SearchMapPageState extends State<SearchMapPage> {
  late TextEditingController textEditingController = TextEditingController();
  late PickerMapController controller = PickerMapController(
    initMapWithUserPosition: true,
  );
  GeoPoint? selectedPoint;
  String street = "";
  String number = "";
  String city = "";
  bool firstLoad = true;

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(textOnChanged);
  }

  void textOnChanged() {
    controller.setSearchableText(textEditingController.text);
  }

  @override
  void dispose() {
    textEditingController.removeListener(textOnChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isForTest
        ? _pageForTesting()
        : CustomPickerLocation(
            onMapReady: (bool isReady) async {
              if (isReady && firstLoad) {
                firstLoad = false;
                MapState state = BlocProvider.of<MapCubit>(context).state;
                if (state.status == MapStatus.success) {
                  GeoPoint point = GeoPoint(
                      latitude: state.latitude, longitude: state.longitude);
                  selectedPoint = point;
                  // await controller.osmBaseController.addMarker(point, markerIcon: Constants.markerIcon);
                  await controller.osmBaseController.goToPosition(point);
                  // await controller.goToLocation(point);
                } else {
                  await controller.getCurrentPositionAdvancedPositionPicker();
                }
              }
            },
            controller: controller,
            topWidgetPicker: getSize(context) == ScreenSize.normal
                ? _builTopWidgetPicker()
                : _builTopTabletWidgetPicker(),
            bottomWidgetPicker: getSize(context) == ScreenSize.normal
                ? _builBottomwidgetPicker()
                : _builBottomTabletwidgetPicker(),
            pickerConfig: CustomPickerLocationConfig(
              // loadingWidget: _buildLoadingChild(),
              initZoom: Constants.mapInitialZoom,
              advancedMarkerPicker: MarkerIcon(
                icon: Icon(
                  AppIcons.pin,
                  size: _isIpad()
                      ? Constants.mapPinIpadDimension
                      : Constants.mapPinDimension,
                  color: AppColors.blackColor,
                ),
              ),
            ),
          );
  }

  _pageForTesting() {
    return getSize(context) == ScreenSize.normal
        ? Stack(
            children: [
              _builBottomwidgetPicker(),
              _builTopWidgetPicker(),
              // _buildLoadingChild(),
            ],
          )
        : Stack(
            children: [
              _builBottomTabletwidgetPicker(),
              _builTopTabletWidgetPicker(),
              // _buildLoadingChild(),
            ],
          );
  }

  _builTopTabletWidgetPicker() {
    return Padding(
      key: const Key("top-tablet-widget-picker"),
      padding: EdgeInsets.only(
        top: Constants.mapSearchTopDistance,
      ),
      child: Column(
        children: [
          Container(
            height: PopupTabletConstants.resize(90),
            width: PopupTabletConstants.resize(660),
            padding: Constants.mapSearchPadding,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(PopupTabletConstants.resize(20)),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).iconTheme.color,
                  size: PopupTabletConstants.iconDimension(),
                ),
                SizedBox(
                  width: Constants.mapSearchspaceBetween,
                ),
                Expanded(
                  child: PointerInterceptor(
                    child: TextField(
                      controller: textEditingController,
                      onEditingComplete: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      decoration: InputDecoration(
                        isCollapsed: true,

                        suffix: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: textEditingController,
                          builder: (ctx, text, child) {
                            if (text.text.isNotEmpty) {
                              return child!;
                            }
                            return const SizedBox.shrink();
                          },
                          child: InkWell(
                            focusNode: FocusNode(),
                            onTap: () {
                              textEditingController.clear();
                              controller.setSearchableText("");
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: Icon(
                              Icons.close,
                              size: PopupTabletConstants.iconDimension(),
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                        focusColor: AppColors.blackColor,
                        // filled: true,
                        hintText: "Search here",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        // fillColor: Theme.of(context).cardColor,
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: Constants.mapSearchspaceBetween,
                ),
                GestureDetector(
                  child: Icon(
                    AppIcons.goToSelected,
                    color: Theme.of(context).iconTheme.color,
                    size: PopupTabletConstants.iconDimension(),
                  ),
                  onTap: () async {
                    if (selectedPoint != null) {
                      await controller.goToLocation(selectedPoint!);

                      controller.osmBaseController
                          .setZoom(zoomLevel: Constants.mapInitialZoom);
                    }
                  },
                ),
                SizedBox(
                  width: Constants.mapSearchspaceBetween,
                ),
                GestureDetector(
                  child: Icon(
                    AppIcons.personOutline,
                    color: Theme.of(context).iconTheme.color,
                    size: PopupTabletConstants.iconDimension(),
                  ),
                  onTap: () async {
                    GeoPoint p =
                        await controller.osmBaseController.myLocation();
                    await controller.goToLocation(p);
                    controller.osmBaseController
                        .setZoom(zoomLevel: Constants.mapInitialZoom);
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          widget.isForTest ? const SizedBox() : const TopSearchWidget()
        ],
      ),
    );
  }

  _builBottomTabletwidgetPicker() {
    return Positioned(
      key: const Key("bottom-tablet-widget-picker"),
      bottom: PopupTabletConstants.resize(12),
      right: PopupTabletConstants.resize(12),
      child: PointerInterceptor(
        child: FloatingActionButton(
          backgroundColor: AppColors.blackColor,
          onPressed: () async {
            MapCubit cubit = BlocProvider.of<MapCubit>(context);
            GeoPoint geoPoint =
                await controller.getCurrentPositionAdvancedPositionPicker();

            try {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                  geoPoint.latitude, geoPoint.longitude,
                  localeIdentifier: "en");
              if (placemarks[0].street != null) {
                street = placemarks[0].street!;
                number = placemarks[0].subThoroughfare!;
                city = placemarks[0].locality!;
                cubit.addPosition(
                  latitude: geoPoint.latitude,
                  longitude: geoPoint.longitude,
                  locationName: "$street $number, $city",
                );
              }
            } catch (_) {
              number = "";
              street = "";
              city = "";
              cubit.setFailure();
            }
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Icon(
            AppIcons.arrowIosForwardOutline,
            size: PopupTabletConstants.iconDimension(),
          ),
        ),
      ),
    );
  }

  _builTopWidgetPicker() {
    return Padding(
      key: const Key("top-widget-picker"),
      padding: EdgeInsets.only(
        top: Constants.mapSearchTopDistance,
      ),
      child: Column(
        children: [
          Container(
            height: 60.h,
            width: 330.w,
            padding: Constants.mapSearchPadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).iconTheme.color,
                  size: Constants.iconDimension,
                ),
                SizedBox(
                  width: Constants.mapSearchspaceBetween,
                ),
                Expanded(
                  child: PointerInterceptor(
                    child: TextField(
                      controller: textEditingController,
                      onEditingComplete: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      decoration: InputDecoration(
                        isCollapsed: true,

                        suffix: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: textEditingController,
                          builder: (ctx, text, child) {
                            if (text.text.isNotEmpty) {
                              return child!;
                            }
                            return const SizedBox.shrink();
                          },
                          child: InkWell(
                            focusNode: FocusNode(),
                            onTap: () {
                              textEditingController.clear();
                              controller.setSearchableText("");
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: Icon(
                              Icons.close,
                              size: 16.r,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                        focusColor: AppColors.blackColor,
                        // filled: true,
                        hintText: "Search here",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        // fillColor: Theme.of(context).cardColor,
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: Constants.mapSearchspaceBetween,
                ),
                GestureDetector(
                  child: Icon(
                    AppIcons.goToSelected,
                    color: Theme.of(context).iconTheme.color,
                    size: Constants.iconDimension,
                  ),
                  onTap: () async {
                    if (selectedPoint != null) {
                      await controller.goToLocation(selectedPoint!);

                      controller.osmBaseController
                          .setZoom(zoomLevel: Constants.mapInitialZoom);
                    }
                  },
                ),
                SizedBox(
                  width: Constants.mapSearchspaceBetween,
                ),
                GestureDetector(
                  child: Icon(
                    AppIcons.personOutline,
                    color: Theme.of(context).iconTheme.color,
                    size: Constants.iconDimension,
                  ),
                  onTap: () async {
                    GeoPoint p =
                        await controller.osmBaseController.myLocation();
                    await controller.goToLocation(p);
                    controller.osmBaseController
                        .setZoom(zoomLevel: Constants.mapInitialZoom);
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8.h,
          ),
          widget.isForTest ? const SizedBox() : const TopSearchWidget()
        ],
      ),
    );
  }

  _builBottomwidgetPicker() {
    return Positioned(
      key: const Key("bottom-widget-picker"),
      bottom: 12.r,
      right: 12.r,
      child: PointerInterceptor(
        child: FloatingActionButton(
          backgroundColor: AppColors.blackColor,
          onPressed: () async {
            MapCubit cubit = BlocProvider.of<MapCubit>(context);
            GeoPoint geoPoint =
                await controller.getCurrentPositionAdvancedPositionPicker();

            try {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                  geoPoint.latitude, geoPoint.longitude,
                  localeIdentifier: "en");
              if (placemarks[0].street != null) {
                street = placemarks[0].street!;
                number = placemarks[0].subThoroughfare!;
                city = placemarks[0].locality!;
                cubit.addPosition(
                  latitude: geoPoint.latitude,
                  longitude: geoPoint.longitude,
                  locationName: "$street $number, $city",
                );
              }
            } catch (_) {
              number = "";
              street = "";
              city = "";
              cubit.setFailure();
            }
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Icon(
            AppIcons.arrowIosForwardOutline,
            size: Constants.iconDimension,
          ),
        ),
      ),
    );
  }

  _isIpad() {
    //So to check for iPad for instance
    if (Device.get().isIos) {
      return true;
    }
    return false;
  }

  // _buildLoadingChild() {
  //   return Container(
  //     height: double.infinity,
  //     width: double.infinity,
  //     color: AppColors.grayColor,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         CustomText(
  //           text: "Map is Loading",
  //           size: 15.h,
  //           fontFamily: "Raleway",
  //           fontWeight: Fonts.bold,
  //         ),
  //         SizedBox(height: 15.h),
  //         const OurCircularProgressIndicator()
  //       ],
  //     ),
  //   );
  // }
}

class TopSearchWidget extends StatefulWidget {
  final PickerMapController? testController;
  const TopSearchWidget({super.key, this.testController});

  @override
  State<StatefulWidget> createState() => _TopSearchWidgetState();
}

class _TopSearchWidgetState extends State<TopSearchWidget> {
  late PickerMapController controller;
  ValueNotifier<GeoPoint?> notifierGeoPoint = ValueNotifier(null);
  ValueNotifier<bool> notifierAutoCompletion = ValueNotifier(false);

  late StreamController<List<SearchInfo>> streamSuggestion = StreamController();
  late Future<List<SearchInfo>> _futureSuggestionAddress;
  String oldText = "";
  Timer? _timerToStartSuggestionReq;
  final Key streamKey = const Key("streamAddressSug");

  @override
  void initState() {
    super.initState();
    controller = widget.testController ?? CustomPickerLocation.of(context);
    controller.searchableText.addListener(onSearchableTextChanged);
  }

  void onSearchableTextChanged() async {
    final v = controller.searchableText.value;
    if (v.length > 3 && oldText != v) {
      oldText = v;
      if (_timerToStartSuggestionReq != null &&
          _timerToStartSuggestionReq!.isActive) {
        _timerToStartSuggestionReq!.cancel();
      }
      _timerToStartSuggestionReq =
          Timer.periodic(const Duration(seconds: 1), (timer) async {
        await suggestionProcessing(v);
        timer.cancel();
      });
    }
    if (v.isEmpty) {
      await reInitStream();
    }
  }

  Future reInitStream() async {
    notifierAutoCompletion.value = false;
    await streamSuggestion.close();
    setState(() {
      streamSuggestion = StreamController();
    });
  }

  Future<void> suggestionProcessing(String addr) async {
    notifierAutoCompletion.value = true;
    _futureSuggestionAddress = addressSuggestion(
      addr,
      limitInformation: 5,
    );
    _futureSuggestionAddress.then((value) {
      streamSuggestion.sink.add(value);
    });
  }

  @override
  void dispose() {
    controller.searchableText.removeListener(onSearchableTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifierAutoCompletion,
      builder: (ctx, isVisible, child) {
        return AnimatedContainer(
          duration: const Duration(
            milliseconds: 500,
          ),
          height: isVisible ? MediaQuery.of(context).size.height / 4 : 0,
          child: Card(
            child: child!,
          ),
        );
      },
      child: StreamBuilder<List<SearchInfo>>(
        stream: streamSuggestion.stream,
        key: streamKey,
        builder: (ctx, snap) {
          if (snap.hasData) {
            return ListView.builder(
              itemExtent: 50.h,
              itemCount: snap.data!.length,
              itemBuilder: (ctx, index) {
                return PointerInterceptor(
                  child: ListTile(
                    title: CustomText(
                      size: 15.h,
                      text: snap.data![index].address.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      /// go to location selected by address
                      controller.goToLocation(
                        snap.data![index].point!,
                      );

                      /// hide suggestion card
                      notifierAutoCompletion.value = false;
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
                      await reInitStream();
                    },
                  ),
                );
              },
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Card(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
