import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
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

class FollowRequest extends StatefulWidget {
  @override
  _FollowRequestState createState() => _FollowRequestState();
}

class _FollowRequestState extends State<FollowRequest> {
  List<SuggestedUser> _listRequest = [];
  var onLoadMore = true;
  var dataOver = false;
  var widgetRefresher = "".obs;
  static const int perPage = 10;
  var isActionDone = false;

  @override
  void initState() {
    super.initState();
    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.pageSize = perPage;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;
    _callGetFollowRequestApi();
  }

  void _callGetFollowRequestApi() {
    LogicalComponents.suggestedUsersModel.pageNumber++;
    var body = {
      Parameters.CpageNumber: LogicalComponents.suggestedUsersModel.pageNumber,
      Parameters.CpageSize: LogicalComponents.suggestedUsersModel.pageSize,
      Parameters.Csearch: '',
      Parameters.CtotalRecords:
          LogicalComponents.suggestedUsersModel.totalRecords,
      Parameters.Cid: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.getfollowerRequest,
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
            _listRequest.clear();
          }
          if (LogicalComponents.suggestedUsersModel.data != null &&
              LogicalComponents.suggestedUsersModel.data.isNotEmpty) {
            _listRequest.addAll(LogicalComponents.suggestedUsersModel.data);
            widgetRefresher.value = Utilities.getRandomString();
          }
        },
        onFailure: (error) {
          onLoadMore = false;
          if (LogicalComponents.suggestedUsersModel.pageNumber == 1) {
            dataOver = true;
            _listRequest.clear();
            widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  void _callRemoveFollowRequestApi(int index) {
    var body = {
      Parameters.CuserIdSmall: _listRequest[index].id,
      Parameters.CFollowerId: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.follow,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          isActionDone = true;
          _listRequest.removeAt(index);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callApproveFollowRequestApi(int index) {
    var body = {
      Parameters.CuserIdSmall: _listRequest[index].id,
      Parameters.CFollowerId: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.approveFollow,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          isActionDone = true;
          _listRequest.removeAt(index);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: isActionDone);
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBgColor,
        appBar: AppBar(
            centerTitle: true,
            brightness: Brightness.dark,
            leading: InkWell(
                onTap: () {
                  Get.back(result: isActionDone);
                },
                child: Padding(
                  padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                  child: Icon(Icons.arrow_back_ios_outlined),
                )),
            title: Text(
              LabelStr.lblFollowRequests,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: MyFont.Poppins_semibold,
                  color: Colors.white),
            )),
        body: Container(
          child: Container(
            margin: EdgeInsets.only(
              top: ScreenUtil().setHeight(29),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: roundedcontainer),
            height: double.infinity,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
            child: Expanded(
              child: Obx(() => widgetRefresher.value == ''
                  ? _skeletonList()
                  : _listRequest.length == 0
                      ? Widgets.dataNotFound()
                      : _followrequestlist()),
            ),
          ),
        ),
      ),
    );
  }

  _skeletonList({int length = 10}) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: length,
        itemBuilder: (context, index) {
          return ItemSkeleton();
        });
  }

  _followrequestlist() {
    return Obx(() => NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (!onLoadMore) {
              onLoadMore = true;
              //call api
              if (!dataOver) {
                _callGetFollowRequestApi();
              }
            }
          } else {
            if (scrollInfo.metrics.pixels == 0) {
              onLoadMore = false;
            }
          }
          return true;
        },
        child: ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresher.value,
          itemCount: dataOver ? _listRequest.length : _listRequest.length + 1,
          itemBuilder: (context, index) {
            return index == _listRequest.length
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
                                    Widgets.userNameWithIndicator(
                                        OpenProfileNeedDataModel(
                                            _listRequest[index].id,
                                            _listRequest[index].firstname +
                                                " " +
                                                _listRequest[index].lastname,
                                            _listRequest[index].username,
                                            _listRequest[index].profileVerified,
                                            _listRequest[index].image),
                                        overflow: TextOverflow.ellipsis,
                                        textSize: dimen.textSmall,
                                        fontFamily: MyFont.poppins_regular,
                                        color: Colors.white),
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
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          shape: BoxShape.rectangle,
                                          color: uploadImgBtnClr,
                                          border: Border.all(
                                              color: HexColor.borderColor)),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          LabelStr.lblApprove,
                                          style: TextStyle(
                                              fontFamily:
                                                  MyFont.Poppins_semibold,
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
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          shape: BoxShape.rectangle,
                                          color: colorGray,
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
        )));
  }
}
