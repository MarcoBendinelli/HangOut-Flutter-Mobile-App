import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/my_events/events_bloc.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/pages/events/add_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_groups_events.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/calendar_widget.dart';
import 'package:hang_out_app/presentation/pages/events/event_card/event_card.dart';

class EventsPage extends StatelessWidget {
  final String heroTag = 'add-event-hero';

  const EventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentUserId = context.select((AppBloc bloc) => bloc.state.user.id);

    return SafeArea(
      child: Padding(
        padding: Constants.pagePadding,
        child: BlocProvider(
          create: (context) =>
              EventsBloc(eventsRepository: context.read<MyEventsRepository>())
                ..add(LoadEvents(userId: currentUserId)),
          child: Builder(builder: (context) {
            return Column(
              children: [
                /// Header
                TopBarGroupsEventsPages(
                  title: "My Events",
                  onAddPress: () {
                    Navigator.of(context).push(
                      HeroDialogRoute(
                        builder: (_) => AddEventPopup(
                          heroTag: heroTag,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 15.h,
                ),
                BlocBuilder<EventsBloc, EventsState>(
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
                SizedBox(
                  height: 30.0.h,
                ),
                //New cards
                BlocBuilder<EventsBloc, EventsState>(
                  builder: (context, state) {
                    if (state is EventsLoading) {
                      return Padding(
                        padding: EdgeInsets.only(top: Constants.heightError),
                        child: const OurCircularProgressIndicator(),
                      );
                    }
                    if (state is EventsLoaded) {
                      if (state.events.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: Constants.heightError),
                          child: const CustomText(
                            text: "You don't have any events yet!",
                          ),
                        );
                      } else {
                        return Expanded(
                          child: MasonryGridView.count(
                            scrollDirection: Axis.vertical,
                            itemCount: state.events.length,
                            itemBuilder: (context, index) {
                              return _buildEventItem(state.events[index]);
                            },
                            crossAxisCount: 2,
                            mainAxisSpacing: Constants.spaceBtwCards.r,
                            crossAxisSpacing: Constants.spaceBtwCards.r,
                          ),
                        );
                      }
                    } else {
                      return const Center(
                        child: CustomText(
                            text: "An error occurred while loading cards"),
                      );
                    }
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEventItem(Event data) {
    return EventCard(data);
  }
}

/*
To have the shade effet

return Expanded(
  child: ShaderMask(
    shaderCallback: (Rect rect) {
      return Constants.blurLinearGradient
          .createShader(rect);
    },
    // blendMode: BlendMode.darken,
    blendMode: BlendMode.dstOut,
    child: MasonryGridView.count(
      scrollDirection: Axis.vertical,
      itemCount: state.events.length,
      itemBuilder: (context, index) {
        return _buildEventItem(state.events[index]);
      },
      crossAxisCount: 2,
      mainAxisSpacing: Constants.spaceBtwCards.h,
      crossAxisSpacing: Constants.spaceBtwCards.w,
    ),
  ),
);
*/