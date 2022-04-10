import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ayuprep/features/battleRoom/battleRoomRepository.dart';
import 'package:ayuprep/features/battleRoom/models/message.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageAddInProgress extends MessageState {}

class MessageFetchedSuccess extends MessageState {
  final List<Message> messages;

  MessageFetchedSuccess(this.messages);
}

class MessageAddedFailure extends MessageState {
  String errorCode;
  MessageAddedFailure(this.errorCode);
}

class MessageCubit extends Cubit<MessageState> {
  final BattleRoomRepository _battleRoomRepository;
  MessageCubit(this._battleRoomRepository)
      : super(MessageFetchedSuccess(List<Message>.from([])));

  late StreamSubscription streamSubscription;

  //subscribe to messages stream
  void subscribeToMessages(String roomId) {
    streamSubscription = _battleRoomRepository
        .subscribeToMessages(roomId: roomId)
        .listen((messages) {
      //messages
      emit(MessageFetchedSuccess(messages));
    });
  }

  void addMessage(
      {required String message,
      required by,
      required roomId,
      required isTextMessage}) async {
    try {
      Message messageModel = Message(
        by: by,
        isTextMessage: isTextMessage,
        message: message,
        messageId: "",
        roomId: roomId,
        timestamp: Timestamp.now(),
      );
      await _battleRoomRepository.addMessage(messageModel);
    } catch (e) {
      emit(MessageAddedFailure(e.toString()));
    }
  }

  void deleteMessages(String roomId, String by) {
    streamSubscription.cancel();
    _battleRoomRepository.deleteMessagesByUserId(roomId, by);
  }

  Message getUserLatestMessage(String userId, {String? messageId}) {
    if (state is MessageFetchedSuccess) {
      final messages = (state as MessageFetchedSuccess).messages;
      final messagesByUser = messages.where((element) => element.by == userId);

      if (messagesByUser.isEmpty) {
        return Message.buildEmptyMessage();
      }
      //If message id is passed that means we are checking for latest message
      //else we are fetching latest message to diplay

      //messageId is null means we are fethcing latest message to display
      if (messageId == null) {
        return messagesByUser.first;
      }

      //messageId is not null so we are checking if there is any latest message or not

      //
      return messagesByUser.first.messageId == messageId
          ? Message.buildEmptyMessage()
          : messagesByUser.first;
    }
    return Message.buildEmptyMessage();
  }

  @override
  Future<void> close() async {
    streamSubscription.cancel();
    super.close();
  }
}
