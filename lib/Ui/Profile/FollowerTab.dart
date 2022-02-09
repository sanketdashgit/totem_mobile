import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Ui/Profile/FollowRequests.dart';
import 'package:get/get.dart';
import 'package:totem_app/Ui/Profile/OtherUserProfile.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/ItemSkeleton.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class FollowerTab extends StatefulWidget {
  int id = 0;

  FollowerTab({this.id});

  @override
  _State createState() => _State();
}

class _State extends State<FollowerTab> {
  List<SuggestedUser> _list = [];
  List<SuggestedUser> _listRequest = [];
  Timer _timer;
  var _searchController = TextEditingController();
  var onLoadMore = true;
  var dataOver = false;
  var widgetRefresher = "".obs;
  var widgetRefresherRequest = "".obs;
  static const int perPage = 10;
  String _searchText = "";
  int userId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.id == null) widget.id = 0;
    if (widget.id == 0)
      userId = SessionImpl.getId();
    else
      userId = widget.id;
    init();
  }

  void init() {
    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.pageSize = perPage;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;
    _searchText = "";
    _callGetFollowerUsersApi();
    if (widget.id ==
        0) //if other user profile than does not show follow requests
      _callGetFollowRequestApi();
  }

  void resetData(bool isReset) {
    if (isReset) {
      widgetRefresher.value = '';
      widgetRefresherRequest.value = '';
      init();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _callGetFollowerUsersApi() {
    LogicalComponents.suggestedUsersModel.pageNumber++;
    var body = {
      Parameters.CpageNumber: LogicalComponents.suggestedUsersModel.pageNumber,
      Parameters.CpageSize: LogicalComponents.suggestedUsersModel.pageSize,
      Parameters.Csearch: _searchText,
      Parameters.CtotalRecords:
          LogicalComponents.suggestedUsersModel.totalRecords,
      Parameters.Cid: userId
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
            _list.clear();
          }
          if (LogicalComponents.suggestedUsersModel.data != null &&
              LogicalComponents.suggestedUsersModel.data.isNotEmpty) {
            _list.addAll(LogicalComponents.suggestedUsersModel.data);
            widgetRefresher.value = Utilities.getRandomString();
          }
        },
        onFailure: (error) {
          onLoadMore = false;
          if (LogicalComponents.suggestedUsersModel.pageNumber == 1) {
            dataOver = true;
            _list.clear();
            widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  void _callGetFollowRequestApi() {
    var body = {
      Parameters.CpageNumber: 1,
      Parameters.CpageSize: 3,
      Parameters.Csearch: _searchText,
      Parameters.CtotalRecords: 0,
      Parameters.Cid: userId
    };
    RequestManager.postRequest(
        uri: endPoints.getfollowerRequest,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          SuggestedUsersModel model = SuggestedUsersModel.fromJson(response);
          _listRequest.clear();
          if (model.data != null && model.data.isNotEmpty) {
            _listRequest.addAll(model.data);
            widgetRefresherRequest.value = Utilities.getRandomString();
          }
        },
        onFailure: (error) {
          _listRequest.clear();
          widgetRefresherRequest.value = Utilities.getRandomString();
        });
  }

  void _callRemoveFollowerApi(int index) {
    var body = {
      Parameters.CuserIdSmall: _list[index].id,
      Parameters.CFollowerId: userId
    };
    RequestManager.postRequest(
        uri: endPoints.follow,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          _list.removeAt(index);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callRemoveFollowRequestApi(int index) {
    var body = {
      Parameters.CuserIdSmall: _listRequest[index].id,
      Parameters.CFollowerId: userId
    };
    RequestManager.postRequest(
        uri: endPoints.follow,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          _listRequest.removeAt(index);
          widgetRefresherRequest.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callApproveFollowRequestApi(int index) {
    var body = {
      Parameters.CuserIdSmall: _listRequest[index].id,
      Parameters.CFollowerId: userId
    };
    RequestManager.postRequest(
        uri: endPoints.approveFollow,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          var item = _listRequest[index];
          _list.add(item);
          _listRequest.removeAt(index);
          widgetRefresherRequest.value = Utilities.getRandomString();
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callFollowApi(int index) {
    var body = {
      Parameters.CuserIdSmall: userId,
      Parameters.CFollowerId: _list[index].id
    };
    RequestManager.postRequest(
        uri: endPoints.follow,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          if (_list[index].isPrivate) {
            RequestManager.getSnackToast(
                title: LabelStr.lblSuccess,
                message: Messages.CFollowrequest,
                colorText: Colors.white,
                backgroundColor: Colors.black);
          } else {
            RequestManager.getSnackToast(
                title: LabelStr.lblSuccess,
                message: Messages.Cfollowing + _list[index].username,
                colorText: Colors.white,
                backgroundColor: Colors.black);
          }
          _list[index].isfollow = 1;
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor,
        body: Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)),
              color: Color.fromRGBO(31, 28, 50, 1)),
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(22),
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: HexColor.iconColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30, left: 10),
                      child: TextField(
                        onChanged: onItemChanged,
                        enabled: true,
                        style: TextStyle(color: Colors.white),
                        controller: _searchController,
                        cursorColor: Colors.blue,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: LabelStr.lblSearch,
                            hintStyle: TextStyle(color: colorHintText),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        if (!onLoadMore) {
                          onLoadMore = true;
                          //call api
                          if (!dataOver) {
                            _callGetFollowerUsersApi();
                          }
                        }
                      } else {
                        if (scrollInfo.metrics.pixels == 0) {
                          onLoadMore = false;
                        }
                      }
                      return true;
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.id != 0
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(18),
                                      bottom: ScreenUtil().setHeight(5)),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            LabelStr.lblFollowRequests,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontFamily:
                                                    MyFont.Poppins_semibold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      Obx(() => widgetRefresherRequest.value ==
                                              ''
                                          ? Container()
                                          : _listRequest.length == 0
                                              ? Container()
                                              : InkWell(
                                                  onTap: () {
                                                    Get.to(FollowRequest())
                                                        .then((value) =>
                                                            resetData(value));
                                                  },
                                                  child: Text(
                                                    LabelStr.lblSeeAll,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: MyFont
                                                            .Poppins_medium,
                                                        color: buttonPrimary),
                                                  ),
                                                )),
                                    ],
                                  ),
                                ),
                          widget.id != 0
                              ? Container()
                              : Obx(() => widgetRefresherRequest.value == ''
                                  ? _skeletonList(length: 3)
                                  : _listRequest.length == 0
                                      ? Widgets.dataNotFound()
                                      : _followrequestlist()),
                          SizedBox(
                            height: ScreenUtil().setHeight(8),
                          ),
                          Divider(
                            color: chatTextBorderColor,
                          ),
                          Text(
                            LabelStr.lblFollowers,
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: MyFont.Poppins_semibold,
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(8),
                          ),
                          Obx(() => widgetRefresher.value == ''
                              ? _skeletonList()
                              : _list.length == 0
                                  ? Widgets.dataNotFound()
                                  : _favoritelist())
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  onItemChanged(String value) {
    if (_searchController.text != '') {
      startTimer();
    } else {
      _timer.cancel();
      _searchText = _searchController.text;
      resetSearch();
    }
  }

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_searchController.text != _searchText) {
          _searchText = _searchController.text;
          resetSearch();
        }
      },
    );
  }

  resetSearch() {
    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;
    _callGetFollowerUsersApi();
  }

  _skeletonList({int length = 10}) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: length,
        itemBuilder: (context, index) {
          return ItemSkeleton();
        });
  }

  _favoritelist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          restorationId: widgetRefresher.value,
          itemCount: dataOver ? _list.length : _list.length + 1,
          itemBuilder: (context, index) {
            return index == _list.length
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      Get.to(OtherUserProfile(
                          _list[index].id,
                          _list[index].firstname + " " + _list[index].lastname,
                          _list[index].username,
                          _list[index].profileVerified,
                          _list[index].image));
                    },
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: CommonNetworkImage(
                                height: 50,
                                width: 50,
                                radius: 25,
                                imageUrl: _list[index].image,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Widgets.userNameWithIndicator(
                                        OpenProfileNeedDataModel(
                                            _list[index].id,
                                            _list[index].firstname +
                                                " " +
                                                _list[index].lastname,
                                            _list[index].username,
                                            _list[index].profileVerified,
                                            _list[index].image),
                                        overflow: TextOverflow.ellipsis,
                                        textSize: dimen.textSmall,
                                        fontFamily: MyFont.poppins_regular,
                                        color: Colors.white),
                                    Text(
                                      _list[index].mutualCount > 0
                                          ? (_list[index]
                                                  .mutualCount
                                                  .toString() +
                                              " ${LabelStr.lblMutualConnection}")
                                          : LabelStr.lblNoMutualConnection,
                                      style: TextStyle(
                                          fontFamily: MyFont.poppins_regular,
                                          fontSize: 10,
                                          color: HexColor.textColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                _list[index].isfollow != 0 &&
                                        _list[index].isfollow != 2
                                    ? Container()
                                    : widget.id != 0
                                        ? Container()
                                        : Center(
                                            child: InkWell(
                                              onTap: () {
                                                if (_list[index].isfollow != 2)
                                                  _callFollowApi(index);
                                              },
                                              child: Container(
                                                width: 85,
                                                height: 20,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    shape: BoxShape.rectangle,
                                                    color: colorGray,
                                                    border: Border.all(
                                                        color: HexColor
                                                            .borderColor)),
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    _list[index].isfollow == 2
                                                        ? LabelStr.lblRequested
                                                        : LabelStr
                                                            .lblFollowBack,
                                                    style: TextStyle(
                                                        fontFamily: MyFont
                                                            .Poppins_medium,
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                SizedBox(
                                  height: 5,
                                ),
                                widget.id != 0
                                    ? Container()
                                    : InkWell(
                                        onTap: () {
                                          _callRemoveFollowerApi(index);
                                        },
                                        child: Container(
                                          width: 75,
                                          height: 20,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              shape: BoxShape.rectangle,
                                              color: colorGray,
                                              border: Border.all(
                                                  color: HexColor.borderColor)),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              LabelStr.lblRemove,
                                              style: TextStyle(
                                                  fontFamily:
                                                      MyFont.Poppins_medium,
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            )
                          ],
                        ),
                        index == _list.length - 1
                            ? Container()
                            : Divider(
                                color: chatTextBorderColor,
                              )
                      ],
                    ),
                  );
          },
        ));
  }

  _followrequestlist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          restorationId: widgetRefresherRequest.value,
          itemCount: _listRequest.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Get.to(OtherUserProfile(
                    _listRequest[index].id,
                    _listRequest[index].firstname +
                        " " +
                        _listRequest[index].lastname,
                    _listRequest[index].username,
                    _listRequest[index].profileVerified,
                    _listRequest[index].image));
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: CommonNetworkImage(
                          height: 50,
                          width: 50,
                          radius: 25,
                          imageUrl: _listRequest[index].image,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _listRequest[index].firstname +
                                    " " +
                                    _listRequest[index].lastname,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: MyFont.poppins_regular,
                                    color: Colors.white),
                              ),
                              Text(
                                _listRequest[index].mutualCount > 0
                                    ? (_listRequest[index]
                                            .mutualCount
                                            .toString() +
                                        " ${LabelStr.lblMutualConnection}")
                                    : LabelStr.lblNoMutualConnection,
                                style: TextStyle(
                                    fontFamily: MyFont.poppins_regular,
                                    fontSize: 10,
                                    color: HexColor.textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                _callApproveFollowRequestApi(index);
                              },
                              child: Container(
                                width: 75,
                                height: 20,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    shape: BoxShape.rectangle,
                                    color: switchButtonactiveColor,
                                    border: Border.all(
                                        color: HexColor.borderColor)),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    LabelStr.lblApprove,
                                    style: TextStyle(
                                        fontFamily: MyFont.Poppins_semibold,
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _callRemoveFollowRequestApi(index);
                              },
                              child: Container(
                                width: 75,
                                height: 20,
                                margin: EdgeInsets.only(top: 5.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    shape: BoxShape.rectangle,
                                    color: switchButtonactiveColor,
                                    border: Border.all(
                                        color: HexColor.borderColor)),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    LabelStr.lbldelete,
                                    style: TextStyle(
                                        fontFamily: MyFont.Poppins_medium,
                                        fontSize: 12,
                                        color: Colors.white60),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  index == _listRequest.length - 1
                      ? Container()
                      : Divider(
                          color: chatTextBorderColor,
                        )
                ],
              ),
            );
          },
        ));
  }
}
