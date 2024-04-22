import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/specific_group_event/specific_group_event_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';

class TitleAppBar extends StatelessWidget {
  final String iD;
  final bool isForTheGroup;

  const TitleAppBar({Key? key, required this.iD, required this.isForTheGroup})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentUserId =
        context.select((UserBloc bloc) => bloc.state.user.id);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          SpecificGroupEventBloc bloc = SpecificGroupEventBloc(
              eventsRepository: context.read<MyEventsRepository>(),
              groupsRepository: context.read<MyGroupsRepository>());
          isForTheGroup
              ? bloc.add(LoadSpecificGroup(groupId: iD))
              : bloc.add(LoadSpecificEvent(eventId: iD));
          return bloc;
        }),
        BlocProvider(create: (context) {
          MembersBloc bloc = MembersBloc(
              eventsRepository: context.read<MyEventsRepository>(),
              groupsRepository: context.read<MyGroupsRepository>(),
              userRepository: context.read<UserRepository>());
          isForTheGroup
              ? bloc.add(
                  LoadMembersInGroup(groupId: iD, currentUserId: currentUserId))
              : bloc.add(LoadMembersInEvent(eventId: iD));
          return bloc;
        }),
      ],
      child: BlocBuilder<MembersBloc, MembersState>(
        builder: (contextMembersBloc, stateMembersBloc) {
          String members = "";
          if (stateMembersBloc is MembersLoaded) {
            members = stateMembersBloc.members
                .map((member) => member.name)
                .join(", ");
          }
          return BlocBuilder<SpecificGroupEventBloc, SpecificGroupEventState>(
            builder: (context, state) {
              if (state is SpecificGroupEventLoading) {
                return const Center(
                  child: OurCircularProgressIndicator(),
                );
              } else if (state is SpecificGroupEventLoaded) {
                if (getSize(context) == ScreenSize.normal) {
                  return _buildPhoneTopBar(state, members);
                }
                return _buildTabletTopBar(state, members, context);
              } else {
                return const Center(
                  child:
                      Text("An error occurred while loading the information"),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildPhoneTopBar(SpecificGroupEventLoaded state, String members) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Name of the group
              CustomText(
                text: isForTheGroup ? state.group!.name : state.event!.name,
                size: Constants.groupNameTextDimension,
                fontWeight: Fonts.bold,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(
                height: 5.h,
              ),

              /// Participants
              CustomText(
                text: members,
                fontFamily: "Inter",
                size: Constants.groupMembersTextDimension,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              // SizedBox(
              //   height: 10.h,
              // ),
            ],
          ),
        ),
        SizedBox(
          width: 30.w,
        ),
        isForTheGroup
            ? state.group!.photo == ""
                ? Constants.noImageInGroupCard
                : CircleAvatar(
                    backgroundImage:
                        ImageManager.getImageProvider(state.group!.photo!),
                    radius: Constants.avatarDimensionInCard,
                  )
            : state.event!.photo == ""
                ? CircleAvatar(
                    backgroundColor:
                        CategoryColors.getColor(state.event!.category),
                    radius: Constants.avatarDimensionInCard,
                  )
                : CircleAvatar(
                    backgroundImage:
                        ImageManager.getImageProvider(state.event!.photo!),
                    radius: Constants.avatarDimensionInCard,
                  )
      ],
    );
  }

  Widget _buildTabletTopBar(
      SpecificGroupEventLoaded state, String members, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Constants.borderRadius),
            topRight: Radius.circular(Constants.borderRadius)),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(PopupTabletConstants.borderRadius()),
            topRight: Radius.circular(PopupTabletConstants.borderRadius()),
            // color: AppColors.whiteColor,
          ),
        ),
        child: Padding(
          padding: PopupTabletConstants.contentPopupPadding(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name of the group
                    CustomText(
                      text:
                          isForTheGroup ? state.group!.name : state.event!.name,
                      size: TabletConstants.groupNameTextDimension(),
                      fontWeight: Fonts.bold,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: TabletConstants.resizeH(15),
                    ),

                    /// Participants
                    CustomText(
                      text: members,
                      fontFamily: "Inter",
                      size: TabletConstants.groupMembersTextDimension(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    // SizedBox(
                    //   height: 10.h,
                    // ),
                  ],
                ),
              ),
              isForTheGroup
                  ? state.group!.photo == ""
                      ? TabletConstants.noImageInGroupCard()
                      : CircleAvatar(
                          backgroundImage: ImageManager.getImageProvider(
                              state.group!.photo!),
                          radius: TabletConstants.avatarDimensionInCard(),
                        )
                  : state.event!.photo == ""
                      ? CircleAvatar(
                          backgroundColor:
                              CategoryColors.getColor(state.event!.category),
                          radius: TabletConstants.avatarDimensionInCard(),
                        )
                      : CircleAvatar(
                          backgroundImage: ImageManager.getImageProvider(
                              state.event!.photo!),
                          radius: TabletConstants.avatarDimensionInCard(),
                        )
            ],
          ),
        ),
      ),
    );
  }
}
