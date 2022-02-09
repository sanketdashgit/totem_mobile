import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totem_app/GeneralUtils/FirestoreService.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/ConversationDetailModel.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Constant.dart';

Future<bool> checkConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

Map<String, dynamic> getUserName(String userName) {
  var fullName = userName;
  List<String> splitName = fullName.split(" ");

  if (splitName.length > 0) {
    if (splitName.length >= 2) {
      return {'fName': splitName[0], 'lName': splitName[1]};
    }else{
      return {'fName': splitName[0], 'lName': 'NA'};
    }
  }

  return null;
}

Future<String> cropImage(PickedFile file) async {
  final cropImageFile = await ImageCropper.cropImage(
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      sourcePath: file.path,
      maxWidth: 512,
      maxHeight: 512,
      compressFormat: ImageCompressFormat.jpg);

  return cropImageFile.path;
}

bool isToday(int timestamp) {
  final today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime msgDate = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  final conversationDate = DateTime(msgDate.year, msgDate.month, msgDate.day);
  return conversationDate == today;
}

bool isYesterday(int timestamp) {
  final yesterday = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  DateTime msgDate = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  final conversationDate = DateTime(msgDate.year, msgDate.month, msgDate.day);
  return conversationDate == yesterday;
}

String getConversationDate(int timestamp) {
  DateTime msgDate = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();

  if (isToday(timestamp)) {
    return LabelStr.lblToday;
  } else if (isYesterday(timestamp)) {
    return LabelStr.lblYesterday;
  } else {
    return "${msgDate.day}/${msgDate.month}/${msgDate.year}";
  }
}

String getTimeForConversationList(int timestamp) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);

  DateTime msgDate = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  final conversationDate = DateTime(msgDate.year, msgDate.month, msgDate.day);

  if (conversationDate == today) {
    return '${DateFormat('hh:mm a').format(msgDate)}';
  } else if (conversationDate == yesterday) {
    return LabelStr.lblYesterday;
  } else {
    return "${msgDate.day}/${msgDate.month}/${msgDate.year}";
  }
}

String getStringDateFromTimestamp(int timestamp, String format) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  return '${DateFormat(format).format(date)}';
}

MessageUserInfoModel getFrontUser(List<MessageUserInfoModel> users) {
  var user = users.where((data) => data.userId != SessionImpl.getId());
  return user.first;
}

bool isTooLargeFile(File file) {
  int sizeInBytes = file.lengthSync();
  double sizeInMb = sizeInBytes / (1024 * 1024);
  if (sizeInMb > 10) {
    return false;
  }
  return true;
}

void clearOverlay(){
  SessionImpl.setIntro1(false);
  SessionImpl.setIntro2(false);
  SessionImpl.setIntro3(false);
  SessionImpl.setIntro4(false);
  SessionImpl.setIntro5(false);
  SessionImpl.setIntro6(false);
  SessionImpl.setIntro7(false);
  SessionImpl.setIntro8(false);
  SessionImpl.setIntro9(false);
  SessionImpl.setIntro10(false);
}

logOut() {
  _callLogoutApi();
  rq.selectedEvents = [];
  rq.selectedArtist = [];
  rq.selectedGener = [];
  rq.selectedTracks = [];
  rq.pickedImageList = [];
  rq.pickedMediaList = [];
  rq.postMediaLinks = [];
  rq.eventList = [];
  rq.homeFeedList = [];
  rq.postCommentList = [];
  rq.removedList = [];
  rq.postCommentWidgetRefresher.value = "";
  rq.imagePageRefrasher.value = "";

  FirestoreService().deleteFCMTokenFromFirestore();

  SessionImpl.setLogIn(false);
  SessionImpl.setprivacy(false);

  GoogleSignIn _googleSignIn = GoogleSignIn();
  _googleSignIn.isSignedIn().then((isSignedIn) {
    if (isSignedIn) _googleSignIn.signOut();
  });

  final facebookLogin = FacebookLogin();
  facebookLogin.isLoggedIn.then((isLoggedIn) {
    if (isLoggedIn) facebookLogin.logOut();
  });
  //clearOverlay();
  FirebaseAuth.instance.signOut();
}

void _callLogoutApi() {
  var body = {
    Parameters.Cid: SessionImpl.getId(),
    Parameters.Cfcm: SessionImpl.getFCMToken(),
    Parameters.Clogin: false,
  };

  RequestManager.postRequest(
      uri: endPoints.LogoutFCM,
      body: body,
      isLoader: false,
      isFailedMessage: false,
      isSuccessMessage: false,
      onSuccess: (response) {},
      onFailure: (error) {});
}

Future<void> forceUpdate() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  var body = {
    Parameters.CType: Platform.isIOS ? 'iOS' : 'Android',
    Parameters.CVersion: packageInfo.version
  };

  RequestManager.postRequest(
      uri: endPoints.getUpdatedVersion,
      body: body,
      isLoader: false,
      isFailedMessage: false,
      isSuccessMessage: false,
      onSuccess: (response) async {
        //...Show alert view for force update app If installed app version is less than app store app version
        if (response[Parameters.CUpdateRequired] == true) {
          await showAlertDialogLogout(response[Parameters.CIsMandatory]);
        }
      },
      onFailure: (error) {});
}

showAlertDialogLogout(bool isMandatory) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(LabelStr.lblCancel),
    onPressed: () {
      Get.back();
    },
  );
  Widget updateButton = TextButton(
    child: Text(LabelStr.lblUpdate),
    onPressed: () {
      Get.back();
      launchURL(Platform.isIOS ? AppStoreURL : PlayStoreURL);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(LabelStr.lblUpdateApp),
    content: Text(
        "Latest update available on ${Platform.isIOS ? 'app store' : 'play store'}."),
    actions: isMandatory
        ? [updateButton]
        : [
            cancelButton,
            updateButton,
          ],
  );

  // show the dialog
  showDialog(
      context: Get.context,
      builder: (BuildContext context) {
        return alert;
      },
      barrierDismissible: false);
}

void launchURL(String _url) async =>
    await canLaunch(_url) ? await launch(_url) : throw '${LabelStr.lblCouldNotLaunch} $_url';
