import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/cubits/events/modify_event/modify_event_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/map/map_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/required_fields/required_fields_cubit.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/presentation/utils/animations/custom_rect_tween.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/mandatory_note.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/our_divider.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/privacy_selector_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/single_category_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_photo_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/map_input_row.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_return_and_name.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ModifyEventPopup extends StatefulWidget {
  final String heroTag;
  final Event oldEvent;

  const ModifyEventPopup(
      {Key? key, required this.heroTag, required this.oldEvent})
      : super(key: key);

  @override
  State<ModifyEventPopup> createState() => _ModifyEventPopupState();
}

class _ModifyEventPopupState extends State<ModifyEventPopup> {
  String newEventName = "";
  String newEventDescription = "";
  String newEventCategory = CategoryIcons.mapper.keys.first;
  String invited = "";
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

  // final DateFormat hourFormatter = DateFormat('');
  String? imageDevicePath;
  XFile? image;
  bool private = true;
  Timestamp newEventDate = Timestamp(0, 0);
  GeoPoint newEventLocation = const GeoPoint(0, 0);
  String newEventLocationName = "";

  @override
  initState() {
    super.initState();
    newEventName = widget.oldEvent.name;
    newEventDescription = widget.oldEvent.description;
    newEventCategory = widget.oldEvent.category;
    invited = "";
    imageDevicePath;
    image;
    private = widget.oldEvent.private;
    newEventDate = widget.oldEvent.date;
    newEventLocation = widget.oldEvent.location;
    newEventLocationName = widget.oldEvent.locationName;
  }

