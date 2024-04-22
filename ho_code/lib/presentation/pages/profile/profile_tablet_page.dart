import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/app/app_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/notifications/notifications_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/business_logic/cubits/required_fields/required_fields_cubit.dart';
import 'package:hang_out_app/business_logic/cubits/user/modify_user_cubit.dart';
import 'package:hang_out_app/data/models/user_data.dart';
import 'package:hang_out_app/data/repositories/notifications_repository.dart';
import 'package:hang_out_app/presentation/pages/profile/notifications_user_col.dart';
import 'package:hang_out_app/presentation/pages/profile/theme_selector_row.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/bars/top_bar_tablet_pages.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_text.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/mandatory_note.dart';
import 'package:hang_out_app/presentation/widgets/our_divider.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_input_row.dart';
import 'package:hang_out_app/presentation/widgets/popups/common_inputs/text_photo_column_tablet.dart';
import 'package:hang_out_app/presentation/widgets/tablet_grid_categories/tablet_landscape_grid_categories.dart';
import 'package:hang_out_app/presentation/widgets/tablet_grid_categories/tablet_portrait_grid_categories.dart';
import 'package:image_picker/image_picker.dart';

class ProfileTabletPage extends StatefulWidget {
  const ProfileTabletPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabletPage> createState() => _ProfileTabletPageState();
}

