import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/chat/chat_bloc.dart';
import 'package:hang_out_app/business_logic/blocs/user/user_bloc.dart';
import 'package:hang_out_app/data/models/message.dart';
import 'package:hang_out_app/data/repositories/chat_repository.dart';
import 'package:hang_out_app/data/repositories/my_groups_repository.dart';
import 'package:hang_out_app/data/repositories/my_events_repository.dart';
import 'package:hang_out_app/data/repositories/user_repository.dart';
import 'package:hang_out_app/presentation/utils/animations/from_right_page_route.dart';
import 'package:hang_out_app/business_logic/blocs/members/members_bloc.dart';
import 'package:hang_out_app/presentation/utils/animations/custom_rect_tween.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/chat/input_widget.dart';
import 'package:hang_out_app/presentation/widgets/chat/message_bubble.dart';
import 'package:hang_out_app/presentation/widgets/chat/message_bubble_no_info.dart';
import 'package:hang_out_app/presentation/widgets/chat/title_app_bar.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:hang_out_app/presentation/widgets/date_in_notifications_and_chat.dart';
import 'package:hang_out_app/presentation/widgets/our_circular_progress_indicator.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_event_popup.dart';
import 'package:hang_out_app/presentation/widgets/popups/single_group_popup.dart';
import 'package:intl/intl.dart';

class ChatTabletPopup extends StatefulWidget {
  final String heroTag;
  final String id;
  final bool isForTheGroup;
  final String chatName;
  final String? eventCategory;

  const ChatTabletPopup(
      {Key? key,
      required this.heroTag,
      required this.id,
      required this.isForTheGroup,
      required this.chatName,
      this.eventCategory})
      : super(key: key);

  @override
  State<ChatTabletPopup> createState() => _ChatTabletPopupState();
}

