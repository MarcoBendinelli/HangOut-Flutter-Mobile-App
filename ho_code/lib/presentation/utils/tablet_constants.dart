import 'package:flutter/material.dart';
import 'colors.dart';

class TabletConstants {
  static late double height;
  static late double width;
  static late Orientation orientation;

  static void setDimensions(context) {
    double tempWidth = MediaQuery.of(context).size.width;
    double tempHeight = MediaQuery.of(context).size.height;
    //set the utils so that height/width is in portrait portrait (h>w) a set device startup orientation
    width = tempHeight > tempWidth ? tempWidth : tempHeight;
    height = tempHeight > tempWidth ? tempHeight : tempWidth;
    orientation = MediaQuery.of(context).orientation;
  }

  static void setOrientation(Orientation newOrientation) {
    orientation = newOrientation;
  }

  ///return wich dimension is the current height based on orientation
  static double _getHeight() {
    if (orientation == Orientation.portrait) {
      return height / 1374;
    } else {
      return width / 1024;
    }
  }

  ///return wich dimension is the current width based on orientation
  static double _getWidth() {
    if (orientation == Orientation.portrait) {
      return width / 1024;
    } else {
      return height / 1374;
    }
  }

  static double resizeH(double number) {
    return _getHeight() * number;
  }

  ///width fixed is always the smallest
  static double resizeR(double number) {
    return width / (1024 / number);
  }

  static double resizeW(double number) {
    return _getWidth() * number;
  }

  /// Padding used in the main pages
  static EdgeInsets pagePadding() {
    return EdgeInsets.only(
        top: resizeH(30), left: resizeW(50), right: resizeW(50));
  }

  static EdgeInsets tabletInsidePagePadding() {
    return EdgeInsets.only(
        top: resizeH(30), left: resizeW(25), right: resizeW(25));
  }

  /// Padding used inside the cards
  static EdgeInsets insideCardPadding() {
    return EdgeInsets.only(
        left: resizeW(25),
        right: resizeW(25),
        top: resizeH(25),
        bottom: resizeH(25));
  }

  static BoxDecoration shadowBoxDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(resizeR(20)),
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

  // static BoxDecoration shadowBoxDecoration() {
  //   return BoxDecoration(
  //     borderRadius: BorderRadius.circular(resizeR(20)),
  //     boxShadow: [boxShadow],
  //   );
  // }

  // static BoxShadow boxShadow =
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

  static double iconDimension() {
    return resizeR(34);
  }

  static double privateIconExploreCardDimension() {
    return resizeR(28);
  }

  static hangOutTextDimension() {
    return resizeR(26);
  }

  /// Login signup page
  static double formInputHeight() {
    return resizeH(50);
  }

  static double formInputWidth() {
    return resizeW(440);
  }

  static double heightBetweenInputForm() {
    return resizeH(20);
  }

  /// Pages
  static double spaceBtwElementsInListView() {
    return resizeR(40);
  }

  static double halfSpaceBtwElementsInListView() {
    return resizeR(20);
  }

  /// Distance card pages
  static double spaceBtwCards() {
    return resizeR(30);
  }

  /// Distance card pages in Groups page
  static double spaceBtwCardsGroupsPage() {
    return resizeR(80);
  }

  static double sideSquareInterest() {
    return resizeR(90);
  }

  static double iconCardInterest() {
    return resizeR(24);
  }

  static double textDimensionCategory() {
    return resizeR(14);
  }

  static double borderRadius() {
    return resizeR(30);
  }

