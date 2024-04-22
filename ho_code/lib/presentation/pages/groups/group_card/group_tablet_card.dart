import 'package:flutter/material.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class GroupTabletCard extends StatelessWidget {
  final Group groupData;

  const GroupTabletCard({required this.groupData, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TabletConstants.shadowBoxDecoration(context),
      child: GroupTabletCardContent(groupData: groupData),
    );
  }
}

class GroupTabletCardContent extends StatelessWidget {
  final Group groupData;

  const GroupTabletCardContent({Key? key, required this.groupData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: TabletConstants.insideCardPadding(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TabletConstants.resizeR(20)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              groupData.photo == ""
                  ? TabletConstants.noImageInGroupCard()
                  : CircleAvatar(
                      backgroundImage:
                          ImageManager.getImageProvider(groupData.photo!),
                      radius: TabletConstants.avatarDimensionInCard(),
                    ),
              Icon(
                groupData.isPrivate ? AppIcons.private : AppIcons.public,
                size: TabletConstants.iconDimension(),
              )
            ],
          ),
          SizedBox(height: TabletConstants.spaceBtwAvatarNName()),
          CustomText(
            text: groupData.name,
            fontFamily: 'Raleway',
            size: TabletConstants.groupNameTextDimension(),
            fontWeight: Fonts.bold,
          ),
          SizedBox(height: TabletConstants.spaceBtwNameNDescription()),
          CustomText(
            text: groupData.caption,
            fontFamily: "Inter",
            size: TabletConstants.groupDescriptionTextDimension(),
          ),
          SizedBox(height: TabletConstants.spaceBtwDescriptionNMembers()),
          CustomText(
            text: "${groupData.numParticipants} Members",
            fontFamily: "Inter",
            size: TabletConstants.groupMembersTextDimension(),
          ),
        ],
      ),
    );
  }
}
