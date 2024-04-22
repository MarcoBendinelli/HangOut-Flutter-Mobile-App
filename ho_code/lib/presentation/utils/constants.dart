import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';

import 'colors.dart';

class Constants {
  /// Padding used in the main pages
  static final pagePadding =
      EdgeInsets.only(top: 10.0.h, left: 20.0.w, right: 20.0.w);

  /// Padding used inside the cards
  static final insideCardPadding =
      EdgeInsets.only(left: 15.0.w, right: 15.0.w, top: 15.0.h, bottom: 15.0.h);

  /// Space between the cards in the main pages
  static const double spaceBtwCards = 15;

  /// Dimension of the avatar inside the Group Card and the App Bar of the Chat
  static final double avatarDimensionInCard = 20.r;

  /// Dimension of the avatar inside the List View of the members
  static final double avatarDimensionInMembers = 22.r;

  /// Dimension of the avatar inside the Group Popup
  static final double avatarDimensionInMembersGroup = 30.r;

  /// Dimension of the avatar inside the Group Popup
  static final double avatarDimensionInPopup = 60.r;

  /// Dimension of the avatar inside the chat's bubbles
  static final double avatarDimensionInChat = 15.r;

  /// Dimension of all the icons
  static final double iconDimension = 24.r;

  /// Height of the error in the Explore Page
  static final double heightError = 185.0.h;

  static final double heightPopup = 675.h;
  static final double heightEventPopup = 735.h;

  /// Push Notification headers
  static const String titleNotificationGroup = " added you"; // Mario added you
  static const String bodyNotificationGroup =
      "in the group:"; // in the group:Football with friends

  static const String titleNotificationEvent =
      " has invited you"; // Mario has invited you
  static const String bodyNotificationEvent =
      "in the event:"; // in the event:Football with friends

  static const String titleNotificationChat =
      " sent a new message"; // Mario sent a new message
  static const String bodyNotificationChatGroup =
      "in the group chat:"; // in the group chat:Football with friends
  static const String bodyNotificationChatEvent =
      "in the event chat:"; // in the event chat:Sushi Poke Pizza

  static const String titleNotificationPublicGroup =
      " published"; // Mario published
  static const String bodyNotificationPublicGroup =
      "the new group:"; // the new group:Pinco Pallino

  static const String titleNotificationPublicEvent =
      " published"; // Mario published
  static const String bodyNotificationPublicEvent =
      "the new event:"; // the new event:Calcettata

  /// ************************* Group popup - start *****************************

  // Space between the interests and the members
  static final double spaceBtwInterestsNMembers = 15.h;

  // Space between the top and the name field
  static final double spaceBtwTopNName = 75.h;

  /// ************************* Group popup - end *******************************

  /// ************************* Group card - start *****************************

  // Group name text dimension
  static final double groupNameTextDimension = 20.r;

  // Description name text dimension
  static final double groupDescriptionTextDimension = 12.r;

  // Members text dimension
  static final double groupMembersTextDimension = 10.r;

  // Space between the Avatar and the Name
  static final double spaceBtwAvatarNName = 20.h;

  // Space between the Name and the Description
  static final double spaceBtwNameNDescription = 10.h;

  // Space between the Description and the Members
  static final double spaceBtwDescriptionNMembers = 40.h;

  /// ************************* Group card - end *******************************

  /// ****************** New Group or Event popup - start **********************

  static const double borderRadius = 20.0;
  static const double padding = 15.0;
  static final popupDimensionPadding = EdgeInsets.only(
      left: padding.w, right: padding.w, top: padding.h, bottom: padding.h);
  static const double borderPopupPadding = 30.0;
  static final contentPopupPadding = EdgeInsets.only(
      top: borderPopupPadding.h,
      bottom: borderPopupPadding.h,
      left: borderPopupPadding.w,
      right: borderPopupPadding.w);
  static double spaceBtwElementsInListView = 10.w;

  static double spaceBtwElementsInListViewGroup = 13.w;

  // Dimension of the avatar image to choose and of the members
  static double avatarDimensionNewGroup = 30.r;

  // Space between the title and the text field
  static final double spaceBtwTitleNTextField = 5.0.h;

  // Space between the title and the categories / members
  static final double spaceBtwTitleNListView = 15.0.h;

  // Titles text dimension
  static final double textDimensionTitle = 14.r;

  /// Name group row
  // Width of the Group Name Text Field (inside a Side Box)
  static final double groupNameFieldWidth = 200.w;

  // Name Group text dimension
  static const double textDimensionGroupName = 24.0;

  // Max length Group Name
  static const int maxLengthGroupName = 20;

  // Max length Event Name
  static const int maxLengthEventName = 15;

  /// Caption group row
  // Width of the Group Caption Text Field (inside a Side Box)
  static final double groupCaptionFieldWidth = 260.w;

  // Caption Group text dimension
  static const double textDimensionCaptionName = 12.0;

  // Max length Group caption
  static const int maxLengthGroupCaption = 100;

  // Max length Event caption
  static const int maxLengthEventCaption = 100;

  /// Members group row
  // Height and width of the Members List View (inside a Side Box)
  static final double membersListViewHeight = 62.h;
  static final double membersListViewWidth = 270.w;

  static final double membersListViewHeightGroups = 80.h;
  static final double membersListViewWidthGroups = 202.w;

  /// Interests group row
  // Height of the Interests List View (inside a Side Box)
  static final double interestsListViewHeight = 80.h;

  static final double sideSquareInterest = 60.r;