  static OutlineInputBorder formBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius())),
    );
  }

  // Group name text dimension in Group Card
  static double groupNameTextDimension() {
    return resizeR(32);
  }

  // Description name text dimension in Group Card
  static double groupDescriptionTextDimension() {
    return resizeR(14);
  }

  // Members text dimension in Group Card
  static double groupMembersTextDimension() {
    return resizeR(14);
  }

  // Space between the Avatar and the Name in Group Card
  static double spaceBtwAvatarNName() {
    return resizeH(30);
  }

  // Space between the Name and the Description in Group Card
  static double spaceBtwNameNDescription() {
    return resizeH(40);
  }

  // Space between the Description and the Members in Group Card
  static double spaceBtwDescriptionNMembers() {
    return resizeH(100);
  }

  /// Dimension of the avatar inside the Group Card
  static double avatarDimensionInCard() {
    return resizeR(35);
  }

  static CircleAvatar noImageInGroupCard() {
    return CircleAvatar(
      backgroundColor: AppColors.whiteColor,
      backgroundImage: const AssetImage("assets/images/group_no_image.png"),
      radius: avatarDimensionInCard(),
    );
  }

  static double distanceBtwDoneNElement() {
    return resizeH(73);
  }

  static double distanceBtwDoneNElementProfileLandscape() {
    return resizeH(73);
  }

  static double spaceBtwTitleNTextField() {
    return resizeH(30);
  }

  /// Titles text dimension
  static double textDimensionGroupName() {
    return resizeR(20);
  }

  /// ****************** background paths  ************************
  //for chat
  static const String tabletBgChat = "assets/background/tablet/LIGHTMODE3.jpg";
  static const String tabletDarkBgChat =
      "assets/background/tablet/DARKMODE3.jpg";
  //for signup
  static const String tabletBgSignup =
      "assets/background/tablet/LIGHTMODE3.jpg";
  static const String tabletDarkBgSignup =
      "assets/background/tablet/DARKMODE3.jpg";
  //for login
  static const String tabletBgLogin = "assets/background/tablet/LIGHTMODE3.jpg";
  static const String tabletDarkBgLogin =
      "assets/background/tablet/DARKMODE3.jpg";
  //for main
  static const String tabletBgMain = "assets/background/tablet/LIGHTMODEWHITE3.jpg";
  static const String tabletDarkBgMain =
      "assets/background/tablet/DARKMODE3.jpg";
}

///added to avoid error between Marco and me, should be merged later on where possible
class PopupTabletConstants {
  static double smallestDimension = 1;
  static void setSmallestDimension(context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    smallestDimension = height > width ? width : height;
  }

  static double resize(double number) {
    return smallestDimension / (1024 / number);
  }

  /// Popup dimensions
  static double popupDimension() {
    return resize(750);
  }

  static double contentPopupPaddingValue() {
    return resize(30);
  }

  /// Inside Popup padding
  static EdgeInsets contentPopupPadding() {
    return EdgeInsets.all(contentPopupPaddingValue());
  }

  /// Inside Popup padding
  static double eventPopupImageHeight() {
    return popupDimension() / 2 - contentPopupPaddingValue() * 2;
  }

  /// Inside Popup padding
  static double eventPopupImagewidth() {
    return popupDimension() / 2 - contentPopupPaddingValue() * 2;
  }

  /// Name group row

  static double groupNameFieldWidth() {
    return (popupDimension() - contentPopupPaddingValue()) / 2;
  }

  static double groupCaptionFieldWidth() {
    return (popupDimension() - contentPopupPaddingValue());
  }

  static mapSearchPadding() {
    return EdgeInsets.symmetric(horizontal: resize(9));
  }

  static iconDimension() {
    return resize(34);
  }

  static double distanceBtwDoneNElement() {
    return resize(60);
  }

  static double spaceBtwElementsInListView() {
    return resize(20);
  }

  ///space between members
  static double spaceBtwElementsInListViewGroup() {
    return resize(20);
  }

  static double spaceBtwTitleNListView() {
    return resize(15);
  }

  static double sideSquareInterest() {
    return resize(90);
  }

  // Width of the Interest
  static double widthInterest() {
    return sideSquareInterest();
  }

  // Height of the Interest (same of the Width)
  static double heightInterest() {
    return sideSquareInterest();
  }

  static double textDimensionCategory() {
    return resize(17);
  }

  static double textDimensionCaptionName() {
    return resize(20);
  }

  static double borderRadius() {
    return resize(30);
  }

