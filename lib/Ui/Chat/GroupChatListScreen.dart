
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Alertview.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Ui/Chat/CreateChatGroupScreen.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class GroupChatListScreen extends StatefulWidget {
  @override
  _GroupChatListScreenState createState() => _GroupChatListScreenState();
}

class _GroupChatListScreenState extends State<GroupChatListScreen> {
  List<SuggestedUser> followerList = [];
  var txtSearchController = TextEditingController();
  var onLoadMore = true;
  var dataOver = false;
  var widgetRefresher = "".obs;
  static const int perPage = 10;
  ScrollController scrollController = ScrollController();
  String _searchText = '';
  List<SuggestedUser> selectedGroupMember = [];
  List<int> selectedGroupMemberIds = [];

  Map<String, dynamic> groupInfo;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.pageSize = perPage;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;
    _searchText = '';
    _callGetFollowerUsersApi();

    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        if (!onLoadMore) {
          onLoadMore = true;
          //call api
          if (!dataOver) {
            _callGetFollowerUsersApi();
          }
        }
      } else {
        onLoadMore = false;
      }
    });
  }

  _callGetFollowerUsersApi() {
    LogicalComponents.suggestedUsersModel.pageNumber++;
    var body = {
      Parameters.CpageNumber: LogicalComponents.suggestedUsersModel.pageNumber,
      Parameters.CpageSize: LogicalComponents.suggestedUsersModel.pageSize,
      Parameters.Csearch: _searchText,
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
            followerList.clear();
          }
          if (LogicalComponents.suggestedUsersModel.data != null &&
              LogicalComponents.suggestedUsersModel.data.isNotEmpty) {
            followerList.addAll(LogicalComponents.suggestedUsersModel.data);
            widgetRefresher.value = Utilities.getRandomString();
            print(widgetRefresher.value + " " + followerList.length.toString());
          }
        },
        onFailure: (error) {
          onLoadMore = false;
          if (LogicalComponents.suggestedUsersModel.pageNumber == 1) {
            dataOver = true;
            followerList.clear();
            widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  resetSearch() {
    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;
    _callGetFollowerUsersApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor, body: groupListView());
  }

  Widget groupListView() {
    return SafeArea(
      child: Column(
        children: [
          Column(children: [
            appBarView(),
            searchTxtFieldView(),
          ]),
          groupChatListView()
        ],
      ),
    );
  }

  Widget appBarView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Get.back();
          },
          child: Padding(
              padding: EdgeInsets.all(15),
              child: Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.white,
              )),
        ),
        Padding(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(40)),
          child: Text(
            LabelStr.lblGroupChat,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontFamily: MyFont.Poppins_semibold,
                color: Colors.white),
          ),
        ),
        Flexible(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
            child: SizedBox(
              width: ScreenUtil().setWidth(70),
              height: ScreenUtil().setHeight(40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(82, 81, 112, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: Text(
                  LabelStr.lblStart,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(14),
                      fontFamily: MyFont.poppins_regular,
                      color: Colors.white),
                ),
                onPressed: () {
                  Get.to(CreateChatGroupScreen(
                    groupMemberList: selectedGroupMember,
                    groupInfo: groupInfo,
                    groupMembersIds: selectedGroupMemberIds,
                  )).then((value) {
                    selectedGroupMember = value['groupMemberList'];
                    groupInfo = value['groupInfo'];
                    selectedGroupMemberIds = value['groupMemberIds'];
                    widgetRefresher.value = Utilities.getRandomString();
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget searchTxtFieldView() {
    return Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(20),
          right: ScreenUtil().setWidth(20),
          top: ScreenUtil().setHeight(20),
          bottom: ScreenUtil().setHeight(15)),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: colorGray),
        child: TextField(
          controller: txtSearchController,
          style: TextStyle(
              color: colorHintText,
              fontFamily: MyFont.poppins_regular,
              fontSize: ScreenUtil().setSp(14)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(5),
            border: InputBorder.none,
            hintText: LabelStr.lblGroupName,
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
          onChanged: (searchText) {
            _onChangedSearchGroup();
          },
        ),
      ),
    );
  }

  Widget groupChatListView() {
    return Expanded(
      child: Obx(() => ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.zero,
          restorationId: widgetRefresher.value,
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: followerList.length,
          itemBuilder: (context, index) {
            return groupChatInfoCardView(followerList[index]);
          })),
    );
  }

  Widget groupChatInfoCardView(SuggestedUser userInfo) {
    return Padding(
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(20), top: ScreenUtil().setHeight(20)),
      child: Column(
        children: [
          Row(
            children: [
              CommonNetworkImage(
                imageUrl: userInfo.image,
                height: 60,
                width: 60,
                radius: 30,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(17)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userInfo.username,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(14),
                            fontFamily: MyFont.Poppins_semibold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    _pressedOnFollowUnFollowGroup(userInfo);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: SvgPicture.asset(
                      selectedGroupMemberIds.contains(userInfo.id)
                          ? MyImage.ic_unfollower
                          : MyImage.ic_follower,
                      width: ScreenUtil().setWidth(22),
                      height: ScreenUtil().setHeight(18),
                    ),
                  )),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: ScreenUtil().setHeight(15),
              right: ScreenUtil().setWidth(20),
            ),
            child: Container(
              height: 1,
              color: purpleDimColor,
            ),
          )
        ],
      ),
    );
  }

  _onChangedSearchGroup() {
    _searchText = txtSearchController.text;
    resetSearch();
  }

  _pressedOnFollowUnFollowGroup(SuggestedUser userInfo) {
    if (selectedGroupMemberIds.contains(userInfo.id)) {
      selectedGroupMemberIds.remove(userInfo.id);
      selectedGroupMember.remove(userInfo);
    } else {
      if (selectedGroupMemberIds.length >= 20) {
        AlertView().showAlert(Messages.CGroupMemberLimit, context);
      } else {
        selectedGroupMemberIds.add(userInfo.id);
        selectedGroupMember.add(userInfo);
      }
    }
    widgetRefresher.value = Utilities.getRandomString();
  }
}
