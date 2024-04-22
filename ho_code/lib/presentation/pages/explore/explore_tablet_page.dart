import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_event_cards.dart';
import 'package:hang_out_app/presentation/pages/explore/explore_group_cards.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_tablet_pages.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/tablet_grid_categories/tablet_landscape_grid_categories.dart';
import 'package:hang_out_app/presentation/widgets/tablet_grid_categories/tablet_portrait_grid_categories.dart';

class ExploreTabletPage extends StatefulWidget {
  final List<String> interests;

  const ExploreTabletPage({super.key, required this.interests});

  @override
  State<ExploreTabletPage> createState() => _ExploreTabletPageState();
}

class _ExploreTabletPageState extends State<ExploreTabletPage> {
  late List<String> _categories;
  bool _onEvents = true;
  bool tapped = false;
  String insertedUserLetters = "";
  bool areAnyNotifications = false;

  @override
  void initState() {
    _categories = widget.interests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = context.select((AppBloc bloc) => bloc.state.user.id);
    //_categories = context.select((UserBloc bloc) => bloc.state.user.interests);

    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationsBloc>(
          create: (context) => NotificationsBloc(
              notificationsRepository: context.read<NotificationsRepository>())
            ..add(LoadNotifications(userId: currentUserId)),
        ),
        BlocProvider<ExploreBloc>(
          create: (context) => ExploreBloc(
              eventsRepository: context.read<MyEventsRepository>(),
              groupsRepository: context.read<MyGroupsRepository>())
            ..add(LoadExploreEvents(
                userId: currentUserId,
                categories: _categories)),
        )
      ],
      child: OrientationBuilder(builder: (context, orientation) {
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: SafeArea(
              child: Padding(
                  padding: TabletConstants.pagePadding(),
                  child: _buildExploreForPortrait(
                      currentUserId, _categories, context)),
            ),
          );
        }
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: Padding(
                padding: TabletConstants.pagePadding(),
                child: _buildExploreForLandscape(
                    currentUserId, _categories, context)),
          ),
        );
      }),
    );
  }

  Widget _buildExploreForPortrait(
      String currentUserId, List<String> interests, BuildContext context) {
    return Column(
      children: [
        const TopBarTabletPages(),
        Flexible(
          child: Padding(
            padding: TabletConstants.tabletInsidePagePadding(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: TabletConstants.resizeW(320),
                      height: TabletConstants.formInputHeight(),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(TabletConstants.resizeR(30)),
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
                              right: TabletConstants.resizeW(30),
                              left: TabletConstants.resizeW(30),
                              top: TabletConstants.resizeH(11)),
                          prefixIcon: tapped
                              ? null
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: TabletConstants.resizeW(15),
                                      ),
                                      Icon(
                                        AppIcons.searchOutline,
                                        size: TabletConstants.iconDimension(),
                                      ),
                                      SizedBox(
                                        width: TabletConstants.resizeW(15),
                                      ),
                                      CustomText(
                                        text: insertedUserLetters == ""
                                            ? "Search"
                                            : insertedUserLetters,
                                        fontFamily: 'Inter',
                                        fontWeight: Fonts.regular,
                                        color: insertedUserLetters == ""
                                            ? Theme.of(context).hintColor
                                            : Theme.of(context).primaryColor,
                                        size: TabletConstants.resizeR(24),
                                      )
                                    ],
                                  ),
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
                          color: Theme.of(context).primaryColor,
                          fontSize: TabletConstants.resizeR(24),
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
                          isDense: false,
                          borderRadius: BorderRadius.circular(
                              TabletConstants.resizeR(20)),
                          icon: Icon(
                            AppIcons.chevronDownOutline,
                            size: TabletConstants.resizeR(24),
                          ),
                          items: [
                            DropdownMenuItem<bool>(
                              value: true,
                              child: CustomText(
                                key: const Key("select-events"),
                                text: "Events",
                                size: TabletConstants.resizeR(24),
                                fontFamily: "Inter",
                                fontWeight: Fonts.regular,
                              ),
                            ),
                            DropdownMenuItem<bool>(
                              value: false,
                              child: CustomText(
                                key: const Key("select-groups"),
                                text: "Groups",
                                size: TabletConstants.resizeR(24),
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
                  height: TabletConstants.resizeH(30),
                ),
                Flexible(
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      TabletPortraitGridCategories(
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
                      BlocBuilder<ExploreBloc, ExploreState>(
                        builder: (context, state) {
                          if (state is ExploreEventsLoading) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: TabletConstants.resizeH(250),
                                  horizontal: TabletConstants.resizeW(150)),
                              child: const Center(
                                child: OurCircularProgressIndicator(),
                              ),
                            );
                          } else if (state is ExploreEventsLoaded) {
                            return ExploreEventCards(
                              events: state.events,
                              insertedUserLetters: insertedUserLetters,
                              isPortrait: true,
                            );
                          } else if (state is ExploreGroupsLoaded) {
                            return ExploreGroupCards(
                              groups: state.groups,
                              insertedUserLetters: insertedUserLetters,
                              isPortrait: true,
                            );
                          } else {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: TabletConstants.resizeH(250),
                                  horizontal: TabletConstants.resizeW(150)),
                              child: Center(
                                child: CustomText(
                                  size: TabletConstants.resizeR(14),
                                  text: "An error occurred while loading cards",
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExploreForLandscape(
      String currentUserId, List<String> interests, BuildContext context) {
    return Column(
      children: [
        const TopBarTabletPages(),
        Flexible(
          child: Padding(
            padding: TabletConstants.tabletInsidePagePadding(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: TabletConstants.resizeW(320),
                      height: TabletConstants.formInputHeight(),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(TabletConstants.resizeR(30)),
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
                              right: TabletConstants.resizeW(30),
                              left: TabletConstants.resizeW(30),
                              top: TabletConstants.resizeH(11)),
                          prefixIcon: tapped
                              ? null
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: TabletConstants.resizeW(15),
                                      ),
                                      Icon(
                                        AppIcons.searchOutline,
                                        size: TabletConstants.iconDimension(),
                                      ),
                                      SizedBox(
                                        width: TabletConstants.resizeW(15),
                                      ),
                                      CustomText(
                                        text: insertedUserLetters == ""
                                            ? "Search"
                                            : insertedUserLetters,
                                        fontFamily: 'Inter',
                                        fontWeight: Fonts.regular,
                                        color: insertedUserLetters == ""
                                            ? Theme.of(context).hintColor
                                            : Theme.of(context).primaryColor,
                                        size: TabletConstants.resizeR(24),
                                      )
                                    ],
                                  ),
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
                          color: Theme.of(context).primaryColor,
                          fontSize: TabletConstants.resizeR(24),
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
                          isDense: false,
                          borderRadius: BorderRadius.circular(
                              TabletConstants.resizeR(20)),
                          icon: Icon(
                            AppIcons.chevronDownOutline,
                            size: TabletConstants.resizeW(24),
                          ),
                          items: [
                            DropdownMenuItem<bool>(
                              value: true,
                              child: CustomText(
                                key: const Key("select-events"),
                                text: "Events",
                                size: TabletConstants.resizeR(24),
                                fontFamily: "Inter",
                                fontWeight: Fonts.regular,
                              ),
                            ),
                            DropdownMenuItem<bool>(
                              value: false,
                              child: CustomText(
                                key: const Key("select-groups"),
                                text: "Groups",
                                size: TabletConstants.resizeR(24),
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
                  height: TabletConstants.resizeH(30),
                ),
                Flexible(
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      TabletLandscapeGridCategories(
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
                      BlocBuilder<ExploreBloc, ExploreState>(
                        builder: (context, state) {
                          if (state is ExploreEventsLoading) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: TabletConstants.resizeW(390)),
                              child: const Center(
                                child: OurCircularProgressIndicator(),
                              ),
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
                              padding: EdgeInsets.only(
                                  left: TabletConstants.resizeW(390)),
                              child: const Center(
                                child: CustomText(
                                  size: 14,
                                  text: "An error occurred while loading cards",
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