  static formBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius())),
    );
  }

  // static BoxDecoration shadowBoxDecoration(BuildContext context) {
  //   return BoxDecoration(
  //     borderRadius: BorderRadius.circular(resizeR(20)),
  //     boxShadow: [boxShadow(context)],
  //   );
  // }

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

  /// Dimension of the avatar inside the Group Popup
  static double avatarDimensionInPopup() {
    return resize(80);
  }

  /// Dimension of the avatar inside the Group Popup (group selector)
  static double avatarDimensionNewGroup() {
    return resize(40);
  }

  static CircleAvatar noImageInGroupPopup() {
    return CircleAvatar(
      backgroundColor: AppColors.whiteColor,
      backgroundImage: const AssetImage("assets/images/group_no_image.png"),
      radius: avatarDimensionInPopup(),
    );
  }

  /// Dimension of the avatar inside the Group Popup (memebers)
  static double avatarDimensionInCard() {
    return resize(35);
  }

  static CircleAvatar noProfileImageInCard() {
    return CircleAvatar(
      backgroundColor: AppColors.whiteColor,
      backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
      radius: avatarDimensionInCard(),
    );
  }

  /// Interests group row
  static double interestsListViewHeight() {
    return resize(120);
  }

  /// Dimension of the avatar inside the List View of the members
  static double avatarDimensionInMembers() {
    return resize(45);
  }

  /// Dimension of the avatar inside the Group Popup
  static double avatarDimensionInMembersGroup() {
    return resize(45);
  }

  static double membersListViewHeightGroups() {
    return resize(120);
  }

  /// Members group row
  static double membersListViewHeight() {
    return resize(120);
  }

  static double membersListViewWidthGroupsGeneral() {
    return popupDimension() - contentPopupPaddingValue() * 2;
  }

  static double membersListViewWidthGroupsAddModify() {
    return resize(590);
  }

  static double membersListViewWidth() {
    return popupDimension() / 2 - contentPopupPaddingValue() * 2;
  }

  static CircleAvatar noProfileImageInMembersGroup() {
    return CircleAvatar(
      backgroundColor: AppColors.whiteColor,
      backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
      radius: avatarDimensionInMembersGroup(),
    );
  }

  static CircleAvatar noProfileImageInMembers() {
    return CircleAvatar(
      backgroundColor: AppColors.whiteColor,
      backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
      radius: avatarDimensionInMembers(),
    );
  }

  /// Space between the top and the name field
  static double spaceBtwTopNName() {
    return resize(75);
  }

  /// Titles text dimension (Name of event or group in popups)
  static double textDimensionBigTitle() {
    return resize(40);
  }

  /// Descriptions/captions text dimension for descriptions
  static double textDimensionDescription() {
    return resize(15);
  }

  /// Titles text dimension
  static double textDimensionTitle() {
    return resize(20);
  }

  static double spaceBtwInterestsNMembers() {
    return resize(12);
  }

  static spaceBtwTitleNTextField() {
    return resize(5);
  }

  static double avatarDimensionInChat() {
    return resize(30);
  }

  static CircleAvatar noProfileImageInChat() {
    return CircleAvatar(
      backgroundColor: AppColors.whiteColor,
      backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
      radius: avatarDimensionInChat(),
    );
  }

  static double heightError() {
    return resize(250);
  }
}






// class TabletConstants {
//   static late double height;
//   static late double width;
//   static late Orientation orientation;

//   static void setDimensions(context) {
//     double tempWidth = MediaQuery.of(context).size.width;
//     double tempHeight = MediaQuery.of(context).size.height;
//     //set the utils so that height/width is in portrait portrait (h>w) a set device startup orientation
//     width = tempHeight > tempWidth ? tempWidth : tempHeight;
//     height = tempHeight > tempWidth ? tempHeight : tempWidth;
//     orientation = MediaQuery.of(context).orientation;
//   }

//   static void setOrientation(Orientation newOrientation) {
//     orientation = newOrientation;
//   }

//   /// Padding used in the main pages
//   static EdgeInsets pagePadding() {
//     return EdgeInsets.only(top: 30.0.h, left: 50.0.w, right: 50.0.w);
//   }

//   static EdgeInsets tabletInsidePagePadding() {
//     return EdgeInsets.only(top: 30.h, left: 25.0.w, right: 25.0.w);
//   }

//   /// Padding used inside the cards
//   static EdgeInsets insideCardPadding() {
//     return EdgeInsets.only(
//         left: 25.0.w, right: 25.0.w, top: 25.0.h, bottom: 25.0.h);
//   }

//   static BoxDecoration shadowBoxDecoration() {
//     return BoxDecoration(
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [boxShadow()],
//     );
//   }

//   static BoxShadow boxShadow() {
//     return BoxShadow(
//       color: Colors.grey.withOpacity(0.5),
//       spreadRadius: 0,
//       blurRadius: 2,
//       offset: const Offset(0, 3), // changes position of shadow
//     );
//   }

