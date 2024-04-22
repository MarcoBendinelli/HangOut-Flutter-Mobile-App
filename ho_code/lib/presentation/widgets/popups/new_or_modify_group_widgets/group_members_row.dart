import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/animations/from_bottom_page_route.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/members.dart';
import 'package:hang_out_app/presentation/widgets/popups/add_members_popup.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';

class GroupMembersRow extends StatefulWidget {
  final int numberOfMembers;

  const GroupMembersRow({Key? key, this.numberOfMembers = 1}) : super(key: key);

  @override
  State<GroupMembersRow> createState() => _GroupMembersRowState();
}

class _GroupMembersRowState extends State<GroupMembersRow> {
  int numberOfMembers = 0;

  @override
  void initState() {
    numberOfMembers = widget.numberOfMembers;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildRow(context);
    }
    return _buildTabletRow(context);
  }

  Widget _buildRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Members(
          nParticipants: numberOfMembers,
          isForTheGroup: true,
          text: 'Members',
          buttonWidget: GestureDetector(
            key: const Key("add-member-button"),
            onTap: () {
              _onTap(context);
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: CircleAvatar(
                radius: Constants.avatarDimensionInMembersGroup,
                backgroundColor: AppColors.grayColor,
                child: Icon(
                  AppIcons.plusCircleOutline,
                  size: Constants.iconDimension,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Members(
          nParticipants: numberOfMembers,
          isForTheGroup: true,
          text: 'Members',
          buttonWidget: GestureDetector(
            key: const Key("add-member-button"),
            onTap: () {
              _onTap(context);
            },
            child: CircleAvatar(
              radius: PopupTabletConstants.avatarDimensionInMembersGroup(),
              backgroundColor: AppColors.grayColor,
              child: Icon(
                AppIcons.plusCircleOutline,
                size: PopupTabletConstants.iconDimension(),
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onTap(BuildContext context) {
    Navigator.of(context)
        .push(FromBottomPageRoute(
            builder: (newContext) => BlocProvider.value(
                  value: BlocProvider.of<MembersBloc>(context),
                  child: AddMembers(
                    heroTag: 'tagNewMembers',
                    addMembersCallback: (numberOfSelectedUsers) {
                      setState(() {
                        numberOfMembers = numberOfSelectedUsers;
                      });
                    },
                  ),
                )))
        .then((value) => FocusManager.instance.primaryFocus?.unfocus());
  }
}
