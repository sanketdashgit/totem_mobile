import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_app/GeneralUtils/Alertview.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/CommonStuff.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FirestoreService.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/ConversationDetailModel.dart';
import 'package:totem_app/Models/ConversationListModel.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Chat/GroupDetailScreen.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/VideoPlayerScreen.dart';
import 'package:totem_app/Ui/Profile/OtherUserProfile.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:collection/collection.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

class ChatDetailScreen extends StatefulWidget {
  String msgID;
  ConversationInfoModel conversationInfoModel;
  Map<String, dynamic> receiverUserInfo;

  ChatDetailScreen(this.msgID, this.receiverUserInfo,
      {this.conversationInfoModel});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  Map<String, List<MessageInfoModel>> chatList;
  var listVRefresher = ''.obs;

  UserInfoModel userModel =
      (SessionImpl.getLoginProfileModel() as UserInfoModel);
  var txtMsgController = TextEditingController();
  ScrollController scrollController = ScrollController();
  DocumentSnapshot lastDocSnapshot;
  String strLastUploadedMedia = '';
  String strLastVideoThumbnail = '';
  List<dynamic> fcmTokens = [];

  @override
  void initState() {
    super.initState();

    if (widget.msgID.isNotEmpty) _getMessageSnapShot();

    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        _loadMoreMessages();
      }
    });

    setInfoForManagePushNotification(true);
    _getFCMToken();
  }

  _getFCMToken() {
    List<dynamic> ids = [];

    if (widget.conversationInfoModel == null) {
      ids = [widget.receiverUserInfo[Parameters.CUserId]];
    } else {
      //...Removed sender user id
      ids = widget.conversationInfoModel.usersId;
      ids.removeWhere((userId) => userId == SessionImpl.getId());
    }

    RequestManager.postRequest(
        uri: endPoints.GetFCMToken,
        body: {Parameters.Cid: ids},
        isLoader: false,
        isSuccessMessage: false,
        onSuccess: (response) {
          List<dynamic> tokens = response;
          fcmTokens = tokens.map((tokenInfo) => tokenInfo["fcm"]).toList();

        },
        onFailure: (error) {

        });
  }

  _getMessageSnapShot() {
    FirebaseFirestore.instance
        .collection(Collections.ConversationDetail)
        .doc(widget.msgID)
        .collection(Collections.Messages)
        .orderBy(Parameters.CTimestamp, descending: true)
        .limit(CLimit)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.length > 0) {
        lastDocSnapshot = snapshot.docs.last;

        List<MessageInfoModel> msgList =
            ConversationDetailModel.fromJson(snapshot.docs).messageList;

        var newAdded = [];
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            newAdded.add(newAdded.length + 1);

            if (strLastUploadedMedia.isNotEmpty) {
              Map<String, dynamic> data = change.doc.data();
              if ((data[Parameters.CTypeMesage] == MessageType.CImage ||
                      data[Parameters.CTypeMesage] == MessageType.CVideo) &&
                  (data[Parameters.CSenderID] == userModel.id)) {
                var lastMsg = msgList.first;
                lastMsg.message = strLastUploadedMedia;
                lastMsg.isLocal = true;

                if (lastMsg.msgType == MessageType.CVideo)
                  lastMsg.videoURL = strLastVideoThumbnail;
                msgList[0] = lastMsg;
                strLastUploadedMedia = '';
                strLastVideoThumbnail = '';
              }
            }
          }
        });

        chatList = (groupBy<MessageInfoModel, String>(msgList, (msgInfo) {
          return getConversationDate(msgInfo.timestamp);
        }));

        listVRefresher.value = Utilities.getRandomString();

        return messageListView();
      }

      return Expanded(child: Center());
    });
  }

  _loadMoreMessages() {
    if (lastDocSnapshot != null) {
      Map<String, dynamic> lastMsg = lastDocSnapshot.data();
      var timestamp = lastMsg['timestamp'];

      FirebaseFirestore.instance
          .collection(Collections.ConversationDetail)
          .doc(widget.msgID)
          .collection(Collections.Messages)
          .where(Parameters.CTimestamp, isLessThan: timestamp)
          .orderBy(Parameters.CTimestamp, descending: true)
          .limit(CLimit)
          .get()
          .then((snapshot) {
        if (snapshot.docs.length > 0) {
          lastDocSnapshot = snapshot.docs.last;

          List<MessageInfoModel> msgList =
              ConversationDetailModel.fromJson(snapshot.docs).messageList;

          groupBy<MessageInfoModel, String>(msgList, (msgInfo) {
            //...Update key values If Key already exist otherwise will create new key for value
            addValueToMap(
                chatList, getConversationDate(msgInfo.timestamp), msgInfo);
          });

          listVRefresher.value = Utilities.getRandomString();
        }
      });
    }
  }

  void addValueToMap<K, V>(Map<K, List<V>> map, K key, V value) =>
      map.update(key, (list) => list..add(value), ifAbsent: () => [value]);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: screenBgColor, body: chatDetailView()),
        onWillPop: () => _pressedOnBack());
  }

  Widget chatDetailView() {
    return SafeArea(
        child: Obx(() => Column(
              children: [
                appBarView(),
                if (listVRefresher.value.isNotEmpty) messageListView(),
                if (listVRefresher.value.isEmpty) Expanded(child: Center()),
                bottomView()
              ],
            )));
  }

  Widget appBarView() {
    return SizedBox(
        width: screenWidth(context),
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(
              right: ScreenUtil().setWidth(20),
            ),
            child: Row(
              children: [
                InkWell(
                    onTap: () => _pressedOnBack(),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: SvgPicture.asset(MyImage.ic_arrow),
                    )),
                Expanded(
                    child: Center(
                  child: Text(
                    (widget.conversationInfoModel == null)
                        ? widget.receiverUserInfo[Parameters.CuserName]
                        : (widget.conversationInfoModel.chatType ==
                                ChatType.CGroup)
                            ? widget.conversationInfoModel.groupName
                            : getFrontUser().userName,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: MyFont.Poppins_semibold,
                        color: Colors.white),
                  ),
                )),
                InkWell(
                  onTap: () {
                    if ((widget.conversationInfoModel != null) &&
                        (widget.conversationInfoModel.chatType ==
                            ChatType.CGroup)) {
                      Get.to(GroupDetailScreen(widget.conversationInfoModel));
                    } else {
                      Get.to(OtherUserProfile(
                          widget.receiverUserInfo[Parameters.CUserId],
                          widget.receiverUserInfo[Parameters.CuserName],
                          widget.receiverUserInfo[Parameters.CuserName],
                          false,
                          widget.receiverUserInfo[Parameters.CUserProfile]));
                    }
                  },
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(40) / 2),
                    child: CachedNetworkImage(
                        imageUrl: (widget.conversationInfoModel == null)
                            ? widget.receiverUserInfo[Parameters.CUserProfile]
                            : (widget.conversationInfoModel.chatType ==
                                    ChatType.CGroup)
                                ? widget.conversationInfoModel.groupProfile
                                : getFrontUser().userProfile,
                        fit: BoxFit.fill,
                        width: ScreenUtil().setWidth(40),
                        height: ScreenUtil().setWidth(40),
                        errorWidget: (context, url, error) => Image.asset(
                            "assets/bg_image/profile-pic-dummy.png",
                            fit: BoxFit.fill)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(16)),
            child: Container(
              height: 1,
              color: purpleDimColor,
            ),
          )
        ]));
  }

  Widget messageListView() {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Obx(() => ListView.builder(
                controller: scrollController,
                reverse: true,
                shrinkWrap: true,
                restorationId: listVRefresher.value,
                itemCount: chatList.keys.length,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  String conversationDate = chatList.keys.toList()[index];
                  List<MessageInfoModel> msgList = chatList[conversationDate];

                  return Column(
                    children: [
                      sectionHeaderView(conversationDate),
                      ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          primary: false,
                          restorationId: listVRefresher.value,
                          itemCount: msgList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                if (msgList[index].isDeleted == true) {
                                  return;
                                }
                                _pressedOnMessage(msgList[index], index);
                              },
                              child:
                                  (msgList[index].msgType == MessageType.CText)
                                      ? textMessageInfoCardView(
                                          msgList[index], index)
                                      : (msgList[index].msgType ==
                                              MessageType.CImage)
                                          ? imgMessageInfoCardView(
                                              msgList[index], index)
                                          : videoMessageInfoCardView(
                                              msgList[index], index),
                            );
                          })
                    ],
                  );
                }))));
  }

  Widget sectionHeaderView(String conversationDate) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(dimen.paddingSmall+2),
        child: Text(
          conversationDate,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(12),
              fontFamily: MyFont.poppins_regular,
              color: whiteDimColor),
        ),
      ),
    );
  }

  Widget textMessageInfoCardView(MessageInfoModel msgInfo, int index) {
    return Stack(children: [
      Container(
        padding: EdgeInsets.only(
            left: (msgInfo.senderId != userModel.id)
                ? 10
                : ScreenUtil().setWidth(75),
            right: (msgInfo.senderId == userModel.id)
                ? 10
                : ScreenUtil().setWidth(75),
            top: 10,
            bottom: 10),
        child: Align(
          alignment: ((msgInfo.senderId != userModel.id)
              ? Alignment.topLeft
              : Alignment.topRight),
          child: Column(
              crossAxisAlignment: (msgInfo.senderId != userModel.id)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                senderUserNameView(msgInfo),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ((msgInfo.senderId != userModel.id)
                          ? colorRecevierChat
                          : colorSenderChat),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ((msgInfo.senderId != userModel.id) &&
                                  (msgInfo.isDeleted == true))
                              ? Messages.CDeleteForOther
                              : ((msgInfo.senderId == userModel.id) &&
                                      (msgInfo.isDeleted == true))
                                  ? Messages.CDeleteForSender
                                  : msgInfo.message,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(13),
                              fontFamily: (msgInfo.isDeleted == true)
                                  ? MyFont.Poppins_semibold
                                  : MyFont.poppins_regular,
                              color: Colors.white),
                        ),
                        msgTimeView(msgInfo.timestamp),
                      ],
                    )),
              ]),
        ),
      ),
      if (msgInfo.senderId != userModel.id) senderViewShapeImg(),
      if (msgInfo.senderId == userModel.id) receiverViewShapeImg(),
    ]);
  }

  Widget imgMessageInfoCardView(MessageInfoModel msgInfo, int index) {
    return Stack(children: [
      Container(
        padding: EdgeInsets.only(
            left: (msgInfo.senderId != userModel.id)
                ? 10
                : (screenWidth(context) - ScreenUtil().setWidth(250)),
            right: (msgInfo.senderId == userModel.id)
                ? 10
                : (screenWidth(context) - ScreenUtil().setWidth(250)),
            top: 10,
            bottom: 10),
        child: Align(
            alignment: ((msgInfo.senderId != userModel.id)
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Column(
              crossAxisAlignment: (msgInfo.senderId != userModel.id)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                senderUserNameView(msgInfo),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ((msgInfo.senderId != userModel.id)
                          ? colorRecevierChat
                          : colorSenderChat),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: (msgInfo.isLocal == true)
                                ? Image.file(
                                    File(msgInfo.message),
                                    fit: BoxFit.fill,
                                    width: ScreenUtil().setWidth(250),
                                  )
                                : CommonChatImage(
                                    msgInfo.message,
                                    ScreenUtil().setWidth(250),
                                  )),
                        msgTimeView(msgInfo.timestamp),
                      ],
                    )),
              ],
            )),
      ),
      if (msgInfo.senderId != userModel.id) senderViewShapeImg(),
      if (msgInfo.senderId == userModel.id) receiverViewShapeImg(),
    ]);
  }

  Widget videoMessageInfoCardView(MessageInfoModel msgInfo, int index) {
    return Stack(children: [
      Container(
        padding: EdgeInsets.only(
            left: (msgInfo.senderId != userModel.id)
                ? 10
                : (screenWidth(context) - ScreenUtil().setWidth(250)),
            right: (msgInfo.senderId == userModel.id)
                ? 10
                : (screenWidth(context) - ScreenUtil().setWidth(250)),
            top: 10,
            bottom: 10),
        child: Align(
            alignment: ((msgInfo.senderId != userModel.id)
                ? Alignment.topLeft
                : Alignment.topRight),
            child: Column(
              crossAxisAlignment: (msgInfo.senderId != userModel.id)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                senderUserNameView(msgInfo),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ((msgInfo.senderId != userModel.id)
                          ? colorRecevierChat
                          : colorSenderChat),
                    ),
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () {
                        _pressedOnVideoPlayBtn(msgInfo.message);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: (msgInfo.isLocal == true)
                                  ? Image.file(
                                      File(msgInfo.videoURL),
                                      fit: BoxFit.fill,
                                      width: ScreenUtil().setWidth(250),
                                      height: ScreenUtil().setHeight(200),
                                    )
                                  : CommonChatThumbnail(
                                      msgInfo.videoURL,
                                      ScreenUtil().setWidth(250),
                                      ScreenUtil().setHeight(200),
                                    )),
                          msgTimeView(msgInfo.timestamp),
                        ],
                      ),
                    )),
              ],
            )),
      ),
      if ((msgInfo.senderId != userModel.id) &&
          (msgInfo.msgType == MessageType.CVideo))
        Positioned(
            left: ScreenUtil().setWidth(250) / 2,
            top: ScreenUtil().setHeight(250) / 2,
            child: playImgButton()),
      if ((msgInfo.senderId == userModel.id) &&
          (msgInfo.msgType == MessageType.CVideo))
        Positioned(
            right: ScreenUtil().setWidth(250) / 2,
            top: ScreenUtil().setHeight(250) / 2,
            child: playImgButton()),
      if (msgInfo.senderId != userModel.id) senderViewShapeImg(),
      if (msgInfo.senderId == userModel.id) receiverViewShapeImg(),
    ]);
  }

  Widget playImgButton() {
    return Image(
      image: AssetImage(MyImage.ic_play),
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setWidth(30),
      color: Colors.white,
    );
  }

  Widget senderUserNameView(MessageInfoModel msgInfo) {
    return Text(
      (widget.conversationInfoModel != null &&
              widget.conversationInfoModel.chatType == ChatType.CGroup &&
              msgInfo.senderId != userModel.id)
          ? '~ ${getSenderUserName(msgInfo.users, msgInfo.senderId).userName}'
          : '',
      style: TextStyle(
          fontSize: ScreenUtil().setSp(10),
          fontFamily: MyFont.Poppins_semibold,
          color: Colors.white),
    );
  }

  Widget msgTimeView(int timestamp) {
    return SizedBox(
      width: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Image(
              image: AssetImage(MyImage.ic_clock),
              color: Colors.white,
              width: 10,
              height: 10,
            ),
          ),
          Text(
            getStringDateFromTimestamp(timestamp, 'hh:mm a'),
            style: TextStyle(
                fontSize: ScreenUtil().setSp(9),
                fontFamily: MyFont.poppins_regular,
                color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget senderViewShapeImg() {
    return Positioned(
      bottom: 0,
      left: 10,
      child: Image(
        image: AssetImage(MyImage.ic_sender),
      ),
    );
  }

  Widget receiverViewShapeImg() {
    return Positioned(
        bottom: 0,
        right: 10,
        child: Image(
          image: AssetImage(MyImage.ic_receiver),
        ));
  }

  Widget bottomView() {
    return Column(
      children: [
        Container(
          height: 1,
          color: purpleDimColor,
        ),
        Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(15.0),
              right: ScreenUtil().setWidth(15.0),
              bottom: ScreenUtil().setWidth(10.0),
              top: ScreenUtil().setHeight(15.0)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  _pressedOnCameraBtn();
                },
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset(MyImage.ic_camera_chat)),
              ),
              Expanded(
                child: Container(
                  child: TextField(
                    controller: txtMsgController,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: 3,
                    minLines: 1,
                    maxLength: 250,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(14),
                        fontFamily: MyFont.poppins_regular,
                        color: colorChatText),
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: "",
                      hintText: Messages.CTypeAMessage,
                      hintStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(14),
                          fontFamily: MyFont.poppins_regular,
                          color: colorChatText),
                      fillColor: colorGray,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _pressedOnAttachmentBtn();
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SvgPicture.asset(MyImage.ic_attachment),
                ),
              ),
              InkWell(
                onTap: () {
                  _pressedOnSendMessageBtn();
                },
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset(MyImage.ic_send)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future getThumbNail(String videoURL) async {
    var fileName = await VideoThumbnail.thumbnailFile(
      video: videoURL,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxWidth: ScreenUtil().setWidth(250).toInt(),
      maxHeight: ScreenUtil().setHeight(200).toInt(),
      quality: 75,
    );
    return fileName;
  }

  _pressedOnCameraBtn() {
    _pickOrClickPhoto(ImageSource.camera);
  }

  _pressedOnAttachmentBtn() {
    showModalBottomSheet(
        context: context,
        backgroundColor: roundedcontainer,
        builder: (context) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)),
                  color: roundedcontainer),
              child: Wrap(
                children: [
                  ListTile(
                      title: Center(
                        child: Text(LabelStr.lblChoosePhoeo,
                            style: TextStyle(
                                fontFamily: MyFont.poppins_regular,
                                fontSize: ScreenUtil().setSp(14),
                                color: Colors.white)),
                      ),
                      onTap: () {
                        _pickOrClickPhoto(ImageSource.gallery);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                      title: Center(
                        child: Text(LabelStr.lblChooseVideo,
                            style: TextStyle(
                                fontFamily: MyFont.poppins_regular,
                                fontSize: ScreenUtil().setSp(14),
                                color: Colors.white)),
                      ),
                      onTap: () {
                        _pickVideoFromGallery();
                        Navigator.of(context).pop();
                      })
                ],
              ),
            ),
          );
        });
  }

  _pressedOnSendMessageBtn() {
    if (txtMsgController.text.isEmpty) {
      return;
    }
    _sendMsgOnFirestore(MessageType.CText);
  }

  _pressedOnVideoPlayBtn(String videoURL) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoURL),
            fullscreenDialog: true));
  }

  _pressedOnMessage(MessageInfoModel messageInfoModel, int index) {
    showModalBottomSheet(
        context: context,
        backgroundColor: screenBgColor,
        builder: (context) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)),
                  color: roundedcontainer),
              child: Wrap(
                children: [
                  ListTile(
                      title: Center(
                          child: Text(LabelStr.lblDeleteFromMe,
                              style: TextStyle(
                                  fontFamily: MyFont.poppins_regular,
                                  fontSize: ScreenUtil().setSp(14),
                                  color: Colors.white))),
                      onTap: () {
                        _pressedOnDeleteMsg(
                            messageInfoModel, DeleteType.CDeleteForMe, index);
                      }),
                  if (messageInfoModel.senderId == userModel.id)
                    ListTile(
                        title: Center(
                            child: Text(LabelStr.lblDeleteForEveryone,
                                style: TextStyle(
                                    fontFamily: MyFont.poppins_regular,
                                    fontSize: ScreenUtil().setSp(14),
                                    color: Colors.white))),
                        onTap: () {
                          _pressedOnDeleteMsg(messageInfoModel,
                              DeleteType.CDeleteForEveryOne, index);
                        }),
                ],
              ),
            ),
          );
        });
  }

  _pickOrClickPhoto(ImageSource source) async {
    final pickedImg = await ImagePicker()
        // ignore: deprecated_member_use
        .getImage(source: source, imageQuality: 75);

    addAttachmentToLocal(MessageType.CImage, File(pickedImg.path));

    return FirestoreService().uploadFile(
        File(pickedImg.path), MessageType.CImage, (attachmentURL, error) {
      _sendMsgOnFirestore(MessageType.CImage, imgURL: attachmentURL);
    });
  }

  _pickVideoFromGallery() async {
    final pickedVideo = await ImagePicker()
        // ignore: deprecated_member_use
        .getVideo(source: ImageSource.gallery);

    if (isTooLargeFile(File(pickedVideo.path))) {
      var thumbnailURL = await VideoThumbnail.thumbnailFile(
        video: pickedVideo.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.WEBP,
        quality: 75,
      );

      addAttachmentToLocal(MessageType.CVideo, File(pickedVideo.path),
          thumbnail: thumbnailURL);

      return FirestoreService().uploadVideoFile(File(pickedVideo.path),
          (response, error) {
        _sendMsgOnFirestore(MessageType.CVideo,
            imgURL: response['videoURL'], thumbnail: response['thumbnail']);
      });
    } else {
      AlertView().showAlert(Messages.CFileSizeLimit, context);
    }
  }

  Map<String, dynamic> addAttachmentToLocal(int msgType, File attachment,
      {String thumbnail = ''}) {
    var msgTime = DateTime.now().toUtc().millisecondsSinceEpoch;
    var msgText = attachment.path;

    var msgInfoModel = MessageInfoModel(
        message: msgText,
        timestamp: msgTime,
        videoURL: thumbnail,
        msgType: msgType,
        senderId: userModel.id,
        users: [
          MessageUserInfoModel(
              userId: userModel.id,
              userName: userModel.username,
              userProfile: userModel.image)
        ],
        isLocal: true);

    var key = getConversationDate(msgTime);
    List<MessageInfoModel> updatedChatList = [];

    if (chatList != null) {
      if (chatList.containsKey(key)) {
        updatedChatList = chatList[key];
        updatedChatList.insert(0, msgInfoModel);
        chatList.addAll({key: updatedChatList});
      }
    } else {
      updatedChatList.add(msgInfoModel);
      chatList = (groupBy<MessageInfoModel, String>(updatedChatList, (msgInfo) {
        return getConversationDate(msgInfo.timestamp);
      }));
    }
    strLastUploadedMedia = msgText;
    strLastVideoThumbnail = thumbnail;
    listVRefresher.value = Utilities.getRandomString();
  }

  _pressedOnBack() {
    setInfoForManagePushNotification(false);
    if (widget.msgID.isNotEmpty)
      FirestoreService().resetUnreadMsgCount(widget.msgID);
    Get.back(result: widget.msgID);
  }

  _pressedOnDeleteMsg(
      MessageInfoModel messageInfoModel, int deleteType, int index) {
    Navigator.of(context).pop();

    Map<String, dynamic> updatedMsg = messageInfoModel.toMap();

    var deletedBy = [userModel.id];
    if (deleteType == DeleteType.CDeleteForMe) {
      if (messageInfoModel.deletedFor.length > 0) {
        deletedBy.add(messageInfoModel.deletedFor.first);
      }
      updatedMsg[Parameters.CDeletedFor] = deletedBy;
    } else {
      updatedMsg[Parameters.CIsDeleted] = true;
      updatedMsg[Parameters.CTypeMesage] = MessageType.CText;
    }

    FirestoreService()
        .deleteMsgForMe(widget.msgID, messageInfoModel.msgId, updatedMsg, () {
      //...Update Conversation List Collection for delete message If user delete last message
      if (index == 0) {
        FirestoreService().getConversationDetail(widget.msgID,
            (response, error) {
          DocumentSnapshot snapshot = response;
          Map<String, dynamic> data = snapshot.data();

          if (deleteType == DeleteType.CDeleteForEveryOne) {
            data[Parameters.CIsDeleted] = true;
          } else {
            data[Parameters.CDeletedFor] = deletedBy;
          }

          FirestoreService().updateMsgInfoInConversationListCollection(
              widget.msgID, data, () {});
        });
      }
    });
  }

  _sendMsgOnFirestore(int msgType,
      {String imgURL = '', String thumbnail = ''}) {
    var msgTime = DateTime.now().toUtc().millisecondsSinceEpoch;
    var msgText =
        (msgType == MessageType.CText) ? txtMsgController.text : imgURL;

    Map<String, dynamic> senderUserInfo = {
      Parameters.CUserId: userModel.id,
      Parameters.CuserName: userModel.username,
      Parameters.CUserProfile: userModel.image,
      Parameters.CFirstName: userModel.firstname,
      Parameters.CLastName: userModel.lastname,
    };

    var usersList = [];
    if (widget.conversationInfoModel == null) {
      usersList = [widget.receiverUserInfo, senderUserInfo];
    } else {
      usersList = widget.conversationInfoModel.users.map((user) {
        return {
          Parameters.CUserId: user.userId,
          Parameters.CuserName: user.userName,
          Parameters.CUserProfile: user.userProfile,
          Parameters.CFirstName: user.firstName,
          Parameters.CLastName: user.lastName,
        };
      }).toList();
    }

    Map<String, dynamic> msgInfo = {
      Parameters.CUsers: usersList,
      Parameters.CMessage: msgText,
      Parameters.CTypeMesage: msgType,
      Parameters.CTimestamp: msgTime,
      Parameters.CSenderID: userModel.id,
      Parameters.CIsDeleted: false
    };

    if (msgType == MessageType.CVideo) {
      msgInfo[Parameters.CVideoURL] = thumbnail;
    }

    msgInfo[Parameters.CChatType] = (widget.conversationInfoModel == null)
        ? ChatType.COTO
        : widget.conversationInfoModel.chatType;

    txtMsgController.text = '';
    FocusScope.of(context).requestFocus(FocusNode());

    FirestoreService().storeMsgInfoInConversationDetailCollection(
        msgInfo, widget.msgID, (documentID, error) {
      var isIntialChat = widget.msgID.isEmpty;
      widget.msgID = documentID;
      setInfoForManagePushNotification(true);
      if (isIntialChat) _getMessageSnapShot();
      setState(() {});
      updateLastMsgInfoInFirestore(documentID, msgInfo, isIntialChat);
    });
  }

  updateLastMsgInfoInFirestore(
      String documentID, Map<String, dynamic> msgInfo, bool isIntialChat) {
    var updatedMsgInfo = msgInfo;

    //...Get latest conversation Info from fire store
    FirestoreService().getConversationDetail(documentID, (response, error) {
      DocumentSnapshot snapshot = response;
      Map<String, dynamic> data = snapshot.data();

      if (data != null) {
        widget.conversationInfoModel = ConversationInfoModel.fromJson(snapshot);
        updatedMsgInfo[Parameters.CGroupName] =
            widget.conversationInfoModel.groupName;
        updatedMsgInfo[Parameters.CGroupProfile] =
            widget.conversationInfoModel.groupProfile;
      }

      //...Update conversation info for unread count for all users
      var updatedUnreadCount = [];
      if (isIntialChat) {
        //... will be set unread count 1 for first message for receiver user(OTO chat)
        updatedUnreadCount = [
          {
            Parameters.CUserId: widget.receiverUserInfo[Parameters.CUserId],
            Parameters.CCount: 1
          },
          {Parameters.CUserId: userModel.id, Parameters.CCount: 0}
        ];

        updatedMsgInfo[Parameters.CUsersID] = [
          userModel.id,
          widget.receiverUserInfo[Parameters.CUserId]
        ];
      } else {
        //... Removed login user ID from unreadCount Users List
        List<dynamic> users = widget.conversationInfoModel.unreadCount;
        users.removeWhere((user) => user == userModel.id);
        widget.conversationInfoModel.unreadCount.forEach((user) {
          var updatedUser = user;
          if (user[Parameters.CUserId] != userModel.id)
            //... Checked it's first message of group, If Yes then set count 1 for all group member expect of login user Otherwise Updated count by +1 for receiver user
            updatedUser[Parameters.CCount] =
                (widget.conversationInfoModel.message.isEmpty)
                    ? 1
                    : updatedUser[Parameters.CCount] + 1;
          updatedUnreadCount.add(updatedUser);
        });

        updatedMsgInfo[Parameters.CUsersID] =
            widget.conversationInfoModel.usersId;
      }

      updatedMsgInfo[Parameters.CConversationId] = documentID;
      updatedMsgInfo[Parameters.CUnreadCount] = updatedUnreadCount;
      updatedMsgInfo[Parameters.CDeletedFor] = [];
      updatedMsgInfo.remove(Parameters.CUnreadUsers);

      FirestoreService().updateMsgInfoInConversationListCollection(
          documentID, updatedMsgInfo, () {
        fcmTokens.forEach((token) {
          FirestoreService()
              .sendChatMessageFCM(updatedMsgInfo, documentID, token);
        });
      });
    });
  }

  MessageUserInfoModel getFrontUser() {
    var user = widget.conversationInfoModel.users
        .where((data) => data.userId != userModel.id);
    return user.first;
  }

  MessageUserInfoModel getSenderUserName(
      List<MessageUserInfoModel> users, int senderID) {
    var user = users.where((data) => data.userId == senderID);
    return user.first;
  }

  setInfoForManagePushNotification(bool isChatDetail) {
    rq.isChatDetailOpen = isChatDetail;
    if (widget.msgID.isNotEmpty) rq.conversationID = widget.msgID;
  }
}
