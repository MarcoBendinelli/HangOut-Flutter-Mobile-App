import 'package:flutter/material.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/popups/chat_tablet_popup.dart';

class EventTabletCard extends StatelessWidget {
  final Event _eventData;

  const EventTabletCard(this._eventData, {super.key});

  @override
  Widget build(BuildContext context) {
    //image==true => 330 pixel card
    return GestureDetector(
      key: const Key("open_event_chat_button"),
      child: Container(
        height: _eventData.photo == ""
            ? TabletConstants.resizeH(400)
            : TabletConstants.resizeH(550),
        // width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TabletConstants.resizeR(20)),
          boxShadow: [
            TabletConstants.boxShadow(context),
          ],
          // color: AppColors.greenColor,
        ),
        child: Column(
          children: [
            Container(
              height: TabletConstants.resizeH(200),
              padding: TabletConstants.insideCardPadding(),
              // width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(TabletConstants.resizeR(20))),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: _eventData.getDay(),
                        size: TabletConstants.resizeR(40),
                        fontFamily: "Inter",
                      ),
                      Icon(
                        _eventData.private ? AppIcons.private : AppIcons.public,
                        size: TabletConstants.iconDimension(),
                      ),
                    ],
                  ),
                  CustomText(
                    text: "${_eventData.getMonth()} ${_eventData.getYear()}",
                    fontFamily: "Inter",
                    size: TabletConstants.resizeR(12),
                    fontWeight: Fonts.bold,
                  ),
                  CustomText(
                    text: _eventData.getDayName(),
                    fontFamily: "Inter",
                    size: TabletConstants.resizeR(12),
                    fontWeight: Fonts.light,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      CustomText(
                        text: _eventData.getHour(),
                        fontFamily: "Inter",
                        size: TabletConstants.resizeR(16),
                        fontWeight: Fonts.bold,
                      ),
                    ],
                  )
                ],
              ),
            ),
            _eventData.photo == ""
                ? const SizedBox()
                : Container(
                    height: TabletConstants.resizeH(150),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      fit: BoxFit.cover,
                      image: ImageManager.getImageProvider(_eventData.photo!),
                    )),
                  ),
            Container(
              height: TabletConstants.resizeH(200),
              // width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(TabletConstants.resizeR(20))),
                color: CategoryColors.getColor(_eventData.category),
              ),
              padding: TabletConstants.insideCardPadding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: _eventData.name,
                    size: TabletConstants.resizeR(32),
                    fontFamily: "Raleway",
                    fontWeight: Fonts.bold,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    color: _eventData.category == "other"
                        ? AppColors.whiteColor
                        : AppColors.blackColor,
                  ),
                  CustomText(
                    text: "${_eventData.numParticipants} Participants",
                    size: TabletConstants.resizeR(12),
                    fontFamily: "Inter",
                    fontWeight: Fonts.regular,
                    color: _eventData.category == "other"
                        ? AppColors.whiteColor
                        : AppColors.blackColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(HeroDialogRoute(
            builder: (newContext) => ChatTabletPopup(
                  heroTag: 'Chat view Popup',
                  id: _eventData.id,
                  isForTheGroup: false,
                  chatName: _eventData.name,
                  eventCategory: _eventData.category,
                ))); // Navigator.push(
      },
    );
  }
}
