import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/explore/explore_bloc.dart';
import 'package:hang_out_app/data/models/group.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';

class ExploreTabletGroupCard extends StatelessWidget {
  final Group _group;

  const ExploreTabletGroupCard({super.key, required Group group})
      : _group = group;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: TabletConstants.insideCardPadding(),
        height: TabletConstants.resizeH(215),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: TabletConstants.resizeR(2),
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
          //
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(TabletConstants.resizeR(20)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Icon(
                _group.isPrivate ? AppIcons.private : AppIcons.public,
                size: TabletConstants.privateIconExploreCardDimension(),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: CustomText(
                text: "${_group.numParticipants} members",
                fontWeight: Fonts.regular,
                size: TabletConstants.resizeR(12),
                fontFamily: "Inter",
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: TabletConstants.resizeW(170),
                child: CustomText(
                  text: _group.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  fontWeight: Fonts.bold,
                  size: TabletConstants.resizeR(24),
                  fontFamily: "Raleway",
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                  height: TabletConstants.resizeH(146),
                  width: TabletConstants.resizeW(146),
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
                width: TabletConstants.resizeW(34),
                height: TabletConstants.resizeH(146),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _group.interests.length,
                  itemBuilder: (context, index) {
                    return _buildCardItem(index,context);
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

  Widget _buildCardItem(int index,BuildContext context) {
    return Container(
      height: TabletConstants.resizeH(34),
      margin: EdgeInsets.symmetric(vertical: TabletConstants.resizeH(7.5)),
      decoration: BoxDecoration(
        boxShadow: [
          TabletConstants.boxShadow(context),
        ],
        //
        color: CategoryColors.getColor(_group.interests[index]),
        borderRadius: BorderRadius.circular(TabletConstants.resizeR(10)),
      ),
      child: Center(
        child: Icon(
          CategoryIcons.mapper[_group.interests[index]],
          color: AppColors.whiteColor,
          size: TabletConstants.iconCardInterest(),
        ),
      ),
    );
  }
}
