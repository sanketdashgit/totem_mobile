import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/GetfollowerCountModel.dart';
import 'package:totem_app/Models/NotificationModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/ItemSkeleton.dart';
import 'package:totem_app/Ui/Post/PostDetail.dart';
import 'package:totem_app/Ui/Profile/OtherUserProfile.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<NotificationScreen> {
  List<NotificationData> _list = [];
  var widgetRefresher = ''.obs;

  var onLoadMore = true;
  var dataOver = false;
  int pageNumber = 0;
  int totalRecords = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _getAllNotificationApi();
  }

  void _onRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    pageNumber = 0;
    _getAllNotificationApi();
  }

  void _onLoading() async {
    await Future.delayed(Duration(seconds: 1));
  }

  void _getAllNotificationApi() {
    pageNumber++;
    var body = {
      Parameters.CpageNumber: pageNumber,
      Parameters.CpageSize: global.PAGE_SIZE_EXPLORE,
      Parameters.Csearch: '',
      Parameters.CtotalRecords: totalRecords,
      Parameters.Cid: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.GetNotification,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          onLoadMore = false;

          pageNumber = response[Parameters.CpageNumber];
          totalRecords = response[Parameters.CtotalRecords];

          _refreshController.loadComplete();
          _refreshController.refreshCompleted();
          if ((pageNumber * global.PAGE_SIZE_EXPLORE) < totalRecords) {
            dataOver = false;
          } else {
            dataOver = true;
          }
          if (pageNumber == 1) {
            _list.clear();
          }
          if ((response[Parameters.CData] as List<dynamic>).isNotEmpty) {
            var temp = List<NotificationData>.from(
                response[Parameters.CData].map((x) => NotificationData.fromJson(x)));
            _list.addAll(temp);
          }
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {
          onLoadMore = false;
          if (pageNumber == 1) {
            dataOver = true;
            _list.clear();
            widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  void _clearAllNotificationApi() {
    var body = {Parameters.Cid: SessionImpl.getId()};
    RequestManager.postRequest(
        uri: endPoints.ClearNotification,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          _list.clear();
          pageNumber = 0;
          _getAllNotificationApi();
        },
        onFailure: (error) {});
  }

  showAlertDialog(BuildContext context, int index, bool status) {
    Widget okButton = TextButton(
      child: Text(LabelStr.lblNo),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: Text(LabelStr.lblYes),
      onPressed: () {
        Get.back();
        _approveNotification(index, status);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(
        Messages.CProfileVisible,
        style: TextStyle(fontFamily: MyFont.Poppins_medium, fontSize: 14),
      ),
      actions: [okButton, continueButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _approveNotification(int index, bool status) {
    var body = {
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CPostId: _list[index].notificationTypeId,
      Parameters.CStatus: status
    };
    RequestManager.postRequest(
        uri: endPoints.PostTagRequestAccept,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        isFailedMessage: true,
        onSuccess: (response) {
          _list.removeAt(index);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callRemoveFollowRequestApi(int index) {
    var body = {
      Parameters.CuserIdSmall: _list[index].notificationTypeId,
      Parameters.CFollowerId: SessionImpl.getId()
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

  void _callApproveFollowRequestApi(int index) {
    var body = {
      Parameters.CuserIdSmall: _list[index].notificationTypeId,
      Parameters.CFollowerId: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.approveFollow,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          _list.removeAt(index);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callFollowApi(int index) {
    var body = {
      Parameters.CuserIdSmall: SessionImpl.getId(),
      Parameters.CFollowerId: _list[index].notificationTypeId
    };
    RequestManager.postRequest(
        uri: endPoints.follow,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          _list[index].requestAccepted = 1;
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _getUserDetails(int id) {
    var body = {Parameters.CUserId: SessionImpl.getId(), Parameters.Cid: id};
    RequestManager.postRequest(
        uri: endPoints.GetfollowerCount,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          Get.to(OtherUserProfile(
              response["profileDetails"]['id'],
              response["profileDetails"]['firstname'] +
                  response["profileDetails"]['lastname'],
              response["profileDetails"]['username'],
              response["profileDetails"]['profileVerified'],
              response["profileDetails"]['image']));
        },
        onFailure: (error) {});
  }

  _getFollowerCount(Map<String, dynamic> params) {
    RequestManager.postRequest(
        uri: endPoints.GetfollowerCount,
        body: params,
        isLoader: true,
        isFailedMessage: false,
        isSuccessMessage: false,
        onSuccess: (response) {
          GetfollowerCountModel countModel =
              GetfollowerCountModel.fromJson(response);
          Get.to(OtherUserProfile(
              countModel.profileDetails.id,
              countModel.profileDetails.firstname,
              countModel.profileDetails.username,
              countModel.profileDetails.profileVerified,
              countModel.profileDetails.image));
        },
        onFailure: () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(49),
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30)),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.all(dimen.paddingForBackArrow),
                        child: SvgPicture.asset(MyImage.ic_arrow),
                      )),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Center(
                    child: Text(
                      LabelStr.lblAllNotification,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: MyFont.Poppins_semibold,
                          color: Colors.white),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() => widgetRefresher.value == ''
                      ? Container()
                      : _list.length == 0
                          ? Container()
                          : InkWell(
                              onTap: (() {
                                _clearAllNotificationApi();
                              }),
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: boxColor),
                                child: Text(
                                  LabelStr.lblClear,
                                  style: TextStyle(
                                      fontSize: dimen.textSmall,
                                      color: whiteTextColor),
                                ),
                              ),
                            )),
                )
              ],
            ),
          ),
          SizedBox(
            height: dimen.paddingMedium,
          ),
          Divider(
            color: dividerLineColor,
          ),
          Expanded(
              flex: 1,
              child: Obx(() => widgetRefresher.value == ''
                  ? _skeletonList()
                  : _list.length == 0
                      ? Widgets.dataNotFound(title: LabelStr.lblEmpty)
                      : _notificationList())),
        ],
      ),
    );
  }

  _skeletonList() {
    return Padding(
      padding: const EdgeInsets.only(
          left: dimen.paddingExtraLarge,
          right: dimen.paddingExtraLarge,
          top: 0),
      child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: 10,
          itemBuilder: (context, index) {
            return ItemSkeleton();
          }),
    );
  }

  _notificationList() {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (!onLoadMore) {
              onLoadMore = true;
              if (!dataOver) {
                _getAllNotificationApi();
              }
            }
          } else {
            if (scrollInfo.metrics.pixels == 0) {
              onLoadMore = false;
            }
          }
          return true;
        },
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            itemCount: dataOver ? _list.length : _list.length + 1,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return index == _list.length
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.0,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                          top: dimen.paddingMedium,
                          left: dimen.paddingExtraLarge,
                          right: dimen.paddingExtraLarge),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CommonNetworkImage(
                                radius: 25,
                                height: 50,
                                width: 50,
                                imageUrl: _list[index].image,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: dimen.paddingLarge),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Flexible(
                                              fit: FlexFit.tight,
                                              child: Text(
                                                _list[index].title,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: dimen.textNormal,
                                                    fontFamily:
                                                        MyFont.Poppins_semibold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Text(
                                              daysBetween(_list[index].date),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontFamily:
                                                      MyFont.Poppins_semibold,
                                                  color: Colors.white60),
                                            )
                                          ],
                                        ),
                                        Wrap(
                                          children: [
                                            RichText(
                                              text: TextSpan(children: [
                                                TextSpan(
                                                  text: _list[index].nuserName,
                                                  style: TextStyle(
                                                      fontFamily: MyFont
                                                          .poppins_regular,
                                                      fontSize: dimen.textSmall,
                                                      color:
                                                          HexColor.textColor),
                                                  recognizer:
                                                      new TapGestureRecognizer()
                                                        ..onTap = () {
                                                          _getUserDetails(_list[
                                                                  index]
                                                              .notificationTypeId);
                                                        },
                                                ),
                                                TextSpan(
                                                  text: _list[index].descp,
                                                  style: TextStyle(
                                                      fontFamily: MyFont
                                                          .poppins_regular,
                                                      fontSize: dimen.textSmall,
                                                      color:
                                                          HexColor.textColor),
                                                ),
                                              ]),
                                            ),
                                          ],
                                        ),
                                        _list[index].notificationType ==
                                                    global
                                                        .NOTIFICATION_POST_TYPE ||
                                                _list[index].notificationType ==
                                                    global
                                                        .NOTIFICATION_FOLLOW_REQUEST_TYPE ||
                                                _list[index].notificationType ==
                                                    global
                                                        .NOTIFICATION_FOLLOW_TYPE ||
                                                _list[index].notificationType ==
                                                    global
                                                        .NOTIFICATION_COMMENT_TYPE ||
                                                _list[index].notificationType ==
                                                    global
                                                        .NOTIFICATION_LIKE_TYPE
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: dimen.paddingSmall),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    _list[index]
                                                                    .notificationType ==
                                                                global
                                                                    .NOTIFICATION_POST_TYPE ||
                                                            _list[index]
                                                                    .notificationType ==
                                                                global
                                                                    .NOTIFICATION_FOLLOW_REQUEST_TYPE ||
                                                        (_list[index]
                                                                    .notificationType ==
                                                                global
                                                                    .NOTIFICATION_FOLLOW_TYPE && _list[index].requestAccepted ==0)
                                                        ? InkWell(
                                                            onTap: () {
                                                              if (_list[index]
                                                                      .notificationType ==
                                                                  global
                                                                      .NOTIFICATION_POST_TYPE)
                                                                showAlertDialog(
                                                                    context,
                                                                    index,
                                                                    true);
                                                              else if (_list[
                                                                          index]
                                                                      .notificationType ==
                                                                  global
                                                                      .NOTIFICATION_FOLLOW_REQUEST_TYPE)
                                                                _callApproveFollowRequestApi(
                                                                    index);
                                                              else if (_list[
                                                                          index]
                                                                      .notificationType ==
                                                                  global
                                                                      .NOTIFICATION_FOLLOW_TYPE)
                                                                _callFollowApi(
                                                                    index);
                                                            },
                                                            child: Container(
                                                              width: _list[index]
                                                                          .notificationType ==
                                                                      global
                                                                          .NOTIFICATION_FOLLOW_TYPE
                                                                  ? 125
                                                                  : 75,
                                                              height: 20,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                  color: purple500,
                                                                  border: Border.all(
                                                                      color: HexColor
                                                                          .borderColor)),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  _list[index].notificationType ==
                                                                          global
                                                                              .NOTIFICATION_FOLLOW_TYPE
                                                                      ? LabelStr
                                                                          .lblFollowBack
                                                                      : LabelStr
                                                                          .lblApprove,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          MyFont
                                                                              .Poppins_semibold,
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      width:
                                                          dimen.paddingMedium,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        if (_list[index].notificationType == global.NOTIFICATION_POST_TYPE ||
                                                            _list[index]
                                                                    .notificationType ==
                                                                global
                                                                    .NOTIFICATION_COMMENT_TYPE ||
                                                            _list[index]
                                                                    .notificationType ==
                                                                global
                                                                    .NOTIFICATION_LIKE_TYPE)
                                                          Get.to(PostDetail(_list[
                                                                  index]
                                                              .notificationTypeId));
                                                        else if (_list[index]
                                                                .notificationType ==
                                                            global
                                                                .NOTIFICATION_FOLLOW_TYPE)
                                                          _getFollowerCount({
                                                            Parameters.CUserId:
                                                                SessionImpl
                                                                    .getId(),
                                                            Parameters
                                                                .Cid: _list[
                                                                    index]
                                                                .notificationTypeId
                                                          });
                                                        else if (_list[index]
                                                                .notificationType ==
                                                            global
                                                                .NOTIFICATION_FOLLOW_REQUEST_TYPE)
                                                          _callRemoveFollowRequestApi(
                                                              index);
                                                      },
                                                      child: Container(
                                                        width: 75,
                                                        height: 20,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    4),
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: darkBlue,
                                                            border: Border.all(
                                                                color: HexColor
                                                                    .borderColor)),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            _list[index]
                                                                            .notificationType ==
                                                                        global
                                                                            .NOTIFICATION_POST_TYPE ||
                                                                    _list[index]
                                                                            .notificationType ==
                                                                        global
                                                                            .NOTIFICATION_COMMENT_TYPE ||
                                                                    _list[index]
                                                                            .notificationType ==
                                                                        global
                                                                            .NOTIFICATION_LIKE_TYPE ||
                                                                    _list[index]
                                                                            .notificationType ==
                                                                        global
                                                                            .NOTIFICATION_FOLLOW_TYPE
                                                                ? LabelStr
                                                                    .lblView
                                                                : LabelStr
                                                                    .lbldelete,
                                                            style: TextStyle(
                                                                fontFamily: MyFont
                                                                    .Poppins_medium,
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white60),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container()
                                      ]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: dimen.paddingMedium,
                          ),
                          _list.length == index + 1
                              ? Container()
                              : Divider(
                                  color: dividerLineColor,
                                ),
                        ],
                      ),
                    );
            },
          ),
        ));
  }

  String daysBetween(String crDate) {
    var stringList = crDate.split(new RegExp(r"[T\.]"));
    var formatedDate = "${stringList[0]} ${stringList[1]}";
    DateTime fromUtc =
        DateFormat("yyyy-MM-dd HH:mm:ss").parse(formatedDate, true);
    DateTime to = DateTime.now();
    DateTime from = fromUtc.toLocal();
    // var diff = to.difference(from).inMinutes;
    var diff = (to.difference(from).inDays);
    var timeAgo = DateFormat('hh:mm a').format(from);
    if (diff == 1) {
      timeAgo = "Yesterday " + DateFormat('hh:mm a').format(from);
    } else if (diff == 0) {
      timeAgo = DateFormat('hh:mm a').format(from);
    } else {
      timeAgo = DateFormat('dd MMM yyyy').format(from);
    }
    return timeAgo;
  }
}
