
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/CommonStuff.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/ConversationDetailModel.dart';
import 'package:totem_app/Models/ConversationListModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Chat/ChatDetailScreen.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class SearchChatListScreen extends StatefulWidget {
  List<ConversationInfoModel> conversationList;

  SearchChatListScreen(this.conversationList);

  @override
  _SearchChatListScreenState createState() => _SearchChatListScreenState();
}

class _SearchChatListScreenState extends State<SearchChatListScreen> {
  List<ConversationInfoModel> filteredList = [];
  List<ConversationInfoModel> frdList = [];
  var txtSearchController = TextEditingController();
  var listVRefresher = ''.obs;

  var onLoadMore = true;
  var dataOver = false;
  var listVOnlineUsersRefresher = "".obs;
  static const int perPage = 10;
  ScrollController scrollController = ScrollController();
  var isLoadedData = false.obs;

  void initState() {
    super.initState();
    filteredList = widget.conversationList;
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
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor, body: searchChatListView());
  }

  Widget searchChatListView() {
    return SafeArea(
      child: Column(
        children: [appBarView(), messageListView()],
      ),
    );
  }

  Widget appBarView() {
    return Column(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Get.back();
            },
            child: Padding(
              padding: EdgeInsets.all(15),
              child: SvgPicture.asset(MyImage.ic_cross),
            ),
          ),
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
        child: TextField(
          controller: txtSearchController,
          style: TextStyle(
              color: colorHintText,
              fontFamily: MyFont.poppins_regular,
              fontSize: ScreenUtil().setSp(14)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(5, 7, 5, 5),
            border: InputBorder.none,
            hintText: LabelStr.lblSearchName,
            hintStyle: TextStyle(
                color: colorHintText,
                fontFamily: MyFont.poppins_regular,
                fontSize: ScreenUtil().setSp(14)),
            prefixIcon: Container(
              padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
              child: IconTheme(
                data: IconThemeData(color: Color.fromRGBO(187, 182, 211, 1)),
                child: Icon(Icons.search),
              ),
            ),
          ),
          onChanged: (searchTxt) {
            _searchByUserName();

            if (searchTxt.length >= 3) {
              LogicalComponents.suggestedUsersModel.pageNumber = 0;
              _callGetFollowerUsersApi();
            } else {
              _searchByUserName();
            }

            if (searchTxt.length == 0) {
              frdList.clear();
              LogicalComponents.suggestedUsersModel.pageNumber = 0;
              LogicalComponents.suggestedUsersModel.totalRecords = 0;
              onLoadMore = false;
              dataOver = true;
            }
          },
          // onChanged: _searchByUserName(),
        ),
      ),
    );
  }

  Widget messageListView() {
    return Obx(() => Expanded(
          child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filteredList.length,
              restorationId: listVRefresher.value,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    _pressedOnChatListInfo(filteredList[index]);
                  },
                  child: messageInfoCardView(filteredList[index]),
                );
              }),
        ));
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
                CommonNetworkImage(
                  imageUrl: (conversationInfoModel.chatType == ChatType.CGroup)
                      ? conversationInfoModel.groupProfile
                      : getFrontUser(conversationInfoModel.users).userProfile,
                  height: 60,
                  width: 60,
                  radius: 30,
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
                      (conversationInfoModel.msgType == null)
                          ? ''
                          : (conversationInfoModel.msgType == MessageType.CText)
                              ? conversationInfoModel.message
                              : (conversationInfoModel.msgType ==
                                      MessageType.CImage)
                                  ? LabelStr.CImage
                                  : LabelStr.CVideo,
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
                (conversationInfoModel.timestamp == null)
                    ? ''
                    : getTimeForConversationList(
                        conversationInfoModel.timestamp),
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

  _pressedOnChatListInfo(ConversationInfoModel conversationInfoModel) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
                  (conversationInfoModel.conversationId == null)
                      ? ''
                      : conversationInfoModel.conversationId,
                  getFrontUser(conversationInfoModel.users).toMap(),
                )));
  }

  _callGetFollowerUsersApi() {
    LogicalComponents.suggestedUsersModel.pageNumber++;
    var body = {
      Parameters.CpageNumber: LogicalComponents.suggestedUsersModel.pageNumber,
      Parameters.CpageSize: LogicalComponents.suggestedUsersModel.pageSize,
      Parameters.Csearch: txtSearchController.text.toLowerCase(),
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
            frdList.clear();
          }
          if (LogicalComponents.suggestedUsersModel.data != null &&
              LogicalComponents.suggestedUsersModel.data.isNotEmpty) {
            var frdUserList = [];

            if (filteredList.length > 0) {
              LogicalComponents.suggestedUsersModel.data.forEach((user) {
                filteredList.forEach((conversationUser) {
                  if (user.id != getFrontUser(conversationUser.users).userId) {
                    frdUserList.add(user);
                  }
                });
              });
            } else {
              frdUserList = LogicalComponents.suggestedUsersModel.data;
            }

            if (frdUserList.length > 0) {
              UserInfoModel userModel =
                  (SessionImpl.getLoginProfileModel() as UserInfoModel);
              List<ConversationInfoModel> updatedFrdList = [];
              frdUserList.forEach((user) {
                var users = [
                  MessageUserInfoModel(
                      userId: userModel.id,
                      firstName: userModel.firstname,
                      lastName: userModel.lastname,
                      userName: userModel.username,
                      userProfile: userModel.image),
                  MessageUserInfoModel(
                      userId: user.id,
                      firstName: user.firstname,
                      lastName: user.lastname,
                      userName: user.username,
                      userProfile: user.image),
                ];

                var usersID = [userModel.id, user.id];

                updatedFrdList.add(ConversationInfoModel(
                    message: '',
                    timestamp: null,
                    videoURL: null,
                    msgType: null,
                    users: users,
                    usersId: usersID,
                    senderId: null,
                    conversationId: null,
                    unreadCount: [],
                    chatType: null,
                    groupName: null,
                    groupProfile: null,
                    isDeleted: false));
              });

              frdList.addAll(updatedFrdList);

              if (txtSearchController.text.length > 0) {
                filteredList.addAll(frdList);
              }
            }

            listVRefresher.value = Utilities.getRandomString();
            isLoadedData.value = true;
            print(listVRefresher.value + " " + frdList.length.toString());
          }
        },
        onFailure: (error) {
          isLoadedData.value = true;
          onLoadMore = false;
          if (LogicalComponents.suggestedUsersModel.pageNumber == 1) {
            dataOver = true;
            frdList.clear();
            listVRefresher.value = Utilities.getRandomString();
          }
        });
  }

  _searchByUserName() {
    List<ConversationInfoModel> resultList = [];

    widget.conversationList.forEach((conversationInfo) {
      if (conversationInfo.chatType == ChatType.CGroup) {
        //... Add search result by group name
        if (conversationInfo.groupName
            .toLowerCase()
            .contains(txtSearchController.text.toLowerCase())) {
          resultList.add(conversationInfo);
        }
      } else {
        //... Add search result by user name
        conversationInfo.users.forEach((user) {
          if ((user.userName
                  .toLowerCase()
                  .contains(txtSearchController.text.toLowerCase())) ||
              (user.firstName
                  .toLowerCase()
                  .contains(txtSearchController.text.toLowerCase())) ||
              (user.lastName
                  .toLowerCase()
                  .contains(txtSearchController.text.toLowerCase())) ||
              ('${user.firstName} ${user.lastName}'
                  .toLowerCase()
                  .contains(txtSearchController.text.toLowerCase()))) {
            if (user.userId != SessionImpl.getId()) {
              resultList.add(conversationInfo);
            }
          }
        });
      }
    });

    filteredList = resultList;
    listVRefresher.value = Utilities.getRandomString();
  }

  MessageUserInfoModel getFrontUser(List<MessageUserInfoModel> users) {
    var user = users.where((data) => data.userId != SessionImpl.getId());
    return user.first;
  }

  String getUnreadCount(List<dynamic> unreadCount) {
    if (unreadCount.length == 0) {
      return '0';
    }

    var user = unreadCount
        .where((user) => user[Parameters.CUserId] == SessionImpl.getId());
    return '${user.first[Parameters.CCount]}';
  }
}
