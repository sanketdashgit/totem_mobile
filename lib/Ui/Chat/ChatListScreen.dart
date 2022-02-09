
import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/CommonStuff.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FirestoreService.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/ConversationDetailModel.dart';
import 'package:totem_app/Models/ConversationListModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Chat/GroupChatListScreen.dart';
import 'package:totem_app/Ui/Chat/SearchChatListScreen.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'ChatDetailScreen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<SuggestedUser> onlineUsersList = [];
  var onLoadMore = true;
  var dataOver = false;
  var listVOnlineUsersRefresher = "".obs;
  static const int perPage = 10;
  ScrollController scrollController = ScrollController();
  var isLoadedData = false.obs;

  UserInfoModel userModel =
      (SessionImpl.getLoginProfileModel() as UserInfoModel);

  List<ConversationInfoModel> conversationList = [];

  Timer _timer;

  @override
  initState() {
    super.initState();

    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.pageSize = perPage;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;

    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        if (!onLoadMore) {
          onLoadMore = true;
          if (!dataOver) {
            _callGetFollowerUsersApi();
          }
        }
      } else {
        onLoadMore = false;
      }
    });

    startTimer();
  }


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    if(_timer != null)
      _timer.cancel();

    _timer = new Timer.periodic(
      Duration(seconds: 10),
          (Timer timer) {
            _callGetFollowerUsersApi();
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor,
        body: VisibilityDetector(
          key: Key("chat_list"),
          onVisibilityChanged: (VisibilityInfo info) {
            debugPrint(
                "visibility : ${info.visibleFraction} of my widget is visible");
            if (info.visibleFraction == 1) {
              _callGetFollowerUsersApi();
            }
          },
          child: chatListView(),
        ));
  }

  Widget chatListView() {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(50)),
      child: Column(
        children: [
          appBarView(),
          onlineUserView(),
          messageListStreamBuilder(),
        ],
      ),
    );
  }

  Widget appBarView() {
    return Column(children: [
      Row(
        children: [
          InkWell(
            onTap: () {
              Get.back();
            },
            child: Container(
                padding: EdgeInsets.all(dimen.paddingForBackArrow),
                margin: EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  color: Colors.white,
                )),
          ),

          // ),
          Expanded(
              child: Center(
            child: Text(
              LabelStr.lblMessage,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: MyFont.Poppins_semibold,
                  color: Colors.white),
            ),
          )),
          Padding(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(20)),
            child: InkWell(
              onTap: () {
                Get.to(GroupChatListScreen());
              },
              child: SvgPicture.asset(MyImage.ic_group),
            ),
          )
        ],
      ),
      searchTxtFieldView(),
      Container(
        height: 1,
        color: purpleDimColor,
      )
    ]);
  }

  Widget searchTxtFieldView() {
    return Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(20),
          right: ScreenUtil().setWidth(20),
          top: ScreenUtil().setHeight(20),
          bottom: ScreenUtil().setHeight(15)),
      child: Container(
          height: ScreenUtil().setHeight(40),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: colorGray),
          child: InkWell(
            onTap: () {
              _pressedOnSearchField();
            },
            child: Padding(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
              child: Row(
                children: [
                  IconTheme(
                    data:
                        IconThemeData(color: whiteDimColor),
                    child: Icon(Icons.search),
                  ),
                  Text(
                    LabelStr.lblSearchName,
                    style: TextStyle(
                        color: colorHintText,
                        fontFamily: MyFont.poppins_regular,
                        fontSize: ScreenUtil().setSp(14)),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget onlineUserView() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(15),
                  left: ScreenUtil().setWidth(20),
                  bottom: ScreenUtil().setHeight(9)),
              child: Text(
                LabelStr.lblOnlineFriends,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(14),
                    fontFamily: MyFont.Poppins_semibold,
                    color: Colors.white),
              ),
            ),
            if (!isLoadedData.value)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            if (isLoadedData.value && onlineUsersList.length > 0)
              onlineUserListView(),
            if (isLoadedData.value && onlineUsersList.length == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    LabelStr.CNotFound,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(11),
                        fontFamily: MyFont.poppins_regular,
                        color: Colors.white),
                  ),
                ),
              ),
            Container(
              height: ScreenUtil().setHeight(10),
              color: colorGray,
            )
          ],
        ));
  }

  Widget onlineUserListView() {
    return SizedBox(
      height: ScreenUtil().setWidth(110), //+16+8+10,
      width: screenWidth(context),
      child: Obx(() => GridView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          restorationId: listVOnlineUsersRefresher.value,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: ScreenUtil().setWidth(80),
            maxCrossAxisExtent: ScreenUtil().setWidth(105),
            crossAxisSpacing: 10,
          ),
          itemCount: onlineUsersList.length,
          padding: EdgeInsets.only(left: 10, right: 10),
          controller: scrollController,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                _pressedOnOnlineUser(onlineUsersList[index]);
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: onlineUserCardView(onlineUsersList[index]),
            );
          })),
    );
  }

  Widget onlineUserCardView(SuggestedUser userInfo) {
    return Container(
      margin: EdgeInsets.only(
          left: ScreenUtil().setWidth(5), right: ScreenUtil().setWidth(5)),
      child: Column(children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(65)),
              child: Container(
                height: ScreenUtil().setWidth(65),
                width: ScreenUtil().setWidth(65),
                color: Colors.grey.shade300,
                child: CachedNetworkImage(
                    imageUrl: userInfo.image,
                    fit: BoxFit.fill,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Image.asset(
                            "assets/bg_image/profile-pic-dummy.png",
                            fit: BoxFit.fill),
                    errorWidget: (context, url, error) => Image.asset(
                        "assets/bg_image/profile-pic-dummy.png",
                        fit: BoxFit.fill)),
              ),
            ),
            onlineStatusView(userInfo.presentLiveStatus == 1)
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 8, bottom: 15),
          child: Text(
            userInfo.username,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(11),
                fontFamily: MyFont.poppins_regular,
                color: blueWhiteColor),
          ),
        )
      ]),
    );
  }

  Widget onlineStatusView(bool isOnline) {
    return Positioned(
        bottom: 0,
        right: 1,
        child: Container(
          width: ScreenUtil().setWidth(15),
          height: ScreenUtil().setWidth(15),
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(ScreenUtil().setWidth(15) / 2),
              border: Border.all(color: Colors.white, width: 2),
              color:
                  isOnline ? greenHoloColor : Colors.grey),
        ));
  }

  Widget messageListStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(Collections.Conversation)
            .where(Parameters.CUsersID, arrayContains: userModel.id)
            .orderBy(Parameters.CTimestamp, descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center();
          }
          if (snapshot.hasData) {
            if (snapshot.data.docs.length > 0) {
              conversationList =
                  ConversationListModel.fromJson(snapshot.requireData.docs)
                      .conversationList;

              return messageListView();
            } else {
              return Center();
            }
          } else {
            return Center();
          }
        });
  }

  Widget messageListView() {
    return Expanded(
      child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: conversationList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                _pressedOnChatListInfo(conversationList[index]);
              },
              child: messageInfoCardView(conversationList[index]),
            );
          }),
    );
  }

  Widget messageInfoCardView(ConversationInfoModel conversationInfoModel) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(20),
        top: ScreenUtil().setHeight(15),
        right: ScreenUtil().setWidth(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(65) / 2),
                  child: CachedNetworkImage(
                      imageUrl:
                          (conversationInfoModel.chatType == ChatType.CGroup)
                              ? conversationInfoModel.groupProfile
                              : getFrontUser(conversationInfoModel.users)
                                  .userProfile,
                      fit: BoxFit.fill,
                      width: ScreenUtil().setWidth(65),
                      height: ScreenUtil().setWidth(65),
                      errorWidget: (context, url, error) => Image.asset(
                          "assets/bg_image/profile-pic-dummy.png",
                          fit: BoxFit.fill)),
                ),
                if (getUnreadCount(conversationInfoModel.unreadCount) != "0")
                  Positioned(
                      bottom: 0,
                      right: 1,
                      child: Container(
                        width: ScreenUtil().setWidth(20),
                        height: ScreenUtil().setWidth(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                ScreenUtil().setWidth(20) / 2),
                            border: Border.all(color: Colors.white, width: 2),
                            color: redHoloColor),
                        child: Text(
                          getUnreadCount(conversationInfoModel.unreadCount),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(10),
                              fontFamily: MyFont.poppins_regular,
                              color: Colors.white),
                        ),
                      )),
              ]),
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(17),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (conversationInfoModel.chatType == ChatType.CGroup)
                          ? conversationInfoModel.groupName
                          : getFrontUser(conversationInfoModel.users).userName,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(14),
                          fontFamily: MyFont.Poppins_semibold,
                          color: Colors.white),
                    ),
                    Text(
                      getChatMessage(conversationInfoModel),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          fontFamily: MyFont.poppins_regular,
                          color: colorChatText),
                    ),
                  ],
                ),
              )),
              Text(
                getTimeForConversationList(conversationInfoModel.timestamp),
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(10),
                    fontFamily: MyFont.Poppins_semibold,
                    color: colorChatText),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
            child: Container(
              height: 1,
              color: purpleDimColor,
            ),
          )
        ],
      ),
    );
  }

  _callGetFollowerUsersApi() {
    var body = {
      Parameters.CpageNumber: 1,
      Parameters.CpageSize: 1000,
      Parameters.Csearch: "",
      Parameters.CtotalRecords:
          LogicalComponents.suggestedUsersModel.totalRecords,
      Parameters.Cid: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.getAllfollower,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          onLoadMore = false;
          LogicalComponents.suggestedUsersModel =
              SuggestedUsersModel.fromJson(response);
          //check data is over
          if ((LogicalComponents.suggestedUsersModel.pageNumber *
                  LogicalComponents.suggestedUsersModel.pageSize) <
              LogicalComponents.suggestedUsersModel.totalRecords) {
            dataOver = false;
          } else {
            dataOver = true;
          }
          if (LogicalComponents.suggestedUsersModel.pageNumber == 1) {
            onlineUsersList.clear();
          }
          if (LogicalComponents.suggestedUsersModel.data != null &&
              LogicalComponents.suggestedUsersModel.data.isNotEmpty) {
            var onlineUsers = LogicalComponents.suggestedUsersModel.data
                .where((user) => user.presentLiveStatus == 1)
                .toList();
            onlineUsersList.addAll(onlineUsers);
            listVOnlineUsersRefresher.value = Utilities.getRandomString();
            isLoadedData.value = true;
            print(listVOnlineUsersRefresher.value +
                " " +
                onlineUsersList.length.toString());
          }
        },
        onFailure: (error) {
          isLoadedData.value = true;
          onLoadMore = false;
          if (LogicalComponents.suggestedUsersModel.pageNumber == 1) {
            dataOver = true;
            onlineUsersList.clear();
            listVOnlineUsersRefresher.value = Utilities.getRandomString();
          }
        });
  }

  String getChatMessage(ConversationInfoModel conversationInfoModel) {
    if (conversationInfoModel.isDeleted) {
      return (conversationInfoModel.senderId == userModel.id)
          ? Messages.CDeleteForSender
          : Messages.CDeleteForOther;
    } else {
      return (conversationInfoModel.deletedFor.contains(SessionImpl.getId()))
          ? Messages.CDeleteForSender
          : (conversationInfoModel.msgType == MessageType.CText)
              ? conversationInfoModel.message
              : (conversationInfoModel.msgType == MessageType.CImage)
                  ? LabelStr.CImage
                  : LabelStr.CVideo;
    }
  }

  String getUnreadCount(List<dynamic> unreadCount) {
    var user =
        unreadCount.where((user) => user[Parameters.CUserId] == userModel.id);
    return '${user.first[Parameters.CCount]}';
  }

  _pressedOnSearchField() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchChatListScreen(conversationList),
            fullscreenDialog: true));
  }

  _pressedOnChatListInfo(ConversationInfoModel conversationInfoModel) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
                  conversationInfoModel.conversationId,
                  getFrontUser(conversationInfoModel.users).toMap(),
                  conversationInfoModel: conversationInfoModel,
                )));
  }

  _pressedOnOnlineUser(SuggestedUser user) {
    FirestoreService().checkConversationIDExistOrNot(user.id,
        (snapshot, error) {
      var conversationID = '';
      conversationID = snapshot;
      Get.to(ChatDetailScreen(conversationID, {
        Parameters.CUserId: user.id,
        Parameters.CuserName: user.username,
        Parameters.CUserProfile: user.image,
        Parameters.CFirstName: user.firstname,
        Parameters.CLastName: user.lastname
      }));
    });
  }
}