  @override
  Widget build(BuildContext context) {
    // UserData currentUser = context.select((UserBloc bloc) => bloc.state.user);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ModifyEventCubit(
              eventsRepository: context.read<MyEventsRepository>()),
        ),
        BlocProvider<RequiredFieldsCubit>(
          create: (context) => RequiredFieldsCubit(isForTheEvent: true),
        ),
      ],
      child: Builder(builder: (context) {
        BlocProvider.of<RequiredFieldsCubit>(context)
            .updateDate(inputDate: newEventDate);
        BlocProvider.of<RequiredFieldsCubit>(context)
            .updateName(inputName: newEventName);
        BlocProvider.of<RequiredFieldsCubit>(context)
            .updateCaption(inputCaption: newEventDescription);
        if (getSize(context) == ScreenSize.normal) {
          return _buildModifyEvent(context);
        }
        return _buildTabletModifyEvent(context);
      }),
    );
  }

  Widget _buildModifyEvent(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: Constants.popupDimensionPadding,
            child: Hero(
              tag: widget.heroTag,
              createRectTween: (begin, end) {
                return CustomRectTween(begin: begin!, end: end!);
              },
              child: Material(
                color: Theme.of(context).cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Constants.borderRadius)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TopBarReturnAndName(
                      title: 'Modify Event',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: Constants.contentPopupPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "Date:",
                                          size: 14.r,
                                          fontFamily: "Raleway",
                                          fontWeight: Fonts.bold,
                                        ),
                                        CustomText(
                                          text: ' *',
                                          size: Constants.textDimensionTitle,
                                          fontWeight: Fonts.regular,
                                          fontFamily: "Inter",
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        CustomText(
                                          text: "Hour:",
                                          size: 14.r,
                                          fontFamily: "Raleway",
                                          fontWeight: Fonts.bold,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: dateFormatter
                                              .format(newEventDate.toDate()),
                                          size: 14.r,
                                          fontFamily: "Inter",
                                          fontWeight: Fonts.regular,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        CustomText(
                                          text: DateFormat("h:mma")
                                              .format(newEventDate.toDate()),
                                          size: 14.r,
                                          fontFamily: "Inter",
                                          fontWeight: Fonts.regular,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _modifyDate(context);
                                },
                              ),
                              const OurDivider(),
                              TextPhotoRow(
                                oldPhoto: widget.oldEvent.photo!,
                                oldName: widget.oldEvent.name,
                                setNameCallback: (insertedGroupName) {
                                  newEventName = insertedGroupName;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateName(inputName: newEventName);
                                },
                                inputName: "Name",
                                setImagePickedCallback: (choseImage) {
                                  image = choseImage;
                                },
                                required: true,
                              ),
                              const OurDivider(),
                              TextInputRow(
                                oldText: widget.oldEvent.description,
                                hintText: Constants.eventCaptionHint,
                                setTextCallback: (insertedGroupName) {
                                  newEventDescription = insertedGroupName;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateCaption(
                                          inputCaption: newEventDescription);
                                },
                                inputName: "Caption",
                                required: true,
                              ),
                              const OurDivider(),
                              PrivacySelectorRow(
                                setPrivacyCallback: (privacy) {
                                  private = privacy;
                                },
                                oldPrivacy: private,
                              ),
                              const OurDivider(),
                              BlocProvider(
                                create: (context) => MapCubit(),
                                child: MapInputRow(
                                  oldLocation: newEventLocation,
                                  oldLocationName: newEventLocationName,
                                  callback: ({
                                    latitude = 0,
                                    longitude = 0,
                                    locationName = "",
                                  }) {
                                    newEventLocation =
                                        GeoPoint(latitude, longitude);
                                    newEventLocationName = locationName;
                                  },
                                ),
                              ),
                              const OurDivider(),
                              SingleCategoryInputRow(
                                index: CategoryColors.mapper.keys
                                    .toList()
                                    .indexOf(widget.oldEvent.category),
                                groupInterestsCallback: (val) =>
                                    newEventCategory = val,
                                inputName: "Category",
                                required: true,
                              ),
                              const OurDivider(),
                              const MandatoryNote(),
                              SizedBox(
                                height: Constants.distanceBtwDoneNElement,
                              ),
                              BlocConsumer<ModifyEventCubit, ModifyEventState>(
                                listener: (context, state) {
                                  if (state.status ==
                                      ModifyEventSatus.success) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status ==
                                      ModifyEventSatus.initial) {
                                    return Center(
                                      child: BlocBuilder<RequiredFieldsCubit,
                                          RequiredFieldsState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              RequiredFieldsStatus.completed) {
                                            return TapFadeText(
                                              onTap: () async {
                                                await _tapDone(context);
                                              },
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                            );
                                          } else {
                                            return TapFadeText(
                                              onTap: () {},
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                              disabled: true,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  } else if (state.status ==
                                      ModifyEventSatus.error) {
                                    return const Center(
                                      child:
                                          CustomText(text: "An error occured"),
                                    );
                                  } else {
                                    return const Center(
                                        child: OurCircularProgressIndicator());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _tapDone(BuildContext context) async {
    await BlocProvider.of<ModifyEventCubit>(context).modifyEvent(
        eventId: widget.oldEvent.id,
        eventName: newEventName,
        eventDescription: newEventDescription,
        category: newEventCategory,
        date: newEventDate,
        image: image,
        private: private,
        oldPhoto: widget.oldEvent.photo!,
        location: newEventLocation,
        locationName: newEventLocationName);
  }

  void _modifyDate(BuildContext context) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now().add(const Duration(hours: 1)),
      maxTime: DateTime.utc(2050, 01, 01),
      currentTime: widget.oldEvent.date.toDate(),
      locale: LocaleType.en,
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          newEventDate = Timestamp.fromDate(date);
        });
        BlocProvider.of<RequiredFieldsCubit>(context)
            .updateDate(inputDate: newEventDate);
      },
    );
  }

  Widget _buildTabletModifyEvent(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Center(
          child: Hero(
            tag: widget.heroTag,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: Material(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.borderRadius)),
              child: SizedBox(
                width: PopupTabletConstants.popupDimension(),
                height: PopupTabletConstants.popupDimension(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TopBarReturnAndName(
                      title: 'Modify Event',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: PopupTabletConstants.contentPopupPadding(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "Date:",
                                          size: PopupTabletConstants
                                              .textDimensionTitle(),
                                          fontFamily: "Raleway",
                                          fontWeight: Fonts.bold,
                                        ),
                                        CustomText(
                                          text: ' *',
                                          size: PopupTabletConstants
                                              .textDimensionTitle(),
                                          fontWeight: Fonts.regular,
                                          fontFamily: "Inter",
                                        ),
                                        SizedBox(
                                          height:
                                              PopupTabletConstants.resize(10),
                                        ),
                                        CustomText(
                                          text: "Hour:",
                                          size: PopupTabletConstants
                                              .textDimensionTitle(),
                                          fontFamily: "Raleway",
                                          fontWeight: Fonts.bold,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: PopupTabletConstants.resize(10),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: dateFormatter
                                              .format(newEventDate.toDate()),
                                          size: PopupTabletConstants.resize(20),
                                          fontFamily: "Inter",
                                          fontWeight: Fonts.regular,
                                        ),
                                        SizedBox(
                                          height:
                                              PopupTabletConstants.resize(25),
                                        ),
                                        CustomText(
                                          text: DateFormat("h:mma")
                                              .format(newEventDate.toDate()),
                                          size: PopupTabletConstants.resize(20),
                                          fontFamily: "Inter",
                                          fontWeight: Fonts.regular,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _modifyDate(context);
                                },
                              ),
                              const OurDivider(),
                              TextPhotoRow(
                                oldPhoto: widget.oldEvent.photo!,
                                oldName: widget.oldEvent.name,
                                setNameCallback: (insertedGroupName) {
                                  newEventName = insertedGroupName;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateName(inputName: newEventName);
                                },
                                inputName: "Name",
                                setImagePickedCallback: (choseImage) {
                                  image = choseImage;
                                },
                                required: true,
                              ),
                              const OurDivider(),
                              TextInputRow(
                                oldText: widget.oldEvent.description,
                                hintText: Constants.eventCaptionHint,
                                setTextCallback: (insertedGroupName) {
                                  newEventDescription = insertedGroupName;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateCaption(
                                          inputCaption: newEventDescription);
                                },
                                inputName: "Caption",
                                required: true,
                              ),
                              const OurDivider(),
                              PrivacySelectorRow(
                                setPrivacyCallback: (privacy) {
                                  private = privacy;
                                },
                                oldPrivacy: private,
                              ),
                              const OurDivider(),
                              BlocProvider(
                                create: (context) => MapCubit(),
                                child: MapInputRow(
                                  oldLocation: newEventLocation,
                                  oldLocationName: newEventLocationName,
                                  callback: ({
                                    latitude = 0,
                                    longitude = 0,
                                    locationName = "",
                                  }) {
                                    newEventLocation =
                                        GeoPoint(latitude, longitude);
                                    newEventLocationName = locationName;
                                  },
                                ),
                              ),
                              const OurDivider(),
                              SingleCategoryInputRow(
                                index: CategoryColors.mapper.keys
                                    .toList()
                                    .indexOf(widget.oldEvent.category),
                                groupInterestsCallback: (val) =>
                                    newEventCategory = val,
                                inputName: "Category",
                                required: true,
                              ),
                              const OurDivider(),
                              const MandatoryNote(),
                              SizedBox(
                                height: PopupTabletConstants
                                    .distanceBtwDoneNElement(),
                              ),
                              BlocConsumer<ModifyEventCubit, ModifyEventState>(
                                listener: (context, state) {
                                  if (state.status ==
                                      ModifyEventSatus.success) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status ==
                                      ModifyEventSatus.initial) {
                                    return Center(
                                      child: BlocBuilder<RequiredFieldsCubit,
                                          RequiredFieldsState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              RequiredFieldsStatus.completed) {
                                            return TapFadeText(
                                              onTap: () async {
                                                await _tapDone(context);
                                              },
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                            );
                                          } else {
                                            return TapFadeText(
                                              onTap: () {},
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                              disabled: true,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  } else if (state.status ==
                                      ModifyEventSatus.error) {
                                    return const Center(
                                      child:
                                          CustomText(text: "An error occured"),
                                    );
                                  } else {
                                    return const Center(
                                        child: OurCircularProgressIndicator());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
