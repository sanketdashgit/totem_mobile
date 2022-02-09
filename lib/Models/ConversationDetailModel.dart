import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';

class ConversationDetailModel {
  List<MessageInfoModel> messageList;

  ConversationDetailModel({this.messageList});

  ConversationDetailModel.fromJson(dynamic json) {
    messageList = [];

    UserInfoModel userModel =
        (SessionImpl.getLoginProfileModel() as UserInfoModel);

    List<dynamic> jsonList = json;
    jsonList.forEach((msgInfo) {
      QueryDocumentSnapshot snapshotJson = msgInfo;

      //...Don't add deleted message by user
      if ((snapshotJson.data() as Map<String, dynamic>)
              .containsKey(Parameters.CDeletedFor) &&
          msgInfo[Parameters.CDeletedFor] != null) {
        if ((msgInfo[Parameters.CDeletedFor] as List<dynamic>)
            .contains(userModel.id)) {
          return;
        }
      }

      messageList.add(MessageInfoModel.fromJson(msgInfo, snapshotJson.id));
    });
  }
}

class MessageInfoModel {
  String message;
  int msgType;
  String videoURL;
  int timestamp;
  List<MessageUserInfoModel> users;
  int senderId;
  String msgId;
  List<dynamic> deletedFor;
  bool isLocal;
  bool isDeleted;
  int chatType;

  MessageInfoModel(
      {this.message,
      this.timestamp,
      this.videoURL,
      this.msgType,
      this.users,
      this.senderId,
      this.msgId,
      this.deletedFor,
      this.isLocal = false,
      this.isDeleted,
      this.chatType});

  MessageInfoModel.fromJson(DocumentSnapshot json, String documentId) {
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
    msgId = documentId;
    deletedFor = (data[Parameters.CDeletedFor] == null)
        ? []
        : data[Parameters.CDeletedFor];
    isDeleted = (data[Parameters.CIsDeleted] == null)
        ? false
        : data[Parameters.CIsDeleted];
    isLocal = false;
    chatType = data[Parameters.CChatType];
  }

  toMap() {
    var updatedUsers = [];
    users.forEach((element) {
      updatedUsers.add(element.toMap());
    });

    return {
      Parameters.CUsers: updatedUsers,
      Parameters.CMessage: message,
      Parameters.CTypeMesage: msgType,
      Parameters.CTimestamp: timestamp,
      Parameters.CSenderID: senderId,
      Parameters.CVideoURL: videoURL,
      Parameters.CChatType: chatType,
      Parameters.CIsDeleted: isDeleted
    };
  }
}

class MessageUserInfoModel {
  int userId;
  String userName;
  String userProfile;
  String firstName;
  String lastName;

  MessageUserInfoModel(
      {this.userId,
      this.userName,
      this.userProfile,
      this.firstName,
      this.lastName});

  factory MessageUserInfoModel.fromJson(dynamic json) {
    return MessageUserInfoModel(
        userId: json[Parameters.CUserId],
        userName: json[Parameters.CuserName],
        userProfile: json[Parameters.CUserProfile],
        firstName: json[Parameters.CFirstName] ?? '',
        lastName: json[Parameters.CLastName] ?? '');
  }

  toMap() {
    return {
      Parameters.CUserId: userId,
      Parameters.CuserName: userName,
      Parameters.CUserProfile: userProfile,
      Parameters.CFirstName: firstName,
      Parameters.CLastName: lastName
    };
  }
}
