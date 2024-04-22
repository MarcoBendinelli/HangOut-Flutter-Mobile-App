import 'package:flutter/material.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class GroupCardContent extends StatelessWidget {
  final Group groupData;

  const GroupCardContent({Key? key, required this.groupData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Constants.insideCardPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              groupData.photo == ""
                  ? Constants.noImageInGroupCard
                  : CircleAvatar(
                      backgroundImage:
                          ImageManager.getImageProvider(groupData.photo!),
                      radius: Constants.avatarDimensionInCard,
                    ),
              Icon(
                groupData.isPrivate ? AppIcons.private : AppIcons.public,
                size: Constants.iconDimension,
              )
            ],
          ),
          SizedBox(height: Constants.spaceBtwAvatarNName),
          CustomText(
            text: groupData.name,
            fontFamily: 'Raleway',
            size: Constants.groupNameTextDimension,
            fontWeight: Fonts.bold,
          ),
          SizedBox(height: Constants.spaceBtwNameNDescription),
          CustomText(
            text: groupData.caption,
            fontFamily: "Inter",
            size: Constants.groupDescriptionTextDimension,
          ),
          SizedBox(height: Constants.spaceBtwDescriptionNMembers),
          CustomText(
            text: "${groupData.numParticipants} Members",
            fontFamily: "Inter",
            size: Constants.groupMembersTextDimension,
          ),
        ],
      ),
    );
  }
}