class _ChatTabletPopupState extends State<ChatTabletPopup> {
  bool alreadyPop = false;
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
        child: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatError) {
              if (context.mounted) {
                alreadyPop = true;
                Navigator.of(context).pop();
              }
            }
          },
          builder: (context, state) {
            if (state is ChatLoaded) {
              return SafeArea(
                child: Center(
                  child: Hero(
                    tag: widget.heroTag,
                    createRectTween: (begin, end) {
                      return CustomRectTween(begin: begin!, end: end!);
                    },
                    child: Material(
                      color: Theme.of(context).cardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Constants.borderRadius)),
                      child: Container(
                        height: PopupTabletConstants.popupDimension(),
                        width: PopupTabletConstants.popupDimension(),
                        decoration: BoxDecoration(
                          // color: AppColors.whiteColor,
                          image: DecorationImage(
                            image: Theme.of(context).brightness ==
                                    Brightness.light
                                ? const AssetImage(TabletConstants.tabletBgChat)
                                : const AssetImage(
                                    TabletConstants.tabletDarkBgChat),
                            fit: BoxFit.cover,
                            // opacity: 0.2,
                          ),
                          borderRadius:
                              BorderRadius.circular(Constants.borderRadius),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: TitleAppBar(
                                key: const Key("chat-title"),
                                iD: widget.id,
                                isForTheGroup: widget.isForTheGroup,
                              ),
                              onTap: () {
                                widget.isForTheGroup
                                    ? Navigator.of(context).push(
                                        FromRightPageRoute(
                                            builder: (newContext) =>
                                                SingleGroupPopup(
                                                    heroTag: 'groupPopup',
                                                    groupId: widget.id)))
                                    : Navigator.of(context).push(
                                        FromRightPageRoute(
                                          builder: (newContext) =>
                                              SingleEventPopup(
                                            heroTag: 'eventPopup',
                                            eventId: widget.id,
                                          ),
                                        ),
                                      );
                              },
                            ),
                            SizedBox(
                              height: PopupTabletConstants.resize(2),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => FocusManager.instance.primaryFocus
                                    ?.unfocus(),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    BlocBuilder<ChatBloc, ChatState>(
                                        builder: (context, state) {
                                      if (state is ChatError) {
                                        debugPrint(
                                            '${state.error}, ${state.stackTrace}');
                                      }

                                      if (state is ChatLoaded) {
                                        List<Widget> rows = [];

                                        // print(Timestamp.fromDate(
                                        //     DateTime.parse("2023-05-06 11:31")));

                                        final List<Message> messages =
                                            state.messages;
                                        messages.sort((b, a) =>
                                            b.timeStamp - a.timeStamp);

                                        DateTime now = DateTime.now();

                                        var groupByDate = groupBy(
                                            messages,
                                            (obj) =>
                                                obj.dateHour.substring(0, 10));

                                        groupByDate.forEach((date, messages) {
                                          DateTime parsedDate =
                                              DateTime.parse(date);

                                          for (int i = 0;
                                              i < messages.length;
                                              i++) {
                                            final Message message = messages[i];

                                            if (message is TextMessage) {
                                              final String messageText =
                                                  message.text;
                                              final String messageSender =
                                                  message.senderNickname;
                                              final String messageSenderPhoto =
                                                  message.senderPhoto;
                                              final List<String> splitDateHour =
                                                  message.dateHour.split(" ");
                                              final String messageHour =
                                                  splitDateHour[1];

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
                                                      messages[i + 1]
                                                          .senderNickname) {
                                                rows.add(MessageBubble(
                                                  isForTablet: true,
                                                  bottomPadding: bottomPadding,
                                                  sender: messageSender,
                                                  text: messageText,
                                                  photo: messageSenderPhoto,
                                                  isMe: messageSender ==
                                                      currentUserNickname,
                                                  hour: messageHour,
                                                  dateHour: message.dateHour,
                                                ));
                                              }
                                              // The first message sent is with the image
                                              else if (i + 1 <
                                                      messages.length &&
                                                  i - 1 >= 0 &&
                                                  messages[i].senderNickname ==
                                                      messages[i + 1]
                                                          .senderNickname &&
                                                  messages[i - 1]
                                                          .senderNickname !=
                                                      messages[i]
                                                          .senderNickname) {
                                                rows.add(MessageBubble(
                                                  isForTablet: true,
                                                  bottomPadding: bottomPadding,
                                                  sender: messageSender,
                                                  text: messageText,
                                                  photo: messageSenderPhoto,
                                                  isMe: messageSender ==
                                                      currentUserNickname,
                                                  hour: messageHour,
                                                  dateHour: message.dateHour,
                                                ));
                                              }
                                              // The internal messages have no image
                                              else if (i + 1 <
                                                      messages.length &&
                                                  i - 1 >= 0 &&
                                                  messages[i - 1]
                                                          .senderNickname ==
                                                      messages[i]
                                                          .senderNickname) {
                                                rows.add(MessageBubbleNoInfo(
                                                  isForTablet: true,
                                                  bottomPadding: bottomPadding,
                                                  sender: messageSender,
                                                  text: messageText,
                                                  isMe: messageSender ==
                                                      currentUserNickname,
                                                  hour: messageHour,
                                                  dateHour: message.dateHour,
                                                ));
                                              }
                                              // Special case for the last message
                                              else if (i ==
                                                      messages.length - 1 &&
                                                  i - 1 >= 0 &&
                                                  messages[i - 1]
                                                          .senderNickname ==
                                                      messages[i]
                                                          .senderNickname) {
                                                rows.add(MessageBubbleNoInfo(
                                                  isForTablet: true,
                                                  bottomPadding: bottomPadding,
                                                  sender: messageSender,
                                                  text: messageText,
                                                  isMe: messageSender ==
                                                      currentUserNickname,
                                                  hour: messageHour,
                                                  dateHour: message.dateHour,
                                                ));
                                              } else {
                                                rows.add(MessageBubble(
                                                  isForTablet: true,
                                                  bottomPadding: bottomPadding,
                                                  sender: messageSender,
                                                  text: messageText,
                                                  photo: messageSenderPhoto,
                                                  isMe: messageSender ==
                                                      currentUserNickname,
                                                  hour: messageHour,
                                                  dateHour: message.dateHour,
                                                ));
                                              }
                                            }
                                          }

                                          /// Header
                                          if (now
                                                  .difference(parsedDate)
                                                  .inDays ==
                                              1) {
                                            rows.add(
                                                const DateInNotificationsAndChat(
                                              hasBottomBorder: false,
                                              sizedBoxHeight: 30,
                                              date: "Yesterday",
                                            ));
                                          } else if (!DateUtils.isSameDay(
                                                  now, parsedDate) &&
                                              now.year == parsedDate.year) {
                                            rows.add(DateInNotificationsAndChat(
                                              hasBottomBorder: false,
                                              sizedBoxHeight: 30,
                                              date:
                                                  "${DateFormat('EEEE').format(parsedDate)} ${parsedDate.day} ${DateFormat.MMMM().format(parsedDate)}",
                                            ));
                                          } else if (!DateUtils.isSameDay(
                                                  now, parsedDate) &&
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
                                          rows[rows.length - 1] =
                                              DateInNotificationsAndChat(
                                                  hasBottomBorder:
                                                      first.hasBottomBorder,
                                                  sizedBoxHeight: 60,
                                                  date: first.date);
                                        }

                                        if (rows.isEmpty) {
                                          return const Expanded(
                                            child: Center(
                                                child: CustomText(
                                                    text: "No new message")),
                                          );
                                        } else {
                                          return Expanded(
                                            child: ListView(
                                              reverse: true,
                                              // In this way my view goes to the last message
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    PopupTabletConstants.resize(
                                                        30),
                                                // vertical: 10.0.h,
                                              ),
                                              children: rows.reversed.toList(),
                                            ),
                                          );
                                        }
                                      }
                                      if (state is ChatLoading) {
                                        return const Center(
                                            child:
                                                OurCircularProgressIndicator());
                                      } else {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              top: PopupTabletConstants
                                                  .heightError()),
                                          child: const Text(
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
                                      isForTablet: true,
                                    ),
                                    MediaQuery.of(context).viewInsets.bottom !=
                                            0
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom -
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .height -
                                                                PopupTabletConstants
                                                                    .popupDimension()) /
                                                            2 +
                                                        PopupTabletConstants.resize(
                                                            14) >
                                                    0
                                                ? MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom -
                                                    (MediaQuery.of(context)
                                                                .size
                                                                .height -
                                                            PopupTabletConstants
                                                                .popupDimension()) /
                                                        2 +
                                                    PopupTabletConstants.resize(
                                                        14)
                                                : 0)
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                child: OurCircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
