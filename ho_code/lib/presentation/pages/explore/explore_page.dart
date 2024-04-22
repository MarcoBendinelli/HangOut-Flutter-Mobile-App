import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_event_cards.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_group_cards.dart';
import 'package:hang_out_app/presentation/utils/animations/from_top_page_route.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/notifications/notifications_popup.dart';
import 'package:hang_out_app/presentation/widgets/scroll_category/multi_scroll_category.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<String> _categories = [];
  bool _onEvents = true;
  bool tapped = false;
  String insertedUserLetters = "";
  bool areAnyNotifications = false;
  bool areNotificationsLoaded = false;

  @override
  Widget build(BuildContext context) {
    String currentUserId = context.select((AppBloc bloc) => bloc.state.user.id);
    List<String> interests =
        context.select((UserBloc bloc) => bloc.state.user.interests);
    Map<int, String> selectedIndexs = <int, String>{};
    var mapper = CategoryColors.mapper;
    for (var i = 0; i < mapper.entries.length; i++) {
      if (interests.contains(mapper.entries.elementAt(i).key)) {
        selectedIndexs.putIfAbsent(i, () => mapper.entries.elementAt(i).key);
      }
    }
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Padding(
          padding: Constants.pagePadding,
          child: MultiBlocProvider(
            providers: [
              BlocProvider<NotificationsBloc>(
                create: (context) => NotificationsBloc(
                    notificationsRepository:
                        context.read<NotificationsRepository>())
                  ..add(LoadNotifications(userId: currentUserId)),
              ),
              BlocProvider<ExploreBloc>(
                create: (context) => ExploreBloc(
                    eventsRepository: context.read<MyEventsRepository>(),
                    groupsRepository: context.read<MyGroupsRepository>())
                  ..add(LoadExploreEvents(
                      userId: currentUserId, categories: interests)),
              )
            ],
            child: Builder(builder: (context) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "HangOut",
                        size: 20.r,
                        fontFamily: "Inter",
                        fontWeight: Fonts.bold,
                      ),
                      BlocListener<NotificationsBloc, NotificationsState>(
                        listener: (context, state) {
                          if (state is NotificationsLoaded) {
                            if (state.notifications.isNotEmpty) {
                              setState(() {
                                areNotificationsLoaded = true;
                                areAnyNotifications = true;
                              });
                            } else {
                              setState(() {
                                areNotificationsLoaded = true;
                                areAnyNotifications = false;
                              });
                            }
                          } else if (state is NotificationsLoading) {
                            setState(() {
                              areNotificationsLoaded = false;
                            });
                          }
                        },
                        child: Builder(builder: (context) {
                          if (areNotificationsLoaded) {
                            return TapFadeIcon(
                              iconColor: Theme.of(context).iconTheme.color!,
                              onTap: () {
                                Navigator.of(context).push(FromTopPageRoute(
                                    builder: (newContext) => BlocProvider.value(
                                          value: BlocProvider.of<
                                              NotificationsBloc>(context),
                                          child: const NotificationsPopup(
                                            heroTag: "notifications",
                                          ),
                                        )));
                              },
                              icon: areAnyNotifications
                                  ? AppIcons.bell
                                  : AppIcons.bellOutline,
                              size: Constants.iconDimension,
                            );
                          } else {
                            return SizedBox(
                              height: Constants.iconDimension,
                              width: Constants.iconDimension,
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 200.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        //padding: EdgeInsets.only(right: 10.0.w),
                        child: TextField(
                          onTap: () {
                            setState(() {
                              tapped = true;
                            });
                          },
                          onTapOutside: (_) {
                            setState(() {
                              tapped = false;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                                right: 15.0.w, left: 15.0.w, top: 5.0.h),
                            prefixIcon: tapped
                                ? null
                                : Icon(
                                    AppIcons.searchOutline,
                                    size: Constants.iconDimension,
                                  ),
                            prefixIconColor: Theme.of(context).hintColor,
                            isDense: true,
                            hintText: "Search",
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          textAlign: TextAlign.start,
                          onChanged: (insertedLetters) {
                            setState(() {
                              insertedUserLetters = insertedLetters;
                            });
                          },
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: Fonts.regular,
                            color: AppColors.blackColor,
                            fontSize: Constants.groupNameTextDimension,
                          ),
                        ),
                      ),
                      BlocBuilder<ExploreBloc, ExploreState>(
                          builder: (context, state) {
                        return DropdownButton(
                            key: const Key("drop-down"),
                            value: _onEvents,
                            elevation: 8,
                            underline: Container(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            isDense: true,
                            borderRadius: BorderRadius.circular(20.r),
                            icon: const Icon(AppIcons.chevronDownOutline),
                            items: [
                              DropdownMenuItem<bool>(
                                value: true,
                                child: CustomText(
                                  key: const Key("select-events"),
                                  text: "Events",
                                  size: 20.r,
                                  fontFamily: "Inter",
                                  fontWeight: Fonts.regular,
                                ),
                              ),
                              DropdownMenuItem<bool>(
                                value: false,
                                child: CustomText(
                                  key: const Key("select-groups"),
                                  text: "Groups",
                                  size: 20.r,
                                  fontFamily: "Inter",
                                  fontWeight: Fonts.regular,
                                ),
                              ),
                            ],
                            onChanged: (bool? value) {
                              setState(() {
                                _onEvents = value!;
                                context.read<ExploreBloc>().add(_onEvents
                                    ? LoadExploreEvents(
                                        userId: currentUserId,
                                        categories: _categories)
                                    : LoadExploreGroups(
                                        userId: currentUserId,
                                        categories: _categories));
                              });
                            });
                      })
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  MultiScrollCategory(
                      callback: (selectedCategories) {
                        _categories = selectedCategories;
                        context.read<ExploreBloc>().add(
                              _onEvents
                                  ? LoadExploreEvents(
                                      userId: currentUserId,
                                      categories: _categories)
                                  : LoadExploreGroups(
                                      userId: currentUserId,
                                      categories: _categories),
                            );
                      },
                      interests: interests),
                  SizedBox(
                    height: 10.h,
                  ),
                  BlocBuilder<ExploreBloc, ExploreState>(
                    builder: (context, state) {
                      if (state is ExploreEventsLoading) {
                        return Padding(
                          padding: EdgeInsets.only(top: Constants.heightError),
                          child: const OurCircularProgressIndicator(),
                        );
                      } else if (state is ExploreEventsLoaded) {
                        return ExploreEventCards(
                            events: state.events,
                            insertedUserLetters: insertedUserLetters);
                      } else if (state is ExploreGroupsLoaded) {
                        return ExploreGroupCards(
                            groups: state.groups,
                            insertedUserLetters: insertedUserLetters);
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(top: Constants.heightError),
                          child: const CustomText(
                              text: "An error occurred while loading cards"),
                        );
                      }
                    },
                  ),
                  // const ExploreGroupCards(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
