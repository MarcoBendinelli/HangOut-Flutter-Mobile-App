import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/widgets/chat/chat_view.dart';
import 'event_card_bottom.dart';
import 'event_card_top.dart';

class EventCard extends StatelessWidget {
  final Event _eventData;

  const EventCard(this._eventData, {super.key});

  @override
  Widget build(BuildContext context) {
    //image==true => 330 pixel card
    return GestureDetector(
      key: const Key("open_event_chat_button"),
      child: Container(
        height: _eventData.photo == "" ? 240.h : 330.h,
        // width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            Constants.boxShadow(context),
          ],
          // color: AppColors.greenColor,
        ),
        child: Column(
          children: [
            EventCardTop(_eventData),
            _eventData.photo == ""
                ? const SizedBox()
                : Container(
                    height: 90.h,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      fit: BoxFit.cover,
                      image: ImageManager.getImageProvider(_eventData.photo!),
                    )),
                  ),
            EventCardBottom(_eventData),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute<bool>(
                builder: (_) => ChatView(
                      id: _eventData.id,
                      isForTheGroup: false,
                      chatName: _eventData.name,
                      eventCategory: _eventData.category,
                    ))); // Navigator.push(
      },
    );
  }
}
