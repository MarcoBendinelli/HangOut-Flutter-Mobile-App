import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/events/delete_join_leave_event/delete_join_leave_event_cubit.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';

class JoinEvent extends StatelessWidget {
  final UserData currentUser;
  final String eventId;
  final bool fromExplore;
  const JoinEvent(
      {super.key,
      required this.currentUser,
      required this.eventId,
      this.fromExplore = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<DeleteJoinLeaveEventCubit, DeleteJoinLeaveEventState>(
        builder: (context, state) {
          if (state.status == DeleteJoinLeaveEventStatus.initial) {
            return TapFadeText(
              onTap: () async {
                await BlocProvider.of<DeleteJoinLeaveEventCubit>(context)
                    .joinEvent(user: currentUser, eventId: eventId);
                //only if from explore
                if (fromExplore && context.mounted) {
                  BlocProvider.of<ExploreBloc>(context)
                      .add(LoadExploreEvents(userId: currentUser.id));
                }
              },
              buttonColor: Theme.of(context).iconTheme.color!,
              titleButton: 'join',
            );
          } else if (state.status == DeleteJoinLeaveEventStatus.loading) {
            return const OurCircularProgressIndicator();
          } else if (state.status == DeleteJoinLeaveEventStatus.success) {
            return const OurCircularProgressIndicator();
          } else {
            return const CustomText(text: "An error occurred");
          }
        },
      ),
    );
  }
}
