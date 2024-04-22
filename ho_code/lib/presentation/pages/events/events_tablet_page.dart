import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/my_events/events_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/presentation/pages/events/add_event_popup.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/event_tablet_card.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_tablet_pages.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/calendar_widget.dart';

class EventsTabletPage extends StatelessWidget {
  final String heroTag = 'add-event-hero';

  const EventsTabletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentUserId = context.select((AppBloc bloc) => bloc.state.user.id);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              EventsBloc(eventsRepository: context.read<MyEventsRepository>())
                ..add(LoadEvents(userId: currentUserId)),
        ),
        BlocProvider<NotificationsBloc>(
          create: (context) => NotificationsBloc(
              notificationsRepository: context.read<NotificationsRepository>())
            ..add(LoadNotifications(userId: currentUserId)),
        ),
      ],
      child: SafeArea(
        child: Padding(
          padding: TabletConstants.pagePadding(),
          child: Builder(builder: (context) {
            return Column(
              children: [
                /// Header
                const TopBarTabletPages(),
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? _buildPortraitEventCards(context)
                    : _buildLandscapeEventCards(context)
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPortraitEventCards(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: TabletConstants.tabletInsidePagePadding(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Row(
                  children: [
                    CustomText(
                      text: "New event",
                      fontFamily: "Inter",
                      fontWeight: Fonts.regular,
                      size: TabletConstants.resizeR(24),
                    ),
                    SizedBox(
                      width: TabletConstants.resizeW(10),
                    ),
                    TapFadeIcon(
                      key: const Key("add"),
                      iconColor: Theme.of(context).iconTheme.color!,
                      onTap: () {
                        Navigator.of(context).push(
                          HeroDialogRoute(
                            builder: (_) => AddEventPopup(
                              heroTag: heroTag,
                            ),
                          ),
                        );
                      },
                      icon: AppIcons.plusCircleOutline,
                      size: TabletConstants.iconDimension(),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: TabletConstants.spaceBtwCards(),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 1 / 3 -
                  TabletConstants.resizeH(40),
              child: BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) {
                  if (state is EventsLoading) {
                    return const CalendarWidget();
                  } else if (state is EventsLoaded) {
                    return CalendarWidget(events: state.events);
                  } else {
                    return const Center(
                      child: CustomText(
                          text: "An error occurred while loading dates"),
                    );
                  }
                },
              ),
            ),
            SizedBox(
              height: TabletConstants.spaceBtwCardsGroupsPage(),
            ),
            //New cards
            Expanded(
              child: BlocBuilder<EventsBloc, EventsState>(
                builder: (context, state) {
                  if (state is EventsLoading) {
                    return SizedBox(
                        height: TabletConstants.resizeR(36),
                        width: TabletConstants.resizeR(36),
                        child: const Center(
                            child: OurCircularProgressIndicator()));
                  }
                  if (state is EventsLoaded) {
                    if (state.events.isEmpty) {
                      return const Center(
                        child: CustomText(
                          text: "You don't have any events yet!",
                        ),
                      );
                    } else {
                      return MasonryGridView.count(
                        scrollDirection: Axis.vertical,
                        itemCount: state.events.length,
                        itemBuilder: (context, index) {
                          return _buildEventItem(state.events[index]);
                        },
                        crossAxisCount: 3,
                        mainAxisSpacing:
                            TabletConstants.spaceBtwCardsGroupsPage(),
                        crossAxisSpacing:
                            TabletConstants.spaceBtwCardsGroupsPage(),
                      );
                    }
                  } else {
                    return const Center(
                      child: Text("An error occurred while loading cards"),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeEventCards(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: TabletConstants.tabletInsidePagePadding(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Row(
                  children: [
                    CustomText(
                      text: "New event",
                      fontFamily: "Inter",
                      fontWeight: Fonts.regular,
                      size: TabletConstants.resizeR(24),
                    ),
                    SizedBox(
                      width: TabletConstants.resizeW(10),
                    ),
                    TapFadeIcon(
                      key: const Key("add"),
                      iconColor: Theme.of(context).iconTheme.color!,
                      onTap: () {
                        Navigator.of(context).push(
                          HeroDialogRoute(
                            builder: (_) => AddEventPopup(
                              heroTag: heroTag,
                            ),
                          ),
                        );
                      },
                      icon: AppIcons.plusCircleOutline,
                      size: TabletConstants.iconDimension(),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: TabletConstants.spaceBtwCards(),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2 -
                        TabletConstants.resizeW(110),
                    height: 
                        TabletConstants.resizeH(735),
                    child: BlocBuilder<EventsBloc, EventsState>(
                      builder: (context, state) {
                        if (state is EventsLoading) {
                          return const CalendarWidget();
                        } else if (state is EventsLoaded) {
                          return CalendarWidget(events: state.events);
                        } else {
                          return const Center(
                            child:
                                Text("An error occurred while loading dates"),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: TabletConstants.spaceBtwCardsGroupsPage(),
                  ),
                  Expanded(
                    child: BlocBuilder<EventsBloc, EventsState>(
                      builder: (context, state) {
                        if (state is EventsLoading) {
                          return const Center(
                              child: OurCircularProgressIndicator());
                        }
                        if (state is EventsLoaded) {
                          if (state.events.isEmpty) {
                            return const Center(
                              child: CustomText(
                                text: "You don't have any events yet!",
                              ),
                            );
                          } else {
                            return MasonryGridView.count(
                              scrollDirection: Axis.vertical,
                              itemCount: state.events.length,
                              itemBuilder: (context, index) {
                                return _buildEventItem(state.events[index]);
                              },
                              crossAxisCount: 2,
                              mainAxisSpacing:
                                  TabletConstants.spaceBtwCardsGroupsPage(),
                              crossAxisSpacing:
                                  TabletConstants.spaceBtwCardsGroupsPage(),
                            );
                          }
                        } else {
                          return const Center(
                            child:
                                Text("An error occurred while loading cards"),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(Event data) {
    return EventTabletCard(data);
  }
}


// child: ShaderMask(
//                             shaderCallback: (Rect rect) {
//                               return Constants.blurLinearGradient
//                                   .createShader(rect);
//                             },
//                             // blendMode: BlendMode.darken,
//                             blendMode: BlendMode.dstOut,
//                             child: MasonryGridView.count(
//                               scrollDirection: Axis.vertical,
//                               itemCount: state.events.length,
//                               itemBuilder: (context, index) {
//                                 return _buildEventItem(state.events[index]);
//                               },
//                               crossAxisCount: 2,
//                               mainAxisSpacing: Constants.spaceBtwCards.h,
//                               crossAxisSpacing: Constants.spaceBtwCards.w,
//                             ),
//                           ),