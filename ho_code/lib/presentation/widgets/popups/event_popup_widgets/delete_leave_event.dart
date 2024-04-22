import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/events/delete_join_leave_event/delete_join_leave_event_cubit.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';

class DeleteLeaveEvent extends StatelessWidget {
  final UserData currentUser;
  final Event event;
  const DeleteLeaveEvent(
      {super.key, required this.currentUser, required this.event});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<DeleteJoinLeaveEventCubit, DeleteJoinLeaveEventState>(
        builder: (context, state) {
          if (state.status == DeleteJoinLeaveEventStatus.initial) {
            return TapFadeText(
              onTap: () async {
                currentUser.id == event.creatorId
                    ? await BlocProvider.of<DeleteJoinLeaveEventCubit>(context)
                        .deleteEvent(eventId: event.id)
                    : await BlocProvider.of<DeleteJoinLeaveEventCubit>(context)
                        .leaveEvent(user: currentUser, eventId: event.id);
              },
              buttonColor: Theme.of(context).iconTheme.color!,
              titleButton:
                  currentUser.id == event.creatorId ? 'delete' : 'leave',
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
