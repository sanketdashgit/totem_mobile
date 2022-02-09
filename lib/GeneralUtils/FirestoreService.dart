import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:convert/convert.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_webservice/staticmap.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/Models/ConversationDetailModel.dart';
import 'package:totem_app/Models/TrackModel.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'LabelStr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

typedef void completionCallBack(dynamic response, Error error);
typedef void completion();

const FCMServerKey =
    'AAAAzT4_wg4:APA91bEWO6PCYK4MGOCWlTJPL2KZm1OxWXJ1m9RR2IiBjwoEhoGBMQVEMjx1-W0rIZR0cGHDAf4C0wvz0bQZ-O-VPi1HNC8ImqIZ2KKA8DSqGB4k4qMtiHK8lU4N4_NPJW58I5nL2yZD';

class Collections {
  static const Users = 'Users';
  static const Conversation = 'Conversation';
  static const ConversationDetail = 'ConversationDetail';
  static const Messages = 'Messages';
  static const ChatAttachment = 'ChatAttachment';
  static const GroupProfile = 'GroupProfile';
  static const FCMToken = 'FCMToken';
}

class FirestoreService {
  Future<void> setDocumentDataWithAutoID(
      String collectionName,
      String documentID,
      Map<String, dynamic> documentData,
      completion completion) async {
    if (documentID == '') {
      FirebaseFirestore.instance
          .collection(collectionName)
          .doc()
          .set(documentData)
          .then((value) {
        completion();
      });
    } else {
      FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentID)
          .set(documentData)
          .then((value) {
        completion();
      });
    }
  }

  Future<void> createSubCollectionWithAutoID(
      String collectionName,
      String documentID,
      String subCollectionName,
      String subCollectionDocumentID,
      Map<String, dynamic> documentData,
      completionCallBack completion) async {
    if (documentID == '' || documentID == null) {
      var test = await FirebaseFirestore.instance
          .collection(collectionName)
          .add({}).then((value) {
        documentID = value.id;
      });
    }
    FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentID)
        .collection(subCollectionName)
        .add(documentData)
        .then((value) {
      completion(documentID, null);
    });
  }

  createUserWithEmailInFireStore(Map<String, dynamic> userInfo) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    var userAuth = await auth.createUserWithEmailAndPassword(
        email: userInfo['email'], password: userInfo['password']);

    if (userAuth != null) {
      Map<String, dynamic> documentData = {
        'uid': userAuth.user.uid,
        'userId': userInfo['userId'],
        'userName': userInfo['userName'],
        'email': userInfo['email']
      };
      storeUserInfoInFirestore(userAuth.user.uid, documentData, () {
        FirestoreService().storeFCMTokenOnFirestore(userAuth.user.uid);
      });
    }
  }

  signInWithEmailAndPasswordInFireStore(
      String email, String password, completionCallBack completion) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    var userAuth =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    if (userAuth != null) {
      FirestoreService().storeFCMTokenOnFirestore(userAuth.user.uid);
      completion(userAuth, null);
    } else {
      completion(null, null);
    }
  }

  storeUserInfoInFirestore(String documentID, Map<String, dynamic> documentData,
      completion completion) {
    setDocumentDataWithAutoID(Collections.Users, documentID, documentData, () {
      completion();
    });
  }

  storeMsgInfoInConversationDetailCollection(Map<String, dynamic> msgInfo,
      String documentId, completionCallBack completion) {
    createSubCollectionWithAutoID(Collections.ConversationDetail, documentId,
        Collections.Messages, documentId, msgInfo, (documentID, error) {
      completion(documentID, error);
    });
  }

  updateMsgInfoInConversationListCollection(
      String documentID, Map<String, dynamic> msgInfo, completion completion) {
    setDocumentDataWithAutoID(Collections.Conversation, documentID, msgInfo,
        () {
      completion();
    });
  }

  uploadFile(
      File attachment, int msgType, completionCallBack completion) async {
    var path = (msgType == MessageType.CImage)
        ? '${Collections.ChatAttachment}/Images/Images${DateTime.now().millisecondsSinceEpoch}'
        : '${Collections.ChatAttachment}/Video/Video${DateTime.now().millisecondsSinceEpoch}';
    firebase_storage.Reference storageRef =
        firebase_storage.FirebaseStorage.instance.ref().child(path);
    firebase_storage.TaskSnapshot uploadTask =
        await storageRef.putFile(attachment);

    if (uploadTask.state == firebase_storage.TaskState.success) {
      uploadTask.ref.getDownloadURL().then((attachmentURL) {
        if (msgType == MessageType.CVideo) {
          getVideoThumbNailandUpload(attachmentURL, (thumbnailURL, error) {
            completion(thumbnailURL, null);
          });
          return;
        }
        completion(attachmentURL, null);
      });
    }
  }

  uploadVideoFile(File attachment, completionCallBack completion) async {
    var path =
        '${Collections.ChatAttachment}/Video/Video${DateTime.now().millisecondsSinceEpoch}';
    firebase_storage.Reference storageRef =
        firebase_storage.FirebaseStorage.instance.ref().child(path);
    firebase_storage.TaskSnapshot uploadTask =
        await storageRef.putFile(attachment);

    if (uploadTask.state == firebase_storage.TaskState.success) {
      uploadTask.ref.getDownloadURL().then((attachmentURL) {
        getVideoThumbNailandUpload(attachmentURL, (videoURLs, error) {
          completion(videoURLs, null);
        });
      });
    }
  }

  Future getVideoThumbNailandUpload(
      String videoURL, completionCallBack completion) async {
    var video = videoURL;
    var fileName = await VideoThumbnail.thumbnailFile(
      video: videoURL,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      quality: 75,
    );

    uploadFile(File(fileName), MessageType.CImage, (thumbnailURL, error) {
      completion({'videoURL': video, 'thumbnail': thumbnailURL}, null);
    });
  }

  deleteMsgForMe(String conversationId, String msgId,
      Map<String, dynamic> msgInfo, completion completion) {
    FirebaseFirestore.instance
        .collection(Collections.ConversationDetail)
        .doc(conversationId)
        .collection(Collections.Messages)
        .doc(msgId)
        .set(msgInfo)
        .then((value) => completion());
  }

  checkConversationIDExistOrNot(int receiverID, completionCallBack completion) {
    FirebaseFirestore.instance
        .collection(Collections.Conversation)
        .where(Parameters.CUsersID, arrayContains: SessionImpl.getId())
        .where(Parameters.CChatType, isEqualTo: ChatType.COTO)
        .get()
        .then((snapshot) {
      var documentID = '';
      if (snapshot.docs.length > 0) {
        snapshot.docs.forEach((element) {
          List<dynamic> users = element.data()[Parameters.CUsersID];
          if (users.contains(receiverID)) {
            completion(element.id, null);
          }
        });
      } else {
        completion('', null);
      }
    });
  }

  resetUnreadMsgCount(String conversationId) {
    getConversationDetail(conversationId, (response, error) {
      DocumentSnapshot snapshot = response;
      Map<String, dynamic> conversationInfo = snapshot.data();

      //...reset unread count to 0 for login user
      var updatedUnreadCount = [];
      var unreadCount = conversationInfo[Parameters.CUnreadCount];
      unreadCount.forEach((user) {
        var updatedUser = user;
        if (user[Parameters.CUserId] == SessionImpl.getId() &&
            updatedUser[Parameters.CCount] != 0)
          updatedUser[Parameters.CCount] = 0;
        updatedUnreadCount.add(updatedUser);
      });
      conversationInfo[Parameters.CUnreadCount] = updatedUnreadCount;

      //...updated unread count
      FirebaseFirestore.instance
          .collection(Collections.Conversation)
          .doc(conversationId)
          .set(conversationInfo);
    });
  }

  getConversationDetail(String conversationId, completionCallBack completion) {
    FirebaseFirestore.instance
        .collection(Collections.Conversation)
        .doc(conversationId)
        .get()
        .then((snapshot) {
      if (snapshot != null) {
        completion(snapshot, null);
      }
    });
  }

  createGroupChat(Map<String, dynamic> groupInfo, File groupProfile,
      completionCallBack completion) {
    uploadGroupProfile(groupProfile, (profileURL, error) {
      var updatedInfo = groupInfo;
      updatedInfo[Parameters.CGroupProfile] = profileURL;

      FirebaseFirestore.instance
          .collection(Collections.Conversation)
          .add(updatedInfo)
          .then((value) {
        var documentID = value.id;

        getConversationDetail(documentID, (response, error) {
          DocumentSnapshot snapshot = response;
          Map<String, dynamic> groupInfo = snapshot.data();
          groupInfo[Parameters.CConversationId] = documentID;

          updateMsgInfoInConversationListCollection(documentID, groupInfo, () {
            getConversationDetail(documentID, (response, error) {
              DocumentSnapshot snapshot = response;
              completion(snapshot, null);
            });
          });
        });
      });
    });
  }

  uploadGroupProfile(File groupProfile, completionCallBack completion) async {
    firebase_storage.Reference storageRef =
        firebase_storage.FirebaseStorage.instance.ref().child(
            '${Collections.GroupProfile}/Images${DateTime.now().millisecondsSinceEpoch}');
    firebase_storage.TaskSnapshot uploadTask =
        await storageRef.putFile(groupProfile);

    if (uploadTask.state == firebase_storage.TaskState.success) {
      uploadTask.ref.getDownloadURL().then((profileURL) {
        completion(profileURL, null);
      });
    }
  }

  updateUserProfileInChat(String profileURL) {
    FirebaseFirestore.instance
        .collection(Collections.Conversation)
        .where(Parameters.CUsersID, arrayContains: SessionImpl.getId())
        .where(Parameters.CChatType, isEqualTo: ChatType.COTO)
        .get()
        .then((snapshot) {
      if (snapshot.docs.length > 0) {
        snapshot.docs.forEach((element) {
          var documentID = element.id;

          var updatedConversationInfo = element.data();
          List<dynamic> users = updatedConversationInfo[Parameters.CUsers];

          List<dynamic> updatedUsers = [];

          users.forEach((user) {
            if (user[Parameters.CUserId] == SessionImpl.getId()) {
              var updatedUser = user;
              updatedUser[Parameters.CUserProfile] = profileURL;
              updatedUsers.add(updatedUser);
            } else {
              updatedUsers.add(user);
            }
          });

          updatedConversationInfo[Parameters.CUsers] = updatedUsers;

          setDocumentDataWithAutoID(Collections.Conversation, documentID,
              updatedConversationInfo, () {});
        });
      }
    });
  }

  storeFCMTokenOnFirestore(String documentId) {
    if (!SessionImpl.getFCMToken().toString().isEmpty) {
      setDocumentDataWithAutoID(Collections.FCMToken, documentId,
          {'token': SessionImpl.getFCMToken()}, () {});
    }
  }

  deleteFCMTokenFromFirestore() {
    //...get user uid from User Collection
    FirebaseFirestore.instance
        .collection(Collections.Users)
        .where(Parameters.CuserIdSmall, isEqualTo: SessionImpl.getId())
        .get()
        .then((snapshot) {
      if (snapshot != null) {
        if (snapshot.docs.length > 0) {
          var uId = snapshot.docs.first.id;

          //... delete FCM Token In Firestore
          FirebaseFirestore.instance
              .collection(Collections.FCMToken)
              .doc(uId)
              .delete();
        }
      }
    });
  }

  getFCMTokenFromServer(List<String> usersId) {
    RequestManager.postRequest(
        uri: endPoints.GetFCMToken,
        body: {"id": usersId},
        isLoader: false,
        isSuccessMessage: false,
        onSuccess: (response) {},
        onFailure: (error) {});
  }

  getUIDsOfUser(Map<String, dynamic> msgInfo, String conversationId) async {
    //...Removed sender user id
    var ids = msgInfo[Parameters.CUsersID];
    ids.removeWhere((userId) => userId == SessionImpl.getId());

    //...Get uid of users from User collection
    FirebaseFirestore.instance
        .collection(Collections.Users)
        .where(Parameters.CuserIdSmall, whereIn: ids)
        .get()
        .then((snapshot) async {
      if (snapshot != null) {
        //...Through uids, will get users FCMToken from FCMToken Collection

        List<String> uids =
            snapshot.docs.map((data) => data.data()['uid'] as String).toList();

        uids.forEach((uid) {
          FirebaseFirestore.instance
              .collection(Collections.FCMToken)
              .doc(uid)
              .get()
              .then((snapshot) {
            if (snapshot.data() != null) {
              var token =
                  (snapshot.data() as Map<String, dynamic>)['token'] as String;

              sendChatMessageFCM(msgInfo, conversationId, token);
            }
          });
        });
      }
    });
  }

  sendChatMessageFCM(Map<String, dynamic> msgInfo, String conversationId,
      String fcmToken) async {
    var senderName = msgInfo[Parameters.CUsers]
        .where(
            (user) => user[Parameters.CUserId] == msgInfo[Parameters.CSenderID])
        .first[Parameters.CuserName];

    var title = (msgInfo[Parameters.CChatType] == ChatType.CGroup)
        ? msgInfo[Parameters.CGroupName]
        : senderName;
    var body = (msgInfo[Parameters.CChatType] == ChatType.CGroup)
        ? '$senderName: ${(msgInfo[Parameters.CTypeMesage] == MessageType.CText) ? msgInfo[Parameters.CMessage] : (msgInfo[Parameters.CTypeMesage] == MessageType.CImage) ? LabelStr.CImage : LabelStr.CVideo}'
        : '${(msgInfo[Parameters.CTypeMesage] == MessageType.CText) ? msgInfo[Parameters.CMessage] : (msgInfo[Parameters.CTypeMesage] == MessageType.CImage) ? LabelStr.CImage : LabelStr.CVideo}';

    final baseURL = 'https://fcm.googleapis.com/fcm/send';
    Map<String, dynamic> payload = {
      'notification': {
        'title': title,
        'body': body,
        'image': (msgInfo[Parameters.CTypeMesage] == MessageType.CImage)
            ? msgInfo[Parameters.CMessage]
            : (msgInfo[Parameters.CTypeMesage] == MessageType.CVideo)
                ? msgInfo[Parameters.CVideoURL]
                : null
      },
      'data': {
        Parameters.CConversationId: conversationId,
        Parameters.CType: NotificationType.CChat,
        Parameters.CConversationInfo: msgInfo
      },
      'to': fcmToken
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'Key=$FCMServerKey'
    };

    final response = await http.post(Uri.parse(baseURL),
        body: json.encode(payload),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      print('FCM sent');
    } else {
      print('FCM error');
    }
  }
}
