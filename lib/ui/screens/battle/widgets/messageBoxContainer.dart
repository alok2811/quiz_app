import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ayuprep/app/appLocalization.dart';
import 'package:ayuprep/features/battleRoom/cubits/messageCubit.dart';
import 'package:ayuprep/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:ayuprep/features/battleRoom/models/message.dart';
import 'package:ayuprep/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:ayuprep/features/quiz/models/quizType.dart';
import 'package:ayuprep/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:ayuprep/ui/widgets/customRoundedButton.dart';
import 'package:ayuprep/utils/constants.dart';
import 'package:ayuprep/utils/stringLabels.dart';
import 'package:ayuprep/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageBoxContainer extends StatefulWidget {
  final VoidCallback closeMessageBox;
  final double? topPadding;
  final String battleRoomId;
  final QuizTypes quizType;

  MessageBoxContainer({
    Key? key,
    required this.closeMessageBox,
    this.topPadding,
    required this.battleRoomId,
    required this.quizType,
  }) : super(key: key);

  @override
  _MessageBoxContainerState createState() => _MessageBoxContainerState();
}

final double tabBarHeightPercentage = 0.085;
final double messageBoxWidthPercentage = 0.775;

class _MessageBoxContainerState extends State<MessageBoxContainer> {
  late int _currentSelectedIndex = 1;
  late double messageBoxDetailsHeightPercentage =
      widget.quizType == QuizTypes.groupPlay
          ? (UiUtils.questionContainerHeightPercentage - (0.05 + 0.045))
          : (UiUtils.questionContainerHeightPercentage - (0.05));
  late final double messageBoxHeightPercentage =
      UiUtils.questionContainerHeightPercentage - (0.03);

  Widget _buildTabbarTextContainer(String text, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentSelectedIndex = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(
            color: Theme.of(context)
                .backgroundColor
                .withOpacity(index == _currentSelectedIndex ? 1.0 : 0.65)),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * tabBarHeightPercentage,
      width: MediaQuery.of(context).size.width * messageBoxWidthPercentage,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //_buildTabbarTextContainer(AppLocalization.of(context)!.getTranslatedValues(chatKey)!, 0),
          _buildTabbarTextContainer(
              AppLocalization.of(context)!.getTranslatedValues(messagesKey)!,
              1),
          _buildTabbarTextContainer(
              AppLocalization.of(context)!.getTranslatedValues(emojisKey)!, 2),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    if (_currentSelectedIndex == 0) {
      return Container();
    } else if (_currentSelectedIndex == 1) {
      return MessagesContainer(
        battleRoomId: widget.battleRoomId,
        closeMessageBox: widget.closeMessageBox,
      );
    }
    return EmojisContainer(
      battleRoomId: widget.battleRoomId,
      closeMessageBox: widget.closeMessageBox,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: widget.topPadding ??
            (MediaQuery.of(context).padding.top +
                7.5 +
                MediaQuery.of(context).size.height * (0.01)),
      ),
      width: MediaQuery.of(context).size.width * messageBoxWidthPercentage,
      height: MediaQuery.of(context).size.height * (messageBoxHeightPercentage),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * (0.085) * 0.25),
              width:
                  MediaQuery.of(context).size.width * messageBoxWidthPercentage,
              height: MediaQuery.of(context).size.height *
                  (messageBoxDetailsHeightPercentage),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildTabBarView(),
              ),
            ),
          ),
          Align(alignment: Alignment.topRight, child: _buildTabBar(context)),
        ],
      ),
    );
  }
}

/*class SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const SendButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 40.0,
        left: MediaQuery.of(context).size.width * (0.175),
        right: MediaQuery.of(context).size.width * (0.175),
      ),
      child: CustomRoundedButton(
        widthPercentage: MediaQuery.of(context).size.width * (0.4),
        backgroundColor: Theme.of(context).primaryColor,
        buttonTitle: "Send",
        titleColor: Theme.of(context).backgroundColor,
        radius: 10,
        showBorder: false,
        elevation: 5,
        height: 40,
        onTap: onTap,
      ),
    );
  }
}*/

class ChatContainer extends StatelessWidget {
  final QuizTypes quizType;
  const ChatContainer({Key? key, required this.quizType}) : super(key: key);