class _ProfileTabletPageState extends State<ProfileTabletPage> {
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<RequiredFieldsCubit>(
          create: (context) => RequiredFieldsCubit(
            isForTheEvent: false,
          ),
        ),
        BlocProvider<NotificationsBloc>(
          create: (context) => NotificationsBloc(
              notificationsRepository: context.read<NotificationsRepository>())
            ..add(LoadNotifications(userId: currentUser.id)),
        ),
      ],
      child: OrientationBuilder(builder: (context, orientation) {
        if (MediaQuery.of(context).orientation == Orientation.portrait) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: SafeArea(
                child: Padding(
                  padding: TabletConstants.pagePadding(),
                  child: _buildProfileForPortrait(currentUser),
                ),
              ),
            ),
          );
        }
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: SafeArea(
              child: Padding(
                padding: TabletConstants.pagePadding(),
                child: _buildProfileForLandscape(currentUser),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<bool?> _showMyDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const CustomText(text: 'Delete profile?'),
        content: const Text('All the user data will be lost forever'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    context.read<AppBloc>().add(const DeleteRequested());
  }

  Widget _buildProfileForPortrait(UserData currentUser) {
    return Builder(builder: (context) {
      BlocProvider.of<RequiredFieldsCubit>(context)
          .updateName(inputName: currentUser.name);
      BlocProvider.of<RequiredFieldsCubit>(context)
          .updateCaption(inputCaption: currentUser.description);
      BlocProvider.of<RequiredFieldsCubit>(context)
          .updateInterests(inputInterests: ["food"]);
      return Column(
        children: [
          const TopBarTabletPages(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: TabletConstants.tabletInsidePagePadding(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: "My interests",
                      size: TabletConstants.textDimensionGroupName(),
                      fontFamily: "Raleway",
                      fontWeight: Fonts.bold,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: TabletConstants.spaceBtwTitleNTextField()),
                      child: TabletPortraitGridCategories(
                        callback: (selectedInterests) {
                          interests = selectedInterests;
                        },
                        interests: currentUser.interests,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: TabletConstants.resizeW(350),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextPhotoColumnTablet(
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
                                borderRadius: 100,
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
                                setTextCallback: (insertedGroupCaption) {
                                  bio = insertedGroupCaption;
                                },
                                required: true,
                                enabled: false,
                              ),
                              SizedBox(
                                height: TabletConstants.resizeH(15),
                              ),
                              const MandatoryNote(),
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
                                      size: TabletConstants
                                          .textDimensionGroupName(),
                                    ),
                                    Icon(
                                      AppIcons.logOutOutline,
                                      size: TabletConstants.iconDimension(),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: TabletConstants.resizeH(27),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  //if user clicks outside dialog false is defaulted
                                  bool accepted =
                                      await _showMyDialog() ?? false;
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
                                      size: TabletConstants
                                          .textDimensionGroupName(),
                                    ),
                                    Icon(
                                      AppIcons.trashOutline,
                                      size: TabletConstants.iconDimension(),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: TabletConstants.resizeW(50),
                        ),
                        Flexible(
                          child: Column(
                            children: [
                              NotificationsUserCol(
                                notificationsPush:
                                    currentUser.notificationsPush,
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
                              SizedBox(
                                height: TabletConstants.resizeH(15),
                              ),
                              const OurDivider(),
                              const ThemeSelector(),
                              SizedBox(
                                height:
                                    TabletConstants.distanceBtwDoneNElement(),
                              ),
                              BlocConsumer<ModifyUserCubit, ModifyUserState>(
                                listener: (context, state) {},
                                builder: (context, state) {
                                  if (state.status ==
                                          ModifyUserStatus.initial ||
                                      state.status ==
                                          ModifyUserStatus.success) {
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
                                                            ModifyUserCubit>(
                                                        context)
                                                    .modifyUser(
                                                        userId: currentUser.id,
                                                        nickname: nickName ==
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
                                                        email:
                                                            currentUser.email,
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
                                      child:
                                          CustomText(text: "An error occured"),
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
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProfileForLandscape(UserData currentUser) {
    return Builder(builder: (context) {
      BlocProvider.of<RequiredFieldsCubit>(context)
          .updateName(inputName: currentUser.name);
      BlocProvider.of<RequiredFieldsCubit>(context)
          .updateCaption(inputCaption: currentUser.description);
      BlocProvider.of<RequiredFieldsCubit>(context)
          .updateInterests(inputInterests: ["food"]);
      return Column(
        children: [
          const TopBarTabletPages(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: TabletConstants.tabletInsidePagePadding(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: TabletConstants.resizeW(350),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextPhotoColumnTablet(
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
                            borderRadius: 100,
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
                            setTextCallback: (insertedGroupCaption) {
                              bio = insertedGroupCaption;
                            },
                            required: true,
                            enabled: false,
                          ),
                          SizedBox(
                            height: TabletConstants.resizeH(15),
                          ),
                          const MandatoryNote(),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: "Logout",
                                  fontFamily: "Raleway",
                                  fontWeight: Fonts.bold,
                                  size:
                                      TabletConstants.textDimensionGroupName(),
                                ),
                                Icon(
                                  AppIcons.logOutOutline,
                                  size: TabletConstants.iconDimension(),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: TabletConstants.resizeH(27),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: "Delete account",
                                  fontFamily: "Raleway",
                                  fontWeight: Fonts.bold,
                                  size:
                                      TabletConstants.textDimensionGroupName(),
                                ),
                                Icon(
                                  AppIcons.trashOutline,
                                  size: TabletConstants.iconDimension(),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: TabletConstants.resizeW(40),
                    ),
                    Column(
                      children: [
                        CustomText(
                          text: "My interests",
                          size: TabletConstants.textDimensionGroupName(),
                          fontFamily: "Raleway",
                          fontWeight: Fonts.bold,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: TabletConstants.spaceBtwTitleNTextField()),
                          child: TabletLandscapeGridCategories(
                            callback: (selectedInterests) {
                              interests = selectedInterests;
                            },
                            interests: currentUser.interests,
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                          SizedBox(
                            height: TabletConstants.resizeH(15),
                          ),
                          const OurDivider(),
                          const ThemeSelector(),
                          SizedBox(
                            height: TabletConstants
                                .distanceBtwDoneNElementProfileLandscape(),
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
                                                    nickname: nickName == ""
                                                        ? currentUser.name
                                                        : nickName,
                                                    isNicknameModified:
                                                        nickName == ""
                                                            ? false
                                                            : true,
                                                    bio: bio == ""
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
                                return Center(
                                  child: TapFadeText(
                                    onTap: () {},
                                    buttonColor:
                                        Theme.of(context).iconTheme.color!,
                                    titleButton: 'save',
                                    disabled: true,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