//   static double iconDimension() {
//     return 34.r;
//   }

//   static double privateIconExploreCardDimension() {
//     return 28.r;
//   }

//   static hangOutTextDimension() {
//     return 26.0.r;
//   }

//   /// Login signup page
//   static double formInputHeight() {
//     return 50.h;
//   }

//   static double formInputWidth() {
//     return 440.w;
//   }

//   static double heightBetweenInputForm() {
//     return 20.h;
//   }

//   /// Pages
//   static double spaceBtwElementsInListView() {
//     return 40.0;
//   }

//   /// Distance card pages
//   static double spaceBtwCards() {
//     return 30.0;
//   }

//   /// Distance card pages in Groups page
//   static double spaceBtwCardsGroupsPage() {
//     return 80.0;
//   }

//   static double sideSquareInterest() {
//     return 90.r;
//   }

//   /// Width of the Interest
//   static double widthInterest() {
//     return sideSquareInterest();
//   }

//   /// Height of the Interest (same of the Width)}
//   static double heightInterest() {
//     return sideSquareInterest();
//   }

//   static double iconCardInterest() {
//     return 24;
//   }

//   static double textDimensionCategory() {
//     return 14;
//   }

//   static double borderRadius() {
//     return 30.0;
//   }

//   static OutlineInputBorder formBorder() {
//     return OutlineInputBorder(
//       borderSide: const BorderSide(color: Colors.transparent),
//       borderRadius: BorderRadius.all(Radius.circular(borderRadius())),
//     );
//   }

//   // Group name text dimension in Group Card
//   static double groupNameTextDimension() {
//     return 32.0;
//   }

//   // Description name text dimension in Group Card
//   static double groupDescriptionTextDimension() {
//     return 14.0;
//   }

//   // Members text dimension in Group Card
//   static double groupMembersTextDimension() {
//     return 14.0;
//   }

//   // Space between the Avatar and the Name in Group Card
//   static double spaceBtwAvatarNName() {
//     return 30.h;
//   }

//   // Space between the Name and the Description in Group Card
//   static double spaceBtwNameNDescription() {
//     return 40.h;
//   }

//   // Space between the Description and the Members in Group Card
//   static double spaceBtwDescriptionNMembers() {
//     return 100.h;
//   }

//   /// Dimension of the avatar inside the Group Card
//   static double avatarDimensionInCard() {
//     return 35.r;
//   }

//   static CircleAvatar noImageInGroupCard() {
//     return CircleAvatar(
//       backgroundColor: AppColors.whiteColor,
//       backgroundImage: const AssetImage("assets/images/group_no_image.png"),
//       radius: avatarDimensionInCard(),
//     );
//   }
// }

// ///added to avoid error between Marco and me, should be merged later on where possible
// class PopupTabletConstants {
//   static double smallestDimension = 1;
//   static void setSmallestDimension(context) {
//     double width = MediaQuery.of(context).size.width;
//     double height = MediaQuery.of(context).size.height;
//     smallestDimension = height > width ? width : height;
//   }

//   static double resize(int number) {
//     return smallestDimension / (1024 / number);
//   }

//   /// Popup dimensions
//   static double popupDimension() {
//     return resize(750);
//   }

//   static double contentPopupPaddingValue() {
//     return resize(30);
//   }

//   /// Inside Popup padding
//   static EdgeInsets contentPopupPadding() {
//     return EdgeInsets.all(contentPopupPaddingValue());
//   }

//   /// Inside Popup padding
//   static double eventPopupImageHeight() {
//     return popupDimension() / 2 - contentPopupPaddingValue() - resize(30);
//   }

//   /// Inside Popup padding
//   static double eventPopupImagewidth() {
//     return popupDimension() / 2 - contentPopupPaddingValue();
//   }

//   /// Name group row

//   static double groupNameFieldWidth() {
//     return (popupDimension() - contentPopupPaddingValue()) / 2;
//   }

//   static double groupCaptionFieldWidth() {
//     return (popupDimension() - contentPopupPaddingValue());
//   }

//   static mapSearchPadding() {
//     return EdgeInsets.symmetric(horizontal: resize(9));
//   }

//   static iconDimension() {
//     return resize(34);
//   }

//   static privateIconExploreCardDimension() {
//     return resize(28);
//   }

