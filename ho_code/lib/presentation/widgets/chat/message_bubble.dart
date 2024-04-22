import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final String photo;
  final bool isMe;
  final String hour;
  final double bottomPadding;
  final bool isForTablet;
  final String dateHour;

  const MessageBubble(
      {required this.sender,
      required this.text,
      required this.photo,
      required this.isMe,
      required this.hour,
      super.key,
      this.bottomPadding = 3.75,
      this.isForTablet = false,
      required this.dateHour});

  List<Widget> invertWidgetsIfNotMe(BuildContext context) {
    List<Widget> myList = [
      Expanded(
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            CustomText(
              text: sender,
              fontWeight: FontWeight.bold,
              size: 12.r,
            ),
            SizedBox(height: 3.0.h),
            Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: isMe ? Radius.circular(20.r) : Radius.zero,
                topRight: isMe ? Radius.zero : Radius.circular(20.r),
                bottomLeft: Radius.circular(20.0.r),
                bottomRight: Radius.circular(20.0.r),
              ),
              elevation: 5.0,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0.h,
                  horizontal: 20.0.w,
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      size: 14.r,
                      text: text,
                    ),
                    SizedBox(
                      height: 5.0.h,
                    ),
                    CustomText(
                      text: hour,
                      size: 10.r,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: 10.0.w,
      ),
      photo == ""
          ? Constants.noProfileImageInChat
          : CircleAvatar(
              backgroundImage: ImageManager.getImageProvider(photo),
              radius: Constants.avatarDimensionInChat,
            ),
    ];
    if (isMe) {
      return myList;
    } else {
      return myList.reversed.map((e) => e).toList();
    }
  }

  List<Widget> invertWidgetsIfNotMeTablet(BuildContext context) {
    List<Widget> myList = [
      Expanded(
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            CustomText(
              text: sender,
              fontWeight: FontWeight.bold,
              size: PopupTabletConstants.resize(14),
            ),
            SizedBox(height: PopupTabletConstants.resize(12)),
            Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: isMe
                    ? Radius.circular(PopupTabletConstants.resize(20))
                    : Radius.zero,
                topRight: isMe
                    ? Radius.zero
                    : Radius.circular(PopupTabletConstants.resize(20)),
                bottomLeft: Radius.circular(20.0.r),
                bottomRight: Radius.circular(20.0.r),
              ),
              elevation: 5.0,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: PopupTabletConstants.resize(10),
                  horizontal: PopupTabletConstants.resize(20),
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      size: PopupTabletConstants.resize(16),
                      text: text,
                    ),
                    SizedBox(
                      height: PopupTabletConstants.resize(12),
                    ),
                    CustomText(
                      text: hour,
                      size: PopupTabletConstants.resize(12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        width: PopupTabletConstants.resize(12),
      ),
      photo == ""
          ? PopupTabletConstants.noProfileImageInChat()
          : CircleAvatar(
              backgroundImage: ImageManager.getImageProvider(photo),
              radius: PopupTabletConstants.avatarDimensionInChat(),
            ),
    ];
    if (isMe) {
      return myList;
    } else {
      return myList.reversed.map((e) => e).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> senderInfo = [];
    List<Widget> senderTabletInfo = [];

    if (!isForTablet) {
      senderInfo = invertWidgetsIfNotMe(context);
      return Padding(
        padding: EdgeInsets.only(top: 15.0.h, bottom: bottomPadding.h),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: senderInfo,
        ),
      );
    }
    senderTabletInfo = invertWidgetsIfNotMeTablet(context);
    return Padding(
      padding: EdgeInsets.only(
          top: PopupTabletConstants.resize(15),
          bottom: PopupTabletConstants.resize(bottomPadding)),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: senderTabletInfo,
      ),
    );
  }
}
