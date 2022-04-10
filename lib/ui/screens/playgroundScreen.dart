import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/battleRoom/cubits/messageCubit.dart';
import 'package:ayuprep/features/battleRoom/models/message.dart';

class PlayGroundScreen extends StatefulWidget {
  PlayGroundScreen({Key? key}) : super(key: key);

  @override
  _PlayGroundScreenState createState() => _PlayGroundScreenState();
}

class _PlayGroundScreenState extends State<PlayGroundScreen>
    with TickerProviderStateMixin {
  String currentUserId = "251"; //current user

  String opponentUserId = "250"; //opponent user
  String roomId = "1234";

  List<Message> userLatestMessages = [];

  @override
  void initState() {
    userLatestMessages.add(Message.buildEmptyMessage());
    userLatestMessages.add(Message.buildEmptyMessage());

    //
    Future.delayed(Duration.zero, () {
      context.read<MessageCubit>().subscribeToMessages(roomId);
    });

    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          heroTag: "Current",
          backgroundColor: Colors.red,
          onPressed: () {
            context.read<MessageCubit>().addMessage(
                  message:
                      "Hello boy current user message - ${Random().nextInt(1000)}",
                  by: currentUserId,
                  roomId: roomId,
                  isTextMessage: true,
                );
          }),
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(),
      body: BlocListener<MessageCubit, MessageState>(
        bloc: context.read<MessageCubit>(),
        listener: (_, state) {
          if (state is MessageFetchedSuccess) {
            //

            if (context
                .read<MessageCubit>()
                .getUserLatestMessage(currentUserId,
                    messageId: userLatestMessages[0].messageId)
                .messageId
                .isNotEmpty) {
              userLatestMessages[0] = context
                  .read<MessageCubit>()
                  .getUserLatestMessage(currentUserId,
                      messageId: userLatestMessages[0].messageId);
              print(
                  "Current user latest message : ${userLatestMessages[0].message}");
            }

            if (context
                .read<MessageCubit>()
                .getUserLatestMessage(opponentUserId,
                    messageId: userLatestMessages[1].messageId)
                .messageId
                .isNotEmpty) {
              userLatestMessages[1] = context
                  .read<MessageCubit>()
                  .getUserLatestMessage(opponentUserId,
                      messageId: userLatestMessages[1].messageId);
              print(
                  "Opponent latest message : ${userLatestMessages[1].message}");
            }
          }
        },
        child: Stack(
          children: [
            Center(
              child: FloatingActionButton(
                  heroTag: "Opponent",
                  onPressed: () {
                    context.read<MessageCubit>().addMessage(
                          message:
                              "Hello boy opponent message - ${Random().nextInt(1000)}",
                          by: opponentUserId,
                          roomId: roomId,
                          isTextMessage: true,
                        );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
