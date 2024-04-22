import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart' as date;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/events/add_event/add_event_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/map/map_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/notification/notification_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/required_fields/required_fields_cubit.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/group_selector.dart';
import 'package:hang_out_app/presentation/widgets/mandatory_note.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/our_divider.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/privacy_selector_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/single_category_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_photo_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/map_input_row.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:hang_out_app/presentation/utils/animations/custom_rect_tween.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_return_and_name.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';

/// Popup card to add a new [Event]. Should be used in conjunction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAddEvent].
class AddEventPopup extends StatefulWidget {
  final String heroTag;

  const AddEventPopup({Key? key, required this.heroTag}) : super(key: key);

  @override
  State<AddEventPopup> createState() => _AddEventPopupState();
}

class _AddEventPopupState extends State<AddEventPopup> {
  String newEventName = "";
  GeoPoint newEventLocation = const GeoPoint(0, 0);
  String newEventLocationName = "";
  String newEventDescription = "";
  String newEventCategory = CategoryIcons.mapper.keys.first;
  List<String> newEventInviteIds = [];
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  String newEventId = "";

  // final DateFormat hourFormatter = DateFormat('');
  String? imageURL;
  String? imageDevicePath;
  XFile? image;
  bool private = true;
  Timestamp? newEventDate;

  @override
  Widget build(BuildContext context) {
    UserData currentUser = context.select((UserBloc bloc) => bloc.state.user);
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(
              notificationsRepository: context.read<NotificationsRepository>(),
              userRepository: context.read<UserRepository>()),
        ),
        BlocProvider(
          create: (context) => AddEventCubit(
              eventsRepository: context.read<MyEventsRepository>()),
        ),
        BlocProvider<RequiredFieldsCubit>(
          create: (context) => RequiredFieldsCubit(isForTheEvent: true),
        ),
        BlocProvider(
          create: (context) => MapCubit(),
        ),
        BlocProvider(
          create: (context) => MembersBloc(
              eventsRepository: context.read<MyEventsRepository>(),
              groupsRepository: context.read<MyGroupsRepository>(),
              userRepository: context.read<UserRepository>())
            ..add(LoadGroupForUser(userId: currentUser.id)),
        )
      ],
      child: Builder(builder: (context) {
        if (getSize(context) == ScreenSize.normal) {
          return _buildAddEventPopup(context, currentUser);
        }
        return _buildTabletAddEventPopup(context, currentUser);
      }),
    );
  }

  Widget _buildAddEventPopup(BuildContext context, UserData currentUser) {
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
                      title: 'New Event',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: Constants.contentPopupPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(
                                        text: "Date and hour:",
                                        size: Constants.textDimensionTitle,
                                        fontFamily: "Raleway",
                                        fontWeight: Fonts.bold,
                                      ),
                                      CustomText(
                                        text: ' *',
                                        size: Constants.textDimensionTitle,
                                        fontWeight: Fonts.regular,
                                        fontFamily: "Inter",
                                      ),
                                    ],
                                  ),
                                  TapFadeIcon(
                                    key: const Key("add_date"),
                                    iconColor:
                                        Theme.of(context).iconTheme.color!,
                                    icon: AppIcons.edit2Outline,
                                    size: Constants.iconDimension,
                                    onTap: () {
                                      _tapAddDate(context);
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: Constants.spaceBtwTitleNTextField),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: newEventDate == null
                                      ? [
                                          CustomText(
                                            text: "YYYY-MM-DD",
                                            size: 14.r,
                                            fontFamily: "Inter",
                                            fontWeight: Fonts.regular,
                                          ),
                                          CustomText(
                                            text: "hh:mm",
                                            size: 14.r,
                                            fontFamily: "Inter",
                                            fontWeight: Fonts.regular,
                                          ),
                                        ]
                                      : [
                                          CustomText(
                                            text: dateFormatter
                                                .format(newEventDate!.toDate()),
                                            size: 14.r,
                                            fontFamily: "Inter",
                                            fontWeight: Fonts.regular,
                                          ),
                                          CustomText(
                                            text: DateFormat("h:mma")
                                                .format(newEventDate!.toDate()),
                                            size: 14.r,
                                            fontFamily: "Inter",
                                            fontWeight: Fonts.regular,
                                          ),
                                        ],
                                ),
                              ),
                              const OurDivider(),
                              TextPhotoRow(
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
                                setTextCallback: (insertedGroupCaption) {
                                  newEventDescription = insertedGroupCaption;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateCaption(
                                          inputCaption: newEventDescription);
                                },
                                hintText: Constants.eventCaptionHint,
                                inputName: "Caption",
                                required: true,
                              ),
                              const OurDivider(),
                              PrivacySelectorRow(
                                  oldPrivacy: private,
                                  setPrivacyCallback: (privacy) {
                                    private = privacy;
                                  }),
                              const OurDivider(),
                              MapInputRow(
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
                              const OurDivider(),
                              SingleCategoryInputRow(
                                  groupInterestsCallback: (val) {
                                    newEventCategory = val;
                                  },
                                  inputName: "Category",
                                  required: true),
                              const OurDivider(),
                              CustomText(
                                text: "Send the invite to:",
                                size: Constants.textDimensionTitle,
                                fontWeight: Fonts.bold,
                                fontFamily: "Raleway",
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              GroupSelector(
                                callback: (val) {
                                  //N:B current user id is already removed from this list
                                  newEventInviteIds = val;
                                },
                              ),
                              const OurDivider(),
                              const MandatoryNote(),
                              SizedBox(
                                height: Constants.distanceBtwDoneNElement,
                              ),
                              BlocConsumer<AddEventCubit, AddEventState>(
                                listener: (context, state) async {
                                  if (state.status == AddEventStatus.success) {
                                    DateTime now = DateTime.now();
                                    int timeStamp = now.millisecondsSinceEpoch;
                                    List<String> splitDateHour =
                                        now.toString().split(".")[0].split(":");
                                    String dateHour =
                                        "${splitDateHour[0]}:${splitDateHour[1]}";

                                    if (newEventInviteIds.isNotEmpty) {
                                      /// Add a notification in the popup notifications
                                      await BlocProvider.of<NotificationCubit>(
                                              context)
                                          .addNewNotification(
                                        userIdsToNotify: newEventInviteIds,
                                        sourceName: currentUser.name,
                                        thingToOpenId: newEventId,
                                        thingToNotifyName: newEventName,
                                        dateHour: dateHour,
                                        timestamp: timeStamp,
                                        eventCategory: newEventCategory,
                                        notificationsInviteEvent: true,
                                        public: false,
                                      );

                                      /// Send a Push Notification to added users
                                      if (mounted) {
                                        await BlocProvider.of<UserBloc>(context)
                                            .sendPushNotificationsToUsers(
                                          userIdsToNotify: newEventInviteIds,
                                          title: currentUser.name +
                                              Constants.titleNotificationEvent,
                                          body:
                                              Constants.bodyNotificationEvent +
                                                  newEventName,
                                          notificationsInviteEvent: true,
                                        );
                                      }
                                    }

                                    if (!private && mounted) {
                                      /// Add a notification for the interested users

                                      List<String> interestedIds =
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .getInterestedUsersToNotify(
                                                  newGroupEventInterests: [
                                            newEventCategory
                                          ]);

                                      interestedIds = interestedIds
                                          .where((id) => currentUser.id != id)
                                          .toList();

                                      interestedIds = interestedIds
                                          .where((id) =>
                                              !newEventInviteIds.contains(id))
                                          .toList();

                                      if (mounted && interestedIds.isNotEmpty) {
                                        await BlocProvider.of<
                                                NotificationCubit>(context)
                                            .addNewNotification(
                                          userIdsToNotify: interestedIds,
                                          sourceName: currentUser.name,
                                          thingToOpenId: newEventId,
                                          thingToNotifyName: newEventName,
                                          dateHour: dateHour,
                                          timestamp: timeStamp,
                                          eventCategory: newEventCategory,
                                          notificationsPublicEvent: true,
                                          public: true,
                                        );
                                        if (mounted) {
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .sendPushNotificationsToUsers(
                                            userIdsToNotify: interestedIds,
                                            title: currentUser.name +
                                                Constants
                                                    .titleNotificationPublicEvent,
                                            body: Constants
                                                    .bodyNotificationPublicEvent +
                                                newEventName,
                                            notificationsPublicEvent: true,
                                          );
                                        }
                                      }
                                    }
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status == AddEventStatus.initial) {
                                    return Center(
                                      child: BlocBuilder<RequiredFieldsCubit,
                                          RequiredFieldsState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              RequiredFieldsStatus.completed) {
                                            return TapFadeText(
                                              key: const Key("activeDone"),
                                              onTap: () async {
                                                await _tapDone(
                                                    context, currentUser);
                                              },
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                            );
                                          } else {
                                            return TapFadeText(
                                              key: const Key("disabledDone"),
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
                                      AddEventStatus.error) {
                                    return const Center(
                                      child: CustomText(
                                        text: "An Error occured",
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: OurCircularProgressIndicator(),
                                    );
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

  Future<void> _tapDone(BuildContext context, UserData currentUser) async {
    newEventId = await BlocProvider.of<AddEventCubit>(context).addEvent(
      eventCreator: currentUser,
      eventName: newEventName,
      eventDescription: newEventDescription,
      category: newEventCategory,
      date: newEventDate!,
      image: image,
      private: private,
      numParticipants: 1,
      location: newEventLocation,
      locationName: newEventLocationName,
    );
  }

  void _tapAddDate(BuildContext context) {
    date.DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now().add(const Duration(hours: 1)),
      maxTime: DateTime.utc(2050, 01, 01),
      currentTime: DateTime.now().add(const Duration(hours: 1)),
      locale: date.LocaleType.en,
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          newEventDate = Timestamp.fromDate(date);
        });
        BlocProvider.of<RequiredFieldsCubit>(context)
            .updateDate(inputDate: newEventDate!);
      },
    );
  }

  Widget _buildTabletAddEventPopup(BuildContext context, UserData currentUser) {
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
                      title: 'New Event',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: PopupTabletConstants.contentPopupPadding(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(
                                        text: "Date and hour:",
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
                                    ],
                                  ),
                                  TapFadeIcon(
                                    key: const Key("add_date"),
                                    iconColor:
                                        Theme.of(context).iconTheme.color!,
                                    icon: AppIcons.edit2Outline,
                                    size: PopupTabletConstants.iconDimension(),
                                    onTap: () {
                                      _tapAddDate(context);
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: PopupTabletConstants
                                        .spaceBtwTitleNTextField()),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: newEventDate == null
                                      ? [
                                          CustomText(
                                            text: "YYYY-MM-DD",
                                            size: 18.r,
                                            fontFamily: "Inter",
                                            fontWeight: Fonts.regular,
                                          ),
                                          CustomText(
                                            text: "hh:mm",
                                            size: 18.r,
                                            fontFamily: "Inter",
                                            fontWeight: Fonts.regular,
                                          ),
                                        ]
                                      : [
                                          CustomText(
                                            text: dateFormatter
                                                .format(newEventDate!.toDate()),
                                            size: 18.r,
                                            fontFamily: "Inter",
                                            fontWeight: Fonts.regular,
                                          ),
                                          CustomText(
                                            text: DateFormat("h:mma")
                                                .format(newEventDate!.toDate()),
                                            size: 18.r,
                                            fontFamily: "Inter",
                                            fontWeight: Fonts.regular,
                                          ),
                                        ],
                                ),
                              ),
                              const OurDivider(),
                              TextPhotoRow(
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
                                setTextCallback: (insertedGroupCaption) {
                                  newEventDescription = insertedGroupCaption;
                                  BlocProvider.of<RequiredFieldsCubit>(context)
                                      .updateCaption(
                                          inputCaption: newEventDescription);
                                },
                                hintText: Constants.eventCaptionHint,
                                inputName: "Caption",
                                required: true,
                              ),
                              const OurDivider(),
                              PrivacySelectorRow(
                                  oldPrivacy: private,
                                  setPrivacyCallback: (privacy) {
                                    private = privacy;
                                  }),
                              const OurDivider(),
                              MapInputRow(
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
                              const OurDivider(),
                              SingleCategoryInputRow(
                                  groupInterestsCallback: (val) {
                                    newEventCategory = val;
                                  },
                                  inputName: "Category",
                                  required: true),
                              const OurDivider(),
                              CustomText(
                                text: "Send the invite to:",
                                size: PopupTabletConstants.textDimensionTitle(),
                                fontWeight: Fonts.bold,
                                fontFamily: "Raleway",
                              ),
                              SizedBox(
                                height: 15.r,
                              ),
                              GroupSelector(
                                callback: (val) {
                                  //N:B current user id is already removed from this list
                                  newEventInviteIds = val;
                                },
                              ),
                              const OurDivider(),
                              const MandatoryNote(),
                              SizedBox(
                                height: PopupTabletConstants
                                    .distanceBtwDoneNElement(),
                              ),
                              BlocConsumer<AddEventCubit, AddEventState>(
                                listener: (context, state) async {
                                  if (state.status == AddEventStatus.success) {
                                    DateTime now = DateTime.now();
                                    int timeStamp = now.millisecondsSinceEpoch;
                                    List<String> splitDateHour =
                                        now.toString().split(".")[0].split(":");
                                    String dateHour =
                                        "${splitDateHour[0]}:${splitDateHour[1]}";

                                    if (newEventInviteIds.isNotEmpty) {
                                      /// Add a notification in the popup notifications
                                      await BlocProvider.of<NotificationCubit>(
                                              context)
                                          .addNewNotification(
                                        userIdsToNotify: newEventInviteIds,
                                        sourceName: currentUser.name,
                                        thingToOpenId: newEventId,
                                        thingToNotifyName: newEventName,
                                        dateHour: dateHour,
                                        timestamp: timeStamp,
                                        eventCategory: newEventCategory,
                                        notificationsInviteEvent: true,
                                        public: false,
                                      );

                                      /// Send a Push Notification to added users
                                      if (mounted) {
                                        await BlocProvider.of<UserBloc>(context)
                                            .sendPushNotificationsToUsers(
                                          userIdsToNotify: newEventInviteIds,
                                          title: currentUser.name +
                                              Constants.titleNotificationEvent,
                                          body:
                                              Constants.bodyNotificationEvent +
                                                  newEventName,
                                          notificationsInviteEvent: true,
                                        );
                                      }
                                    }

                                    if (!private && mounted) {
                                      /// Add a notification for the interested users

                                      List<String> interestedIds =
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .getInterestedUsersToNotify(
                                                  newGroupEventInterests: [
                                            newEventCategory
                                          ]);

                                      interestedIds = interestedIds
                                          .where((id) => currentUser.id != id)
                                          .toList();

                                      interestedIds = interestedIds
                                          .where((id) =>
                                              !newEventInviteIds.contains(id))
                                          .toList();

                                      if (mounted && interestedIds.isNotEmpty) {
                                        await BlocProvider.of<
                                                NotificationCubit>(context)
                                            .addNewNotification(
                                          userIdsToNotify: interestedIds,
                                          sourceName: currentUser.name,
                                          thingToOpenId: newEventId,
                                          thingToNotifyName: newEventName,
                                          dateHour: dateHour,
                                          timestamp: timeStamp,
                                          eventCategory: newEventCategory,
                                          notificationsPublicEvent: true,
                                          public: true,
                                        );
                                        if (mounted) {
                                          await BlocProvider.of<UserBloc>(
                                                  context)
                                              .sendPushNotificationsToUsers(
                                            userIdsToNotify: interestedIds,
                                            title: currentUser.name +
                                                Constants
                                                    .titleNotificationPublicEvent,
                                            body: Constants
                                                    .bodyNotificationPublicEvent +
                                                newEventName,
                                            notificationsPublicEvent: true,
                                          );
                                        }
                                      }
                                    }
                                    if (mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                builder: (context, state) {
                                  if (state.status == AddEventStatus.initial) {
                                    return Center(
                                      child: BlocBuilder<RequiredFieldsCubit,
                                          RequiredFieldsState>(
                                        builder: (context, state) {
                                          if (state.status ==
                                              RequiredFieldsStatus.completed) {
                                            return TapFadeText(
                                              key: const Key("activeDone"),
                                              onTap: () async {
                                                await _tapDone(
                                                    context, currentUser);
                                              },
                                              buttonColor: Theme.of(context)
                                                  .iconTheme
                                                  .color!,
                                              titleButton: 'done',
                                            );
                                          } else {
                                            return TapFadeText(
                                              key: const Key("disabledDone"),
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
                                      AddEventStatus.error) {
                                    return const Center(
                                      child: CustomText(
                                        text: "An Error occured",
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                      child: OurCircularProgressIndicator(),
                                    );
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
