import 'package:flutter/material.dart';
import 'package:hang_out_app/presentation/pages/groups/group_card/group_card_content.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/data/models/group.dart';

class GroupCard extends StatelessWidget {
  final Group groupData;

  const GroupCard({required this.groupData, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constants.shadowBoxDecoration(context),
      child: GroupCardContent(groupData: groupData),
    );
  }
}
