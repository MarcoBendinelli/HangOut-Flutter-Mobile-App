import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/data/models/other_user.dart';
import 'package:hang_out_app/presentation/utils/animations/custom_rect_tween.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/our_divider.dart';
import 'package:hang_out_app/presentation/widgets/popups/user_info/common_groups_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/user_info/interests_row.dart';

class UserInfo extends StatelessWidget {
  final String heroTag;
  final OtherUser user;

  const UserInfo({Key? key, required this.heroTag, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildUserInfo(user, context);
    }
    return _buildTabletUserInfo(user, context);
  }

  Widget _buildUserInfo(OtherUser user, BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: Constants.popupDimensionPadding,
          child: Hero(
            tag: heroTag,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: Material(
              color: Theme.of(context).cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Constants.borderRadius)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: Constants.contentPopupPadding,
                  child: SizedBox(
                    height: Constants.heightPopup,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TapFadeIcon(
                                      key: const Key("user-info-bacl-button"),
                                      iconColor:
                                          Theme.of(context).iconTheme.color!,
                                      onTap: () {
                                        _pop(context);
                                      },
                                      icon: AppIcons.arrowIosBackOutline,
                                      size: Constants.iconDimension),
                                  SizedBox(
                                    height: Constants.spaceBtwTopNName,
                                  ),
                                  CustomText(
                                    text: user.name,
                                    size: 24,
                                    fontWeight: Fonts.bold,
                                    fontFamily: 'Raleway',
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0.w),
                                  child: user.photo == ""
                                      ? Constants.noImageInGroupCard
                                      : CircleAvatar(
                                          backgroundImage:
                                              ImageManager.getImageProvider(
                                                  user.photo),
                                          radius:
                                              Constants.avatarDimensionInPopup,
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.0.h,
                        ),
                        CustomText(
                          text: user.description,
                          size: 14.h,
                          fontWeight: Fonts.regular,
                          fontFamily: "Inter",
                        ),
                        const OurDivider(),
                        user.interests.isEmpty
                            ? const SizedBox()
                            : InterestsRow(user: user),
                        SizedBox(
                          height: Constants.spaceBtwInterestsNMembers,
                        ),
                        const CommonGroupsRow(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  Widget _buildTabletUserInfo(OtherUser user, BuildContext context) {
    return SafeArea(
      child: Center(
        child: Hero(
          tag: heroTag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: Theme.of(context).cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.borderRadius)),
            child: SizedBox(
              width: PopupTabletConstants.popupDimension(),
              height: PopupTabletConstants.popupDimension(),
              child: Padding(
                padding: PopupTabletConstants.contentPopupPadding(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TapFadeIcon(
                                  key: const Key("user-info-bacl-button"),
                                  iconColor: Theme.of(context).iconTheme.color!,
                                  onTap: () {
                                    _pop(context);
                                  },
                                  icon: AppIcons.arrowIosBackOutline,
                                  size: PopupTabletConstants.iconDimension()),
                              SizedBox(
                                height: Constants.spaceBtwTopNName,
                              ),
                              CustomText(
                                text: user.name,
                                size: PopupTabletConstants
                                    .textDimensionBigTitle(),
                                fontWeight: Fonts.bold,
                                fontFamily: 'Raleway',
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: PopupTabletConstants.resize(15)),
                              child: user.photo == ""
                                  ? PopupTabletConstants.noImageInGroupPopup()
                                  : CircleAvatar(
                                      backgroundImage:
                                          ImageManager.getImageProvider(
                                              user.photo),
                                      radius: PopupTabletConstants
                                          .avatarDimensionInPopup(),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: PopupTabletConstants.resize(15),
                    ),
                    CustomText(
                      text: user.description,
                      size: PopupTabletConstants.textDimensionDescription(),
                      fontWeight: Fonts.regular,
                      fontFamily: "Inter",
                    ),
                    const OurDivider(),
                    user.interests.isEmpty
                        ? const SizedBox()
                        : InterestsRow(user: user),
                    SizedBox(
                      height: PopupTabletConstants.spaceBtwInterestsNMembers(),
                    ),
                    const CommonGroupsRow(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
