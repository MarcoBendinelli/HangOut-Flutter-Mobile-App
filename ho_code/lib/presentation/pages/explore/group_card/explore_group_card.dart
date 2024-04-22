import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';

class ExploreGroupCard extends StatelessWidget {
  final Group _group;

  const ExploreGroupCard({super.key, required Group group}) : _group = group;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(bottom: Constants.spaceBtwCards.h),
        padding: Constants.insideCardPadding,
        height: 175.h,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 2.r,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          //
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Icon(
                _group.isPrivate ? AppIcons.private : AppIcons.public,
                size: Constants.iconDimension,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: CustomText(
                text: "${_group.numParticipants} members",
                fontWeight: Fonts.regular,
                size: 10.r,
                fontFamily: "Inter",
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 170.w,
                child: CustomText(
                  text: _group.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  fontWeight: Fonts.bold,
                  size: 20.r,
                  fontFamily: "Raleway",
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                  height: 120.h,
                  width: 120.w,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _group.photo != ""
                            ? ImageManager.getImageProvider(_group.photo!)
                            : const AssetImage(
                                "assets/images/group_no_image.png")),
                    shape: const CircleBorder(),
                  )),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 30.w,
                height: 110.h,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _group.interests.length,
                  itemBuilder: (context, index) {
                    return _buildCardItem(context,index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (newContext) => BlocProvider.value(
              value: BlocProvider.of<ExploreBloc>(context),
              child: SingleGroupPopup(
                heroTag: 'grouPopup',
                groupId: _group.id,
                fromExplore: true,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardItem(BuildContext context, int index) {
    return Container(
      height: 30.h,
      margin: EdgeInsets.symmetric(vertical: 3.h),
      decoration: BoxDecoration(
        boxShadow: [
          Constants.boxShadow(context),
        ],
        //
        color: CategoryColors.getColor(_group.interests[index]),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Icon(
          CategoryIcons.mapper[_group.interests[index]],
          color: AppColors.whiteColor,
          size: Constants.iconCardInterest,
        ),
      ),
    );
  }
}
