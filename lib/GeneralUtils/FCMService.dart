import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/utils.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/ConversationListModel.dart';
import 'package:totem_app/Ui/Chat/ChatDetailScreen.dart';
import 'package:totem_app/Ui/Notification/NotificationScreen.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:get/get.dart';
import 'CommonStuff.dart';

class FCMService {
  getFCMToken() async {
    FirebaseMessaging.instance.getToken().then((token) async {
      SessionImpl.setFCMToken(token);
    });
  }

  void registerNotification() async {
    //...On iOS, this helps to take the user permissions
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    _handleNotificationState();
  }

  _handleNotificationState() {

    //...Will be call when app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      _handleForegroundNotification(message);
    });

    //...Handle the background notifications (the app is terminated)
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
          handleNotificationRedirection(message);
      }
    });

    //...Will be call click on notification when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationRedirection(message);
    });
  }

  _handleForegroundNotification(RemoteMessage message) {
    String notificationType = message.data[Parameters.CType];

    if (int.parse(notificationType) == NotificationType.CChat) {
      if (rq.isChatDetailOpen &&
          rq.conversationID == message.data[Parameters.CConversationId]) return;
    }

    RequestManager.getSnackToast(
        title: message.notification.title,
        message: message.notification.body,
        backgroundColor: screenBgColor);
  }

  handleNotificationRedirection(RemoteMessage message) {
    var payloadInfo = message.data;
    String notificationType = payloadInfo[Parameters.CType];

    if (int.parse(notificationType) == NotificationType.CChat) {
      _handleChatNotification(payloadInfo);
    }else{
      Get.to(NotificationScreen());
    }
  }

  _handleChatNotification(Map<String, dynamic> payload) {
    Map<String, dynamic> conversationInfo =
        json.decode(payload[Parameters.CConversationInfo]);

    var conversationModel = ConversationInfoModel.fromPayload(conversationInfo);

    Get.to(ChatDetailScreen(
      payload[Parameters.CConversationId],
      getFrontUser(conversationModel.users).toMap(),
      conversationInfoModel: conversationModel,
    ));
  }
}