//   static double distanceBtwDoneNElement() {
//     return resize(60);
//   }

//   static double spaceBtwElementsInListView() {
//     return resize(15);
//   }

//   static double spaceBtwElementsInListViewGroup() {
//     return resize(13);
//   }

//   static double spaceBtwTitleNListView() {
//     return resize(15);
//   }

//   static double sideSquareInterest() {
//     return resize(90);
//   }

//   // Width of the Interest
//   static double widthInterest() {
//     return sideSquareInterest();
//   }

//   // Height of the Interest (same of the Width)
//   static double heightInterest() {
//     return sideSquareInterest();
//   }

//   static double textDimensionCategory() {
//     return resize(17);
//   }

//   static double textDimensionCaptionName() {
//     return resize(20);
//   }

//   static double borderRadius() {
//     return resize(30);
//   }

//   static formBorder() {
//     return OutlineInputBorder(
//       borderSide: const BorderSide(color: Colors.transparent),
//       borderRadius: BorderRadius.all(Radius.circular(borderRadius())),
//     );
//   }

//   static BoxShadow boxShadow() {
//     return BoxShadow(
//       color: Colors.grey.withOpacity(0.5),
//       spreadRadius: 0,
//       blurRadius: 2,
//       offset: const Offset(0, 3), // changes position of shadow
//     );
//   }

//   /// Dimension of the avatar inside the Group Popup
//   static double avatarDimensionInPopup() {
//     return resize(80);
//   }

//   /// Dimension of the avatar inside the Group Popup (group selector)
//   static double avatarDimensionNewGroup() {
//     return resize(40);
//   }

//   static CircleAvatar noImageInGroupPopup() {
//     return CircleAvatar(
//       backgroundColor: AppColors.whiteColor,
//       backgroundImage: const AssetImage("assets/images/group_no_image.png"),
//       radius: avatarDimensionInPopup(),
//     );
//   }

//   /// Dimension of the avatar inside the Group Popup (memebers)
//   static double avatarDimensionInCard() {
//     return resize(35);
//   }

//   static CircleAvatar noProfileImageInCard() {
//     return CircleAvatar(
//       backgroundColor: AppColors.whiteColor,
//       backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
//       radius: avatarDimensionInCard(),
//     );
//   }

//   /// Interests group row
//   // Height of the Interests List View (inside a Side Box)
//   static double interestsListViewHeight() {
//     return resize(120);
//   }

//   static double membersListViewHeightGroups() {
//     return resize(101);
//   }

//   static double membersListViewWidthGroups() {
//     return resize(610);
//   }

//   /// Members group row
//   // Height and width of the Members List View (inside a Side Box)
//   static double membersListViewHeight() {
//     return resize(101);
//   }

//   static double membersListViewWidth() {
//     return popupDimension() / 2 - contentPopupPaddingValue() * 2;
//   }

//   static CircleAvatar noProfileImageInMembersGroup() {
//     return CircleAvatar(
//       backgroundColor: AppColors.whiteColor,
//       backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
//       radius: avatarDimensionInMembersGroup(),
//     );
//   }

//   static CircleAvatar noProfileImageInMembers() {
//     return CircleAvatar(
//       backgroundColor: AppColors.whiteColor,
//       backgroundImage: const AssetImage("assets/images/profile_no_image.png"),
//       radius: avatarDimensionInMembers(),
//     );
//   }

//   /// Dimension of the avatar inside the List View of the members
//   static double avatarDimensionInMembers() {
//     return resize(40);
//   }

//   /// Dimension of the avatar inside the Group Popup
//   static double avatarDimensionInMembersGroup() {
//     return resize(40);
//   }

//   /// Space between the top and the name field
//   static double spaceBtwTopNName() {
//     return resize(75);
//   }

//   /// Titles text dimension (Name of event or group in popups)
//   static double textDimensionBigTitle() {
//     return resize(40);
//   }

//   /// Descriptions/captions text dimension for descriptions
//   static double textDimensionDescription() {
//     return resize(15);
//   }

//   /// Titles text dimension
//   static double textDimensionTitle() {
//     return resize(20);
//   }

//   static double spaceBtwInterestsNMembers() {
//     return resize(12);
//   }

//   static spaceBtwTitleNTextField() {
//     return resize(5);
//   }
// }

