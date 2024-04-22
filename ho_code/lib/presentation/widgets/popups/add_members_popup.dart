import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/users/users_bloc.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/cache_images.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';

class AddMembers extends StatefulWidget {
  final String heroTag;
  final Function addMembersCallback;

  const AddMembers(
      {Key? key, required this.heroTag, required this.addMembersCallback})
      : super(key: key);

  @override
  State<AddMembers> createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  String insertedUserLetters = Constants.impossibleString;
  List<String> selectedIdUsers = [];
  bool firstBuild = false;

  @override
  void initState() {
    firstBuild = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId =
        context.select((UserBloc bloc) => bloc.state.user.id);
    if (firstBuild) {
      List<String> totalSelectedIdUsers = BlocProvider.of<MembersBloc>(context)
          .selectedUsers
          .map((e) => e.id)
          .toList();
      selectedIdUsers.addAll(totalSelectedIdUsers);
      firstBuild = false;
    }

    return BlocProvider(
      create: (context) =>
          UsersBloc(userRepository: context.read<UserRepository>())
            ..add(const LoadUsers()),
      child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: getSize(context) == ScreenSize.normal
              ? _buildRow(currentUserId)
              : _buildTabletRow(currentUserId)),
    );
  }

  _buildRow(String currentUserId) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: Constants.popupDimensionPadding,
          child: Material(
            color: Theme.of(context).cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.borderRadius)),
            child: Padding(
              padding: Constants.contentPopupPadding,
              child: SizedBox(
                height: 720.h,
                child: Column(
                  children: [
                    TapFadeIcon(
                        iconColor: Theme.of(context).iconTheme.color!,
                        onTap: () {
                          _pop();
                        },
                        icon: AppIcons.arrowIosDownOutline,
                        size: Constants.iconDimension),
                    SizedBox(height: 15.0.h),
                    TextField(
                      key: const Key("search-user-bar"),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 15.0.w, vertical: 10.0.h),
                        isDense: true,
                        hintText: "Enter the name of the new member",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Constants.borderRadius)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Constants.borderRadius)),
                        counterText: "",
                        labelStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      textAlign: TextAlign.start,
                      onChanged: (insertedLetters) {
                        setState(() {
                          insertedUserLetters = insertedLetters;
                          if (insertedUserLetters.isEmpty) {
                            insertedUserLetters = Constants.impossibleString;
                          }
                        });
                      },
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: Fonts.regular,
                        fontSize: Constants.textDimensionCaptionName,
                      ),
                    ),
                    SizedBox(
                      height: 15.0.h,
                    ),
                    SizedBox(
                      height: 470.h,
                      child: BlocBuilder<UsersBloc, UsersState>(
                        builder: (context, state) {
                          if (state is UsersLoaded) {
                            List<UserData> filteredUsers = state.users
                                .where((user) =>
                                    user.name.contains(insertedUserLetters))
                                .where((user) =>
                                    // !totalSelectedIdUsers
                                    //     .contains(user.id) &&
                                    user.id != currentUserId)
                                .toList();

                            if (filteredUsers.isEmpty) {
                              return Center(
                                child: CustomText(
                                  size: 12.r,
                                  text: "No user found",
                                ),
                              );
                            } else {
                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  return _buildUserItem(filteredUsers[index]);
                                },
                              );
                            }
                          } else {
                            return Center(
                              child: CustomText(
                                size: 12.r,
                                text: "No user found",
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: Constants.distanceBtwDoneNElement,
                    ),
                    TapFadeText(
                      key: const Key("done-add-button"),
                      onTap: () {
                        _tapDone(currentUserId);
                      },
                      buttonColor: Theme.of(context).iconTheme.color!,
                      titleButton: 'done',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pop() {
    Navigator.of(context).pop();
  }

  void _tapDone(String currentUserId) {
    BlocProvider.of<MembersBloc>(context).add(LoadSelectedUsers(
        idUsers: selectedIdUsers, currentUserId: currentUserId));
    widget.addMembersCallback(selectedIdUsers.length);
    BlocProvider.of<MembersBloc>(context).add(GoInInitState());
    Navigator.of(context).pop();
  }

  _buildTabletRow(String currentUserId) {
    return SafeArea(
      child: Center(
        child: Material(
          color: Theme.of(context).cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.borderRadius)),
          child: SizedBox(
            height: PopupTabletConstants.popupDimension(),
            width: PopupTabletConstants.popupDimension(),
            child: Padding(
              padding: PopupTabletConstants.contentPopupPadding(),
              child: SizedBox(
                height: PopupTabletConstants.popupDimension() -
                    PopupTabletConstants.contentPopupPaddingValue(),
                child: Column(
                  children: [
                    TapFadeIcon(
                        iconColor: Theme.of(context).iconTheme.color!,
                        onTap: () {
                          _pop();
                        },
                        icon: AppIcons.arrowIosDownOutline,
                        size: PopupTabletConstants.iconDimension()),
                    SizedBox(height: PopupTabletConstants.resize(15)),
                    TextField(
                      key: const Key("search-user-bar"),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: PopupTabletConstants.resize(15),
                            vertical: PopupTabletConstants.resize(10)),
                        isDense: true,
                        hintText: "Enter the name of the new member",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Constants.borderRadius)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Constants.borderRadius)),
                        counterText: "",
                        labelStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      textAlign: TextAlign.start,
                      onChanged: (insertedLetters) {
                        setState(() {
                          insertedUserLetters = insertedLetters;
                          if (insertedUserLetters.isEmpty) {
                            insertedUserLetters = Constants.impossibleString;
                          }
                        });
                      },
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: Fonts.regular,
                        fontSize:
                            PopupTabletConstants.textDimensionCaptionName(),
                      ),
                    ),
                    SizedBox(
                      height: PopupTabletConstants.resize(15),
                    ),
                    SizedBox(
                      height: PopupTabletConstants.resize(470),
                      child: BlocBuilder<UsersBloc, UsersState>(
                        builder: (context, state) {
                          if (state is UsersLoaded) {
                            List<UserData> filteredUsers = state.users
                                .where((user) =>
                                    user.name.contains(insertedUserLetters))
                                .where((user) =>
                                    // !totalSelectedIdUsers
                                    //     .contains(user.id) &&
                                    user.id != currentUserId)
                                .toList();

                            if (filteredUsers.isEmpty) {
                              return Center(
                                child: CustomText(
                                  size: PopupTabletConstants.resize(20),
                                  text: "No user found",
                                ),
                              );
                            } else {
                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  return _buildTabletUserItem(
                                      filteredUsers[index]);
                                },
                              );
                            }
                          } else {
                            return Center(
                              child: CustomText(
                                size: PopupTabletConstants.resize(20),
                                text: "No user found",
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: PopupTabletConstants.distanceBtwDoneNElement(),
                    ),
                    TapFadeText(
                      key: const Key("done-add-button"),
                      onTap: () {
                        _tapDone(currentUserId);
                      },
                      buttonColor: Theme.of(context).iconTheme.color!,
                      titleButton: 'done',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserItem(UserData user) {
    return Padding(
      padding: EdgeInsets.only(bottom: Constants.spaceBtwElementsInListView),
      child: Container(
        padding: Constants.insideCardPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          //border: Border.all(),
        ),
        child: Row(
          children: [
            user.photo == ""
                ? Constants.noProfileImageInCard
                : CircleAvatar(
                    backgroundImage: ImageManager.getImageProvider(user.photo),
                    radius: Constants.avatarDimensionInCard,
                  ),
            SizedBox(
              width: 15.0.w,
            ),
            SizedBox(
              width: 147.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: user.name,
                    fontWeight: FontWeight.bold,
                    size: 14,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  CustomText(
                    size: 12,
                    text: user.interests.isEmpty
                        ? "No interests"
                        : "Interests: ${user.interests.join(", ")}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 15.0.w,
            ),
            IconButton(
              key: const Key("add-user-selector"),
              padding: EdgeInsets.zero,
              iconSize: Constants.iconDimension,
              constraints: const BoxConstraints(),
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  if (selectedIdUsers.contains(user.id)) {
                    selectedIdUsers.remove(user.id);
                  } else {
                    selectedIdUsers.add(user.id);
                  }
                });
              },
              icon: selectedIdUsers.contains(user.id)
                  ? Icon(
                      AppIcons.radioButtonOn,
                      size: Constants.iconDimension,
                    )
                  : Icon(
                      AppIcons.radioButtonOffOutline,
                      size: Constants.iconDimension,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletUserItem(UserData user) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: PopupTabletConstants.spaceBtwElementsInListView()),
      child: Container(
        padding: PopupTabletConstants.contentPopupPadding(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          //border: Border.all(),
        ),
        child: Row(
          children: [
            user.photo == ""
                ? PopupTabletConstants.noProfileImageInCard()
                : CircleAvatar(
                    backgroundImage: ImageManager.getImageProvider(user.photo),
                    radius: PopupTabletConstants.avatarDimensionInCard(),
                  ),
            SizedBox(
              width: PopupTabletConstants.resize(15),
            ),
            SizedBox(
              width: PopupTabletConstants.resize(490),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: user.name,
                    fontWeight: FontWeight.bold,
                    size: PopupTabletConstants.resize(22),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  CustomText(
                    size: PopupTabletConstants.resize(18),
                    text: user.interests.isEmpty
                        ? "No interests"
                        : "Interests: ${user.interests.join(", ")}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: PopupTabletConstants.resize(15),
            ),
            IconButton(
              key: const Key("add-user-selector"),
              padding: EdgeInsets.zero,
              iconSize: PopupTabletConstants.iconDimension(),
              constraints: const BoxConstraints(),
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  if (selectedIdUsers.contains(user.id)) {
                    selectedIdUsers.remove(user.id);
                  } else {
                    selectedIdUsers.add(user.id);
                  }
                });
              },
              icon: selectedIdUsers.contains(user.id)
                  ? Icon(
                      AppIcons.radioButtonOn,
                      size: PopupTabletConstants.iconDimension(),
                    )
                  : Icon(
                      AppIcons.radioButtonOffOutline,
                      size: PopupTabletConstants.iconDimension(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