  // Width of the Interest
  static final double widthInterest = sideSquareInterest;

  // Height of the Interest (same of the Width)
  static final double heightInterest = sideSquareInterest;

  // Category text dimension
  static final double textDimensionCategory = 10.r;

  /// Our Done button
  // Distance between the done button and the last element
  static final double distanceBtwDoneNElement = 60.0.h;

  /// ****************** New Group or Event popup - end ************************

  static const String impossibleString = "?^*/+-..;.-;#```";

  static BoxDecoration shadowBoxDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [boxShadow(context)],
    );
  }

  static BoxShadow boxShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const BoxShadow(
            color: AppColors.almostBlackColor,
            spreadRadius: 0,
            blurRadius: 2,
            offset: Offset(0, 3), // changes position of shadow
          )
        : BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 3), // changes position of shadow
          );
  }

  // static final BoxDecoration shadowBoxDecoration = BoxDecoration(
  //   borderRadius: BorderRadius.circular(20),
  //   boxShadow: [boxShadow],
  // );

  // static final BoxShadow boxShadow =
  //     SchedulerBinding.instance.platformDispatcher.platformBrightness ==
  //             Brightness.dark
  //         ? const BoxShadow(
  //             color: AppColors.almostBlackColor,
  //             spreadRadius: 0,
  //             blurRadius: 2,
  //             offset: Offset(0, 3), // changes position of shadow
  //           )
  //         : BoxShadow(
  //             color: Colors.grey.withOpacity(0.5),
  //             spreadRadius: 0,
  //             blurRadius: 2,
  //             offset: const Offset(0, 3), // changes position of shadow
  //           );

  static final double iconCardInterest = 20.r;

  static const formBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.all(Radius.circular(Constants.borderRadius)),
  );

  static const errorFormBorder = OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.error),
    borderRadius: BorderRadius.all(Radius.circular(Constants.borderRadius)),
  );

  static CircleAvatar noImageInGroupCard = CircleAvatar(
    backgroundColor: AppColors.whiteColor,
    backgroundImage: const AssetImage("assets/images/group_no_image.png"),
    radius: avatarDimensionInCard,
  );

  static CircleAvatar noImageInGroupPopup = CircleAvatar(
    backgroundColor: AppColors.whiteColor,
    backgroundImage: const AssetImage("assets/images/group_no_image.png"),
    radius: avatarDimensionInPopup,
  );

  static CircleAvatar noProfileImageInChat = CircleAvatar(
    backgroundColor: AppColors.whiteColor,
    backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
    radius: avatarDimensionInChat,
  );

  static CircleAvatar noProfileImageInCard = CircleAvatar(
    backgroundColor: AppColors.whiteColor,
    backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
    radius: avatarDimensionInCard,
  );

  static CircleAvatar noProfileImageInMembers = CircleAvatar(
    backgroundColor: AppColors.whiteColor,
    backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
    radius: avatarDimensionInMembers,
  );

  static CircleAvatar noProfileImageInMembersGroup = CircleAvatar(
    backgroundColor: AppColors.whiteColor,
    backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
    radius: avatarDimensionInMembersGroup,
  );

  static final double formInputHeight = 36.h;
  static final double formInputWidth = 270.w;

  /// ****************** Static texts - start ************************
  static const String groupCaptionHint = "Write the group caption here";
  static const String eventCaptionHint = "Write the event caption here";

  /// ****************** Static map - start ************************
  // static const double mapSearchPadding = 16
  static final double mapSearchspaceBetween = 10.w;
  static final double mapSearchTopDistance = 56.h;
  static final EdgeInsets mapSearchPadding =
      EdgeInsets.symmetric(horizontal: 9.w);
  static const double mapPinDimension = 90;
  static const double mapPinIpadDimension = 8;
  static const double mapInitialZoom = 16;
  static const MarkerIcon markerIcon = MarkerIcon(
    icon: Icon(
      AppIcons.pin,
      size: Constants.mapPinDimension,
      color: AppColors.error,
    ),
  ); //N.B not scalable with .h but must be fixed

  /// ****************** Scroll blur  ************************
  static const blurLinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black,
      Colors.transparent,
    ],
    stops: [
      0.0,
      0.03,
    ], // 10% purple, 80% transparent, 10% purple
  );

  /// ****************** Calendar blur  ************************
  static final double calendarDefaultNumberDimension = 12.r;
  static final double calendarTodayNumberDimension = 14.r;

  /// ****************** background paths  ************************
  //for chat
  static const String phoneBgChat = "assets/background/phone/LIGHTMODE3.jpg";
  static const String phoneDarkBgChat = "assets/background/phone/DARKMODE3.jpg";
  static const String iPhoneBgChat = "assets/background/phone/iPhone_LIGHTMODE3.jpg";
  static const String iPhoneDarkBgChat = "assets/background/phone/iPhone_DARKMODE3.jpg";
  //for signup
  static const String phoneBgSignUp = "assets/background/phone/LIGHTMODE3.jpg";
  static const String phoneDarkBgSignUp =
      "assets/background/phone/DARKMODE3.jpg";
  //for login
  static const String phoneBgLogin = "assets/background/phone/LIGHTMODE3.jpg";
  static const String phoneDarkBgLogin =
      "assets/background/phone/DARKMODE3.jpg";
  //for main
  static const String phoneBgMain =
      "assets/background/phone/LIGHTMODEWHITE3.jpg";
  static const String phoneDarkBgMain = "assets/background/phone/DARKMODE3.jpg";
}
