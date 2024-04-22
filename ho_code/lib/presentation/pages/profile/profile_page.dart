import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/required_fields/required_fields_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/user/modify_user_cubit.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/presentation/pages/profile/notifications_user_col.dart';
import 'package:hang_out_app/presentation/pages/profile/theme_selector_row.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/mandatory_note.dart';
import 'package:hang_out_app/presentation/widgets/our_divider.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_photo_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/multi_category_input_row.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nickName = "";
  String bio = "";
  List<String> interests = [];
  XFile? photo;
  late bool notificationsPush;
  late bool notificationsGroupChat;
  late bool notificationsEventChat;
  late bool notificationsJoinGroup;
  late bool notificationsInviteEvent;
  late bool notificationsPublicEvent;
  late bool notificationsPublicGroup;

  @override
  Widget build(BuildContext context) {
    final UserData currentUser =
        context.select((UserBloc bloc) => bloc.state.user);

    notificationsPush = currentUser.notificationsPush;
    notificationsGroupChat = currentUser.notificationsGroupChat;
    notificationsEventChat = currentUser.notificationsEventChat;
    notificationsJoinGroup = currentUser.notificationsJoinGroup;
    notificationsInviteEvent = currentUser.notificationsInviteEvent;
    notificationsPublicEvent = currentUser.notificationsPublicEvent;
    notificationsPublicGroup = currentUser.notificationsPublicGroup;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: Constants.pagePadding,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<RequiredFieldsCubit>(
                  create: (context) => RequiredFieldsCubit(
                    isForTheEvent: false,
                  ),
                )
              ],
              child: Builder(builder: (context) {
                BlocProvider.of<RequiredFieldsCubit>(context)
                    .updateName(inputName: currentUser.name);
                BlocProvider.of<RequiredFieldsCubit>(context)
                    .updateCaption(inputCaption: currentUser.description);
                BlocProvider.of<RequiredFieldsCubit>(context)
                    .updateInterests(inputInterests: ["food"]);
                return Column(
                  children: [
                    Center(
                      child: CustomText(
                        text: "My Profile",
                        size: 20.r,
                        fontFamily: "Inter",
                        fontWeight: Fonts.bold,
                      ),
                    ),
                    SizedBox(
                      height: Constants.spaceBtwCards.h,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextPhotoRow(
                              inputName: "Nickname",
                              oldName: currentUser.name,
                              oldPhoto: currentUser.photo,
                              setNameCallback: (insertedGroupName) {
                                nickName = insertedGroupName;
                                BlocProvider.of<RequiredFieldsCubit>(context)
                                    .updateName(inputName: nickName);
                              },
                              setImagePickedCallback: (choseImage) {
                                photo = choseImage;
                              },
                              required: true,
                              borderRadius: 60,
                            ),
                            const OurDivider(),
                            TextInputRow(
                              inputName: "Bio",
                              oldText: currentUser.description,
                              setTextCallback: (insertedGroupCaption) {
                                bio = insertedGroupCaption;
                                BlocProvider.of<RequiredFieldsCubit>(context)
                                    .updateCaption(inputCaption: bio);
                              },
                              required: true,
                            ),
                            const OurDivider(),
                            TextInputRow(
                              inputName: "E-mail",
                              oldText: currentUser.email,
                              setTextCallback: (insertedGroupCaption) {},
                              required: true,
                              enabled: false,
                            ),
                            SizedBox(
                              height: 15.0.h,
                            ),
                            const MandatoryNote(),
                            const OurDivider(),
                            MultiCategoryInputRow(
                              inputName: "My interests",
                              oldGroupInterests: currentUser.interests,
                              groupInterestsCallback: (selectedInterests) {
                                interests = selectedInterests;
                              },
                            ),
                            const OurDivider(),
                            NotificationsUserCol(
                              notificationsPush: currentUser.notificationsPush,
                              notificationsGroupChat:
                                  currentUser.notificationsGroupChat,
                              notificationsEventChat:
                                  currentUser.notificationsEventChat,
                              notificationsJoinGroup:
                                  currentUser.notificationsJoinGroup,
                              notificationsInviteEvent:
                                  currentUser.notificationsInviteEvent,
                              notificationsPublicEvent:
                                  currentUser.notificationsPublicEvent,
                              notificationsPublicGroup:
                                  currentUser.notificationsPublicGroup,
                              callbackEventChat: (bool isEnabled) {
                                notificationsEventChat = isEnabled;
                              },
                              callbackGroupChat: (bool isEnabled) {
                                notificationsGroupChat = isEnabled;
                              },
                              callbackInviteEvent: (bool isEnabled) {
                                notificationsInviteEvent = isEnabled;
                              },
                              callbackJoinGroup: (bool isEnabled) {
                                notificationsJoinGroup = isEnabled;
                              },
                              callbackPublicEvent: (bool isEnabled) {
                                notificationsPublicEvent = isEnabled;
                              },
                              callbackPublicGroup: (bool isEnabled) {
                                notificationsPublicGroup = isEnabled;
                              },
                              callbackPush: (bool isEnabled) {
                                notificationsPush = isEnabled;
                              },
                            ),
                            const OurDivider(),
                            const ThemeSelector(),
                            const OurDivider(),
                            GestureDetector(
                              onTap: () {
                                if (mounted) {
                                  BlocProvider.of<UserBloc>(context)
                                      .setNotificationsServiceOnNotInitialized();
                                }
                                context
                                    .read<AppBloc>()
                                    .add(const AppLogoutRequested());
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: "Logout",
                                    fontFamily: "Raleway",
                                    fontWeight: Fonts.bold,
                                    size: 14.h,
                                  ),
                                  Icon(
                                    AppIcons.logOutOutline,
                                    size: Constants.iconDimension,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 27.h,
                            ),
                            GestureDetector(
                              onTap: () async {
                                //if user clicks outside dialog false is defaulted
                                bool accepted = await _showMyDialog() ?? false;
                                if (accepted) {
                                  if (mounted) {
                                    BlocProvider.of<UserBloc>(context)
                                        .setNotificationsServiceOnNotInitialized();
                                  }
                                  _deleteAccount();
                                }
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: "Delete account",
                                    fontFamily: "Raleway",
                                    fontWeight: Fonts.bold,
                                    size: 14.h,
                                  ),
                                  Icon(
                                    AppIcons.trashOutline,
                                    size: Constants.iconDimension,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: Constants.distanceBtwDoneNElement,
                            ),
                            BlocConsumer<ModifyUserCubit, ModifyUserState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                if (state.status == ModifyUserStatus.initial ||
                                    state.status == ModifyUserStatus.success) {
                                  return Center(
                                    child: BlocBuilder<RequiredFieldsCubit,
                                        RequiredFieldsState>(
                                      builder: (context, state) {
                                        if (state.status ==
                                            RequiredFieldsStatus.completed) {
                                          return TapFadeText(
                                            key: const Key("activeSave"),
                                            onTap: () async {
                                              await BlocProvider.of<
                                                      ModifyUserCubit>(context)
                                                  .modifyUser(
                                                      userId: currentUser.id,
                                                      nickname:
                                                          nickName ==
                                                                  ""
                                                              ? currentUser.name
                                                              : nickName,
                                                      isNicknameModified:
                                                          nickName ==
                                                                  ""
                                                              ? false
                                                              : true,
                                                      bio: bio ==
                                                              ""
                                                          ? currentUser
                                                              .description
                                                          : bio,
                                                      email: currentUser.email,
                                                      interests: interests,
                                                      newProfileImage: photo,
                                                      urlProfileImage:
                                                          currentUser.photo,
                                                      notificationsPush:
                                                          notificationsPush,
                                                      notificationsEventChat:
                                                          notificationsEventChat,
                                                      notificationsGroupChat:
                                                          notificationsGroupChat,
                                                      notificationsInviteEvent:
                                                          notificationsInviteEvent,
                                                      notificationsJoinGroup:
                                                          notificationsJoinGroup,
                                                      notificationsPublicEvent:
                                                          notificationsPublicEvent,
                                                      notificationsPublicGroup:
                                                          notificationsPublicGroup);
                                            },
                                            buttonColor: Theme.of(context)
                                                .iconTheme
                                                .color!,
                                            titleButton: 'save',
                                          );
                                        } else {
                                          return TapFadeText(
                                            key: const Key("disabledSave"),
                                            onTap: () {},
                                            buttonColor: Theme.of(context)
                                                .iconTheme
                                                .color!,
                                            titleButton: 'save',
                                            disabled: true,
                                          );
                                        }
                                      },
                                    ),
                                  );
                                } else if (state.status ==
                                    ModifyUserStatus.error) {
                                  return const Center(
                                    child: CustomText(text: "An error occured"),
                                  );
                                } else {
                                  return TapFadeText(
                                    onTap: () {},
                                    buttonColor:
                                        Theme.of(context).iconTheme.color!,
                                    titleButton: 'save',
                                    disabled: true,
                                  );
                                }
                              },
                            ),
                            SizedBox(
                              height: 25.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showMyDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const CustomText(text: 'Delete profile?'),
        content:
            const CustomText(text: 'All the user data will be lost forever'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const CustomText(text: 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const CustomText(text: 'Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    context.read<AppBloc>().add(const DeleteRequested());
  }
}
