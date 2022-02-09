import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';

import 'ConversationDetailModel.dart';

class ConversationListModel {
  List<ConversationInfoModel> conversationList;

  ConversationListModel({this.conversationList});

  ConversationListModel.fromJson(dynamic json) {
    conversationList = [];

    List<dynamic> jsonList = json;
    jsonList.forEach((msgInfo) {
      conversationList.add(ConversationInfoModel.fromJson(msgInfo));
    });
  }
}

class ConversationInfoModel {
  String message;
  int msgType;
  String videoURL;
  int timestamp;
  List<MessageUserInfoModel> users;
  int senderId;
  String conversationId;
  List<dynamic> usersId;
  List<dynamic> unreadCount;
  int chatType;
  String groupName;
  String groupProfile;
  bool isDeleted;
  List<dynamic> deletedFor;

  ConversationInfoModel(
      {this.message,
      this.timestamp,
      this.videoURL,
      this.msgType,
      this.users,
      this.senderId,
      this.usersId,
      this.conversationId,
      this.unreadCount,
      this.chatType,
      this.groupName,
      this.groupProfile,
      this.isDeleted});

  ConversationInfoModel.fromJson(DocumentSnapshot json) {
    Map<String, dynamic> data = json.data();

    users = [];
    List<dynamic> jsonList = data[Parameters.CUsers];
    jsonList.forEach((user) {
      users.add(MessageUserInfoModel.fromJson(user));
    });

    message = data[Parameters.CMessage];
    timestamp = data[Parameters.CTimestamp];
    videoURL =
        (data[Parameters.CVideoURL] == null) ? '' : data[Parameters.CVideoURL];
    msgType = data[Parameters.CTypeMesage];
    senderId = data[Parameters.CSenderID];
    usersId = data[Parameters.CUsersID];
    conversationId = data[Parameters.CConversationId];
    unreadCount = data[Parameters.CUnreadCount];
    chatType = data[Parameters.CChatType];
    groupName = data[Parameters.CGroupName];
    groupProfile = data[Parameters.CGroupProfile];
    isDeleted = data[Parameters.CIsDeleted];
    deletedFor = (data[Parameters.CDeletedFor] == null)
    ? []
    : data[Parameters.CDeletedFor];
  }

  ConversationInfoModel.fromPayload(Map<String, dynamic> data) {

    users = [];
    List<dynamic> jsonList = data[Parameters.CUsers];
    jsonList.forEach((user) {
      users.add(MessageUserInfoModel.fromJson(user));
    });

    message = data[Parameters.CMessage];
    timestamp = data[Parameters.CTimestamp];
    videoURL =
    (data[Parameters.CVideoURL] == null) ? '' : data[Parameters.CVideoURL];
    msgType = data[Parameters.CTypeMesage];
    senderId = data[Parameters.CSenderID];
    usersId = data[Parameters.CUsersID];
    conversationId = data[Parameters.CConversationId];
    unreadCount = data[Parameters.CUnreadCount];
    chatType = data[Parameters.CChatType];
    groupName = data[Parameters.CGroupName];
    groupProfile = data[Parameters.CGroupProfile];
    isDeleted = data[Parameters.CIsDeleted];
    deletedFor = (data[Parameters.CDeletedFor] == null)
    ? []
    : data[Parameters.CDeletedFor];
  }
}
