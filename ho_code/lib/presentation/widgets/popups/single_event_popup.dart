import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/specific_group_event/specific_group_event_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/events/delete_join_leave_event/delete_join_leave_event_cubit.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/animations/from_right_page_route.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/members.dart';
import 'package:hang_out_app/presentation/utils/animations/custom_rect_tween.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/our_divider.dart';
import 'package:hang_out_app/presentation/widgets/popups/event_popup_widgets/delete_leave_event.dart';
import 'package:hang_out_app/presentation/widgets/popups/map_goto_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/modify_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/event_popup_widgets/join_event.dart';

class SingleEventPopup extends StatefulWidget {
  final String heroTag;
  final String eventId;
  final bool fromExplore;
  final bool fromNotification;

  const SingleEventPopup(
      {super.key,
      required this.heroTag,
      required this.eventId,
      this.fromExplore = false,
      this.fromNotification = false});

  @override
  State<SingleEventPopup> createState() => _SingleEventPopupState();
}

class _SingleEventPopupState extends State<SingleEventPopup> {
  bool alreadyPop = false;
  @override
  Widget build(BuildContext context) {
    UserData currentUser = context.select((UserBloc bloc) => bloc.state.user);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DeleteJoinLeaveEventCubit(
              eventsRepository: context.read<MyEventsRepository>()),
        ),
        BlocProvider(
          create: (context) => SpecificGroupEventBloc(
              eventsRepository: context.read<MyEventsRepository>(),
              groupsRepository: context.read<MyGroupsRepository>())
            ..add(LoadSpecificEvent(eventId: widget.eventId)),
        ),
        BlocProvider(
          create: (context) => MembersBloc(
              eventsRepository: context.read<MyEventsRepository>(),
              groupsRepository: context.read<MyGroupsRepository>(),
              userRepository: context.read<UserRepository>())
            ..add(LoadMembersInEvent(eventId: widget.eventId)),
        )
      ],
      child: BlocConsumer<SpecificGroupEventBloc, SpecificGroupEventState>(
        listener: (context, state) {
          if (state is SpecificGroupEventError) {
            if (context.mounted) {
              alreadyPop = true;
              Navigator.of(context).pop();
              widget.fromExplore ? null : Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          if (state is SpecificGroupEventLoaded) {
            if (getSize(context) == ScreenSize.normal) {
              return _buildLoadedCard(state.event!, currentUser);
            }
            return _buildTabletLoadedCard(state.event!, currentUser);
          } else {
            return const Center(
              child: OurCircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadedCard(Event event, UserData currentUser) {
    return SafeArea(
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
                  borderRadius: BorderRadius.circular(Constants.borderRadius)),
              child: SizedBox(
                height: Constants.heightEventPopup,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _TopPart(event: event),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: CategoryColors.getColor(event.category)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 34.w, vertical: 15.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        CategoryIcons.mapper[event.category],
                                        color: AppColors.whiteColor,
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      CustomText(
                                        text: "${event.category} event",
                                        color: AppColors.whiteColor,
                                        fontWeight: Fonts.semiBold,
                                      ),
                                    ],
                                  ),
                                  Icon(event.private
                                      ? AppIcons.private
                                      : AppIcons.public),
                                ],
                              ),
                              SizedBox(
                                height: 30.h,
                              ),
                              CustomText(
                                text: event.name,
                                size: 24.r,
                                fontWeight: Fonts.bold,
                                fontFamily: "Raleway",
                                color: event.category == "other"
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              CustomText(
                                text: event.description,
                                size: 12.r,
                                fontWeight: Fonts.regular,
                                fontFamily: "Inter",
                                color: event.category == "other"
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                              ),
                              SizedBox(
                                height: 30.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: Constants.contentPopupPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Members(
                              nParticipants: event.numParticipants!,
                              text: 'Participants',
                            ),
                            SizedBox(
                              height: Constants.borderPopupPadding.h,
                            ),
                            MapGoToRow(
                                location: event.location,
                                locationName: event.locationName),
                            SizedBox(
                              height: Constants.distanceBtwDoneNElement,
                            ),
                            BlocListener<DeleteJoinLeaveEventCubit,
                                    DeleteJoinLeaveEventState>(
                                listener: (context, state) {
                                  if (context.mounted && !alreadyPop) {
                                    if (state.status ==
                                        DeleteJoinLeaveEventStatus.success) {
                                      Navigator.of(context).pop();
                                      widget.fromExplore
                                          ? null
                                          : Navigator.of(context).pop();
                                    }
                                  }
                                },
                                child: widget.fromNotification
                                    ? event.members!.contains(currentUser.id)
                                        ? DeleteLeaveEvent(
                                            event: event,
                                            currentUser: currentUser,
                                          )
                                        : JoinEvent(
                                            eventId: event.id,
                                            currentUser: currentUser,
                                          )
                                    : widget.fromExplore
                                        ? JoinEvent(
                                            fromExplore: true,
                                            eventId: event.id,
                                            currentUser: currentUser,
                                          )
                                        : DeleteLeaveEvent(
                                            event: event,
                                            currentUser: currentUser,
                                          )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLoadedCard(Event event, UserData currentUser) {
    // return OrientationBuilder(builder: (context, orientation) {
    //   if (orientation == Orientation.portrait) {
    //     ScreenUtil.init(context, designSize: tabletPortraitSize);
    //   } else {
    //     ScreenUtil.init(
    //       context,
    //       designSize: tabletLandscapeSize,
    //     );
    //   }
    return SafeArea(
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
              height: PopupTabletConstants.popupDimension(),
              width: PopupTabletConstants.popupDimension(),
              child: Row(
                children: [
                  Container(
                    width: PopupTabletConstants.popupDimension() / 2,
                    // height: PopupTabletConstants.popupDimension(),
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(Constants.borderRadius)),
                        color: CategoryColors.getColor(event.category)),
                    child: Padding(
                      padding: PopupTabletConstants.contentPopupPadding(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CategoryIcons.mapper[event.category],
                                color: AppColors.whiteColor,
                                size: PopupTabletConstants.iconDimension(),
                              ),
                              SizedBox(
                                width: PopupTabletConstants.resize(12),
                              ),
                              CustomText(
                                text: "${event.category} event",
                                color: AppColors.whiteColor,
                                fontWeight: Fonts.semiBold,
                                size: PopupTabletConstants.resize(20),
                              ),
                            ],
                          ),
                          // SizedBox(
                          //   height: PopupTabletConstants.resize(43),
                          // ),
                          CustomText(
                            text: event.name,
                            size: PopupTabletConstants.textDimensionBigTitle(),
                            fontWeight: Fonts.bold,
                            fontFamily: "Raleway",
                            color: event.category == "other"
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                          ),
                          // SizedBox(
                          //   height: PopupTabletConstants.resize(23),
                          // ),
                          CustomText(
                            text: event.description,
                            size:
                                PopupTabletConstants.textDimensionDescription(),
                            fontWeight: Fonts.regular,
                            fontFamily: "Inter",
                            color: event.category == "other"
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                          ),
                          // SizedBox(
                          //   height: PopupTabletConstants.resize(45),
                          // ),
                          event.photo == ""
                              ? SizedBox(
                                  height: PopupTabletConstants
                                      .eventPopupImageHeight(),
                                  width: PopupTabletConstants
                                      .eventPopupImageHeight(),
                                )
                              : Container(
                                  height: PopupTabletConstants
                                      .eventPopupImageHeight(),
                                  width: PopupTabletConstants
                                      .eventPopupImagewidth(),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: ImageManager.getImageProvider(
                                          event.photo!),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        Constants.borderRadius),
                                  ),
                                ),
                          // SizedBox(
                          //   height:  PopupTabletConstants.resize(70),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: PopupTabletConstants.popupDimension() / 2,
                    child: Padding(
                      padding: PopupTabletConstants.contentPopupPadding(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              event.creatorId == currentUser.id
                                  ? TapFadeIcon(
                                      iconColor:
                                          Theme.of(context).iconTheme.color!,
                                      onTap: () {
                                        _tapEdit(context, event);
                                      },
                                      icon: AppIcons.edit2Outline,
                                      size:
                                          PopupTabletConstants.iconDimension())
                                  : const SizedBox(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomText(
                                    text: event.private ? "private" : "public",
                                    size: PopupTabletConstants.resize(20),
                                    fontWeight: Fonts.semiBold,
                                  ),
                                  Icon(
                                    event.private
                                        ? AppIcons.private
                                        : AppIcons.public,
                                    size: PopupTabletConstants.iconDimension(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const OurDivider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  CustomText(
                                    text: event.getDay(),
                                    size: PopupTabletConstants.resize(50),
                                    fontWeight: Fonts.semiBold,
                                    fontFamily: 'Inter',
                                  ),
                                  SizedBox(
                                    height: PopupTabletConstants.resize(10),
                                  ),
                                  CustomText(
                                    text:
                                        "${event.getMonth()} ${event.getYear()}",
                                    size: PopupTabletConstants.resize(20),
                                    fontWeight: Fonts.bold,
                                    fontFamily: 'Inter',
                                  ),
                                  SizedBox(
                                    height: PopupTabletConstants.resize(10),
                                  ),
                                  CustomText(
                                    text: event.getDayName(),
                                    size: PopupTabletConstants.resize(18),
                                    fontWeight: Fonts.light,
                                    fontFamily: 'Inter',
                                  ),
                                ],
                              ),
                              CustomText(
                                text: event.getHour(),
                                size: PopupTabletConstants.resize(18),
                                fontWeight: Fonts.regular,
                                fontFamily: 'Inter',
                              ),
                            ],
                          ),
                          const OurDivider(),
                          Members(
                            nParticipants: event.numParticipants!,
                            text: 'Participants',
                          ),
                          const OurDivider(),
                          MapGoToRow(
                              location: event.location,
                              locationName: event.locationName),
                          SizedBox(
                            height:
                                PopupTabletConstants.distanceBtwDoneNElement(),
                          ),
                          BlocListener<DeleteJoinLeaveEventCubit,
                              DeleteJoinLeaveEventState>(
                            listener: (context, state) {
                              if (context.mounted && !alreadyPop) {
                                if (state.status ==
                                    DeleteJoinLeaveEventStatus.success) {
                                  Navigator.of(context).pop();
                                  widget.fromExplore
                                      ? null
                                      : Navigator.of(context).pop();
                                }
                              }
                            },
                            child: widget.fromNotification
                                ? event.members!.contains(currentUser.id)
                                    ? DeleteLeaveEvent(
                                        event: event,
                                        currentUser: currentUser,
                                      )
                                    : JoinEvent(
                                        eventId: event.id,
                                        currentUser: currentUser,
                                      )
                                : widget.fromExplore
                                    ? JoinEvent(
                                        eventId: event.id,
                                        currentUser: currentUser,
                                      )
                                    : DeleteLeaveEvent(
                                        event: event,
                                        currentUser: currentUser,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // });
  }
}

void _tapEdit(BuildContext context, Event event) {
  if (context.mounted) {
    Navigator.of(context).push(
      FromRightPageRoute(
        builder: (BuildContext newContext) => ModifyEventPopup(
          heroTag: 'heroTag',
          oldEvent: event,
        ),
      ),
    );
    // Navigator.of(context).push<void>(ChatView.route());
  }
}

class _TopPart extends StatelessWidget {
  final Event _event;

  const _TopPart({required Event event}) : _event = event;

  @override
  Widget build(BuildContext context) {
    UserData currentUser = context.select((UserBloc bloc) => bloc.state.user);
    return Padding(
      padding: Constants.contentPopupPadding,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TapFadeIcon(
                          iconColor: Theme.of(context).iconTheme.color!,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          icon: AppIcons.arrowIosBackOutline,
                          size: Constants.iconDimension,
                        ),
                        _event.creatorId == currentUser.id
                            ? TapFadeIcon(
                                iconColor: Theme.of(context).iconTheme.color!,
                                onTap: () {
                                  _tapEdit(context, _event);
                                },
                                icon: AppIcons.edit2Outline,
                                size: Constants.iconDimension)
                            : const SizedBox(),
                      ],
                    ),
                    SizedBox(
                      height: Constants.iconDimension,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0.h),
                      child: Divider(
                        color: Theme.of(context).dividerColor,
                        thickness: 0.2,
                      ),
                    ),
                    CustomText(
                      text: _event.getDay(),
                      size: 48,
                      fontWeight: Fonts.semiBold,
                      fontFamily: 'Inter',
                    ),
                    CustomText(
                      text: "${_event.getMonth()} ${_event.getYear()}",
                      size: 14,
                      fontWeight: Fonts.bold,
                      fontFamily: 'Inter',
                    ),
                  ],
                ),
              ),
              _event.photo == ""
                  ? const SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(left: 15.0.w),
                      child: Container(
                        height: 120.h,
                        width: 120.w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: ImageManager.getImageProvider(_event.photo!),
                          ),
                          borderRadius:
                              BorderRadius.circular(Constants.borderRadius),
                        ),
                      ),
                    ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: _event.getDayName(),
                size: 14,
                fontWeight: Fonts.light,
                fontFamily: 'Inter',
              ),
              CustomText(
                text: _event.getHour(),
                size: 14,
                fontWeight: Fonts.regular,
                fontFamily: 'Inter',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
