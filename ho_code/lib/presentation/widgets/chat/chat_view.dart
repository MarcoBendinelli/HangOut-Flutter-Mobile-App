import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/widgets/chat/input_widget.dart';
import 'package:hang_out_app/presentation/widgets/chat/message_bubble_no_info.dart';
import 'package:hang_out_app/presentation/widgets/chat/title_app_bar.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/date_in_notifications_and_chat.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/buttons/tap_fade_icon.dart';
import 'package:hang_out_app/business_logic/blocs/chat/chat_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/presentation/utils/animations/hero_dialog_route.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';
import 'package:intl/intl.dart';
import 'message_bubble.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

class ChatView extends StatefulWidget {
  final String id;
  final bool isForTheGroup;
  final String chatName;
  final String? eventCategory;

  const ChatView(
      {super.key,
      required this.id,
      required this.isForTheGroup,
      required this.chatName,
      this.eventCategory});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool fixTheInputWidget = false;
  List<String> membersToNotify = [];

  @override
  Widget build(BuildContext context) {
    String currentUserNickname =
        context.select((UserBloc bloc) => bloc.state.user.name);
    String currentUserId =
        context.select((UserBloc bloc) => bloc.state.user.id);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            MembersBloc bloc = MembersBloc(
                eventsRepository: context.read<MyEventsRepository>(),
                groupsRepository: context.read<MyGroupsRepository>(),
                userRepository: context.read<UserRepository>());
            widget.isForTheGroup
                ? bloc.add(LoadMembersInGroup(
                    groupId: widget.id, currentUserId: currentUserId))
                : bloc.add(LoadMembersInEvent(eventId: widget.id));
            return bloc;
          },
        ),
        BlocProvider<ChatBloc>(create: (context) {
          ChatBloc bloc =
              ChatBloc(chatRepository: context.read<ChatRepository>());
          widget.isForTheGroup
              ? bloc.add(LoadGroupChat(groupId: widget.id))
              : bloc.add(LoadEventChat(eventId: widget.id));
          return bloc;
        }),
      ],
      child: BlocListener<MembersBloc, MembersState>(
        listener: (context, state) {
          if (state is MembersLoaded) {
            setState(() {
              membersToNotify = state.members.map((e) => e.id).toList();
            });
          }
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: DecoratedBox(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.secondary),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Device.get().isIos
                      ? Theme.of(context).brightness == Brightness.light
                          ? const AssetImage(Constants.iPhoneBgChat)
                          : const AssetImage(Constants.iPhoneDarkBgChat)
                      : Theme.of(context).brightness == Brightness.light
                          ? const AssetImage(Constants.phoneBgChat)
                          : const AssetImage(Constants.phoneDarkBgChat),
                  fit: BoxFit.cover,
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: !fixTheInputWidget,
                appBar: AppBar(
                  leading: TapFadeIcon(
                      iconColor: Theme.of(context).iconTheme.color!,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      icon: AppIcons.arrowIosBackOutline,
                      size: Constants.iconDimension),
                  title: GestureDetector(
                    child: TitleAppBar(
                      iD: widget.id,
                      isForTheGroup: widget.isForTheGroup,
                    ),
                    onTap: () {
                      setState(() {
                        fixTheInputWidget = true;
                      });
                      widget.isForTheGroup
                          ? Navigator.of(context)
                              .push(HeroDialogRoute(
                                  builder: (newContext) => SingleGroupPopup(
                                      heroTag: 'groupPopup',
                                      groupId: widget.id)))
                              .then((value) => setState(() {
                                    fixTheInputWidget = false;
                                  }))
                          : Navigator.of(context)
                              .push(
                                HeroDialogRoute(
                                  builder: (newContext) => SingleEventPopup(
                                    heroTag: 'eventPopup',
                                    eventId: widget.id,
                                  ),
                                ),
                              )
                              .then((value) => setState(() {
                                    fixTheInputWidget = false;
                                  }));
                    },
                  ),
                ),
                body: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BlocBuilder<ChatBloc, ChatState>(
                          builder: (context, state) {
                        if (state is ChatError) {
                          debugPrint('${state.error}, ${state.stackTrace}');
                        }

                        if (state is ChatLoaded) {
                          List<Widget> rows = [];

                          // print(Timestamp.fromDate(
                          //     DateTime.parse("2023-05-06 11:31")));

                          final List<Message> messages = state.messages;
                          messages.sort((b, a) => b.timeStamp - a.timeStamp);

                          DateTime now = DateTime.now();

                          var groupByDate = groupBy(
                              messages, (obj) => obj.dateHour.substring(0, 10));

                          groupByDate.forEach((date, messages) {
                            DateTime parsedDate = DateTime.parse(date);

                            for (int i = 0; i < messages.length; i++) {
                              final Message message = messages[i];

                              if (message is TextMessage) {
                                final String messageText = message.text;
                                final String messageSender =
                                    message.senderNickname;
                                final String messageSenderPhoto =
                                    message.senderPhoto;
                                final List<String> splitDateHour =
                                    message.dateHour.split(" ");
                                final String messageHour = splitDateHour[1];

                                double bottomPadding;
                                if (i == messages.length - 1) {
                                  bottomPadding = 15;
                                } else {
                                  bottomPadding = 3.75; // 7.5
                                }

                                // Special case to handle the first message of the group
                                if (i == 0 &&
                                    i + 1 < messages.length &&
                                    messages[i].senderNickname ==
                                        messages[i + 1].senderNickname) {
                                  rows.add(MessageBubble(
                                    bottomPadding: bottomPadding,
                                    sender: messageSender,
                                    text: messageText,
                                    photo: messageSenderPhoto,
                                    isMe: messageSender == currentUserNickname,
                                    hour: messageHour,
                                    dateHour: message.dateHour,
                                  ));
                                }
                                // The first message sent is with the image
                                else if (i + 1 < messages.length &&
                                    i - 1 >= 0 &&
                                    messages[i].senderNickname ==
                                        messages[i + 1].senderNickname &&
                                    messages[i - 1].senderNickname !=
                                        messages[i].senderNickname) {
                                  rows.add(MessageBubble(
                                    bottomPadding: bottomPadding,
                                    sender: messageSender,
                                    text: messageText,
                                    photo: messageSenderPhoto,
                                    isMe: messageSender == currentUserNickname,
                                    hour: messageHour,
                                    dateHour: message.dateHour,
                                  ));
                                }
                                // The internal messages have no image
                                else if (i + 1 < messages.length &&
                                    i - 1 >= 0 &&
                                    messages[i - 1].senderNickname ==
                                        messages[i].senderNickname) {
                                  rows.add(MessageBubbleNoInfo(
                                    bottomPadding: bottomPadding,
                                    sender: messageSender,
                                    text: messageText,
                                    isMe: messageSender == currentUserNickname,
                                    hour: messageHour,
                                    dateHour: message.dateHour,
                                  ));
                                }
                                // Special case for the last message
                                else if (i == messages.length - 1 &&
                                    i - 1 >= 0 &&
                                    messages[i - 1].senderNickname ==
                                        messages[i].senderNickname) {
                                  rows.add(MessageBubbleNoInfo(
                                    bottomPadding: bottomPadding,
                                    sender: messageSender,
                                    text: messageText,
                                    isMe: messageSender == currentUserNickname,
                                    hour: messageHour,
                                    dateHour: message.dateHour,
                                  ));
                                } else {
                                  rows.add(MessageBubble(
                                    bottomPadding: bottomPadding,
                                    sender: messageSender,
                                    text: messageText,
                                    photo: messageSenderPhoto,
                                    isMe: messageSender == currentUserNickname,
                                    hour: messageHour,
                                    dateHour: message.dateHour,
                                  ));
                                }
                              }
                            }

                            /// Header
                            if (now.difference(parsedDate).inDays == 1) {
                              rows.add(const DateInNotificationsAndChat(
                                hasBottomBorder: false,
                                sizedBoxHeight: 30,
                                date: "Yesterday",
                              ));
                            } else if (!DateUtils.isSameDay(now, parsedDate) &&
                                now.year == parsedDate.year) {
                              rows.add(DateInNotificationsAndChat(
                                hasBottomBorder: false,
                                sizedBoxHeight: 30,
                                date:
                                    "${DateFormat('EEEE').format(parsedDate)} ${parsedDate.day} ${DateFormat.MMMM().format(parsedDate)}",
                              ));
                            } else if (!DateUtils.isSameDay(now, parsedDate) &&
                                now.year != parsedDate.year) {
                              rows.add(DateInNotificationsAndChat(
                                hasBottomBorder: false,
                                sizedBoxHeight: 30,
                                date:
                                    "${DateFormat('EEEE').format(parsedDate)} ${parsedDate.day} ${DateFormat.MMMM().format(parsedDate)} ${parsedDate.year}",
                              ));
                            }
                          });

                          if (rows.length - 1 >= 0 &&
                              rows[rows.length - 1]
                                  is DateInNotificationsAndChat) {
                            DateInNotificationsAndChat first =
                                rows[rows.length - 1]
                                    as DateInNotificationsAndChat;
                            rows[rows.length - 1] = DateInNotificationsAndChat(
                                hasBottomBorder: first.hasBottomBorder,
                                sizedBoxHeight: 60,
                                date: first.date);
                          }

                          if (rows.isEmpty) {
                            return Padding(
                              padding:
                                  EdgeInsets.only(top: Constants.heightError),
                              child: const Center(
                                  child: CustomText(text: "No new message")),
                            );
                          } else {
                            return Expanded(
                              child: ListView(
                                reverse: true,
                                // In this way my view goes to the last message
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.0.w,
                                  // vertical: 10.0.h,
                                ),
                                children: rows.reversed.toList(),
                              ),
                            );
                          }
                        }
                        if (state is ChatLoading) {
                          return const Center(
                              child: OurCircularProgressIndicator());
                        } else {
                          return Padding(
                            padding:
                                EdgeInsets.only(top: Constants.heightError),
                            child: const CustomText(
                                text:
                                    "An error occurred while loading the chat"),
                          );
                        }
                      }),
                      InputWidget(
                        iD: widget.id,
                        isForTheGroup: widget.isForTheGroup,
                        chatName: widget.chatName,
                        memberIdsToNotify: membersToNotify,
                        eventCategory: widget.eventCategory,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