  Widget _buildMessage(BuildContext context, Message message) {
    bool messageByCurrentUser =
        message.by == context.read<UserDetailsCubit>().getUserId();
    MultiUserBattleRoomCubit battleRoomCubit =
        context.read<MultiUserBattleRoomCubit>();

    return Align(
      alignment: messageByCurrentUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * (0.3),
          maxWidth: MediaQuery.of(context).size.width * (0.5),
        ),
        margin: messageByCurrentUser
            ? EdgeInsets.only(bottom: 20.0, right: 15.0)
            : EdgeInsets.only(bottom: 20.0, left: 15.0),
        child: Column(
          crossAxisAlignment: messageByCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                //
                messageByCurrentUser
                    ? Container()
                    : Padding(
                        padding: const EdgeInsetsDirectional.only(
                            bottom: 5.0, start: 10.0),
                        child: Text(
                          "${battleRoomCubit.getUser(message.by)!.name}  ",
                          style: TextStyle(
                              fontSize: 11.0,
                              color: Theme.of(context).backgroundColor),
                        ),
                      ),

                Padding(
                  padding: messageByCurrentUser
                      ? const EdgeInsets.only(bottom: 5.0, right: 10.0)
                      : const EdgeInsets.only(bottom: 5.0, left: 10.0),
                  child: Text(
                    "${message.timestamp.toDate().hour}:${message.timestamp.toDate().minute}",
                    style: TextStyle(
                        fontSize: 11.0,
                        color: Theme.of(context).backgroundColor),
                  ),
                ),
              ],
            ),
            CustomPaint(
              painter: ChatMessagePainter(
                  isLeft: !messageByCurrentUser,
                  color: Theme.of(context).backgroundColor),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: message.isTextMessage
                    ? Text(
                        "${message.message}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.25,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.85),
                        ),
                      )
                    : SizedBox(
                        height: 30,
                        width: MediaQuery.of(context).size.width * (0.2),
                        child: SvgPicture.asset(
                          UiUtils.getEmojiPath(message.message),
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.85),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageCubit, MessageState>(
      bloc: context.read<MessageCubit>(),
      builder: (context, state) {
        if (state is MessageFetchedSuccess) {
          List<Message> messages = state.messages;
          messages = messages.reversed.toList();
          return messages.isEmpty
              ? Container()
              : ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height *
                        tabBarHeightPercentage,
                    bottom: 10,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(context, messages[index]);
                  });
        }
        return Container();
      },
    );
  }
}

class MessagesContainer extends StatefulWidget {
  final String battleRoomId;
  final VoidCallback closeMessageBox;
  MessagesContainer(
      {Key? key, required this.closeMessageBox, required this.battleRoomId})
      : super(key: key);

  @override
  _MessagesContainerState createState() => _MessagesContainerState();
}

class _MessagesContainerState extends State<MessagesContainer> {
  int currentlySelectedMessageIndex = -1;

  Widget _buildMessages() {
    return ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * tabBarHeightPercentage,
          bottom: 100,
        ),
        itemCount: predefinedMessages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (0.05),
              vertical: 10,
            ),
            child: CustomRoundedButton(
              onTap: () {
                MessageCubit messageCubit = context.read<MessageCubit>();

                UserDetailsCubit userDetailsCubit =
                    context.read<UserDetailsCubit>();
                messageCubit.addMessage(
                  message: predefinedMessages[index],
                  by: userDetailsCubit.getUserId(),
                  roomId: widget.battleRoomId,
                  isTextMessage: true,
                );
                widget.closeMessageBox();
              },
              widthPercentage: MediaQuery.of(context).size.width * (0.4),
              backgroundColor: currentlySelectedMessageIndex == index
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).backgroundColor,
              buttonTitle: predefinedMessages[index],
              titleColor: currentlySelectedMessageIndex == index
                  ? Theme.of(context).backgroundColor
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              radius: 10,
              showBorder: false,
              height: 40,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _buildMessages(),
        ),
        /*  Align(
            alignment: Alignment.bottomCenter,
            child: SendButton(onTap: () {
              if (currentlySelectedMessageIndex != -1) {
                MessageCubit messageCubit = context.read<MessageCubit>();
                BattleRoomCubit battleRoomCubit = context.read<BattleRoomCubit>();
                UserDetailsCubit userDetailsCubit = context.read<UserDetailsCubit>();
                messageCubit.addMessage(
                  message: predefinedMessages[currentlySelectedMessageIndex],
                  by: userDetailsCubit.getUserId(),
                  roomId: battleRoomCubit.getRoomId(),
                  isTextMessage: true,
                );
                widget.closeMessageBox();
              }
            })),*/
      ],
    );
  }
}

class EmojisContainer extends StatefulWidget {
  final VoidCallback closeMessageBox;
  final String battleRoomId;
  EmojisContainer(
      {Key? key, required this.closeMessageBox, required this.battleRoomId})
      : super(key: key);

  @override
  _EmojisContainerState createState() => _EmojisContainerState();
}

class _EmojisContainerState extends State<EmojisContainer> {
  int currentlySelectedEmojiIndex = -1;

  Widget _buildEmojies(List<String> emojis) {
    return GridView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * tabBarHeightPercentage,
          left: MediaQuery.of(context).size.width * (0.05),
          right: MediaQuery.of(context).size.width * (0.05),
          bottom: 100,
        ),
        itemCount: emojis.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              MessageCubit messageCubit = context.read<MessageCubit>();

              UserDetailsCubit userDetailsCubit =
                  context.read<UserDetailsCubit>();
              messageCubit.addMessage(
                message: emojis[index],
                by: userDetailsCubit.getUserId(),
                roomId: widget.battleRoomId,
                isTextMessage: false,
              );
              widget.closeMessageBox();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: index == currentlySelectedEmojiIndex
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).backgroundColor,
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.5, vertical: 15.0),
                      child: SvgPicture.asset(
                        UiUtils.getEmojiPath(emojis[index]),
                        color: index == currentlySelectedEmojiIndex
                            ? Theme.of(context).backgroundColor
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final emojis = context.read<SystemConfigCubit>().getEmojis();
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _buildEmojies(emojis),
        ),
        /*   Align(
            alignment: Alignment.bottomCenter,
            child: SendButton(onTap: () {
              if (currentlySelectedEmojiIndex != -1) {
                MessageCubit messageCubit = context.read<MessageCubit>();
                BattleRoomCubit battleRoomCubit = context.read<BattleRoomCubit>();
                UserDetailsCubit userDetailsCubit = context.read<UserDetailsCubit>();
                messageCubit.addMessage(
                  message: emojis[currentlySelectedEmojiIndex],
                  by: userDetailsCubit.getUserId(),
                  roomId: battleRoomCubit.getRoomId(),
                  isTextMessage: false,
                );
                widget.closeMessageBox();
              }
            })),*/
      ],
    );
  }
}

class ChatMessagePainter extends CustomPainter {
  bool isLeft;
  Color color;
  ChatMessagePainter({required this.isLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (isLeft) {
      path.moveTo(size.width * (0.1), 0);
      path.lineTo(size.width * (0.9), 0);

      //add top-right curve effect
      path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.2);

      path.lineTo(size.width, size.height * (0.8));
      //add bottom-right curve
      path.quadraticBezierTo(
          size.width, size.height, size.width * (0.9), size.height);
      path.lineTo(size.width * (0.125), size.height);

      //add botom left shape
      path.lineTo(size.width * (0.025), size.height * (1.175));
      path.quadraticBezierTo(
          -10, size.height * (1.275), 0, size.height * (0.8));

      //add left-top curve
      path.lineTo(0, size.height * (0.2));
      path.quadraticBezierTo(0, 0, size.width * (0.1), 0);
      canvas.drawPath(path, paint);
    } else {
      //

      path.moveTo(size.width * (0.1), 0);
      path.quadraticBezierTo(0, 0, 0, size.height * (0.2));
      path.lineTo(0, size.height * (0.8));

      path.quadraticBezierTo(0, size.height, size.width * (0.1), size.height);
      path.lineTo(size.width * (0.875), size.height);

      //add bottom right shape
      //path.quadraticBezierTo(x1, y1, x2, y2);
      path.lineTo(size.width * (0.975), size.height * (1.175));
      path.quadraticBezierTo(size.width + 10, size.height * (1.275), size.width,
          size.height * (0.8));

      path.lineTo(size.width, size.height * (0.2));
      path.quadraticBezierTo(size.width, 0, size.width * (0.9), 0);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
