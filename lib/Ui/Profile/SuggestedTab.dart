import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/EventCommentModel.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Ui/Profile/OtherUserProfile.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/ItemSkeleton.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:get/get.dart';

class SuggestedTab extends StatefulWidget {
  @override
  _SuggestedTabState createState() => _SuggestedTabState();
}

class _SuggestedTabState extends State<SuggestedTab> {
  List<SuggestedUser> _list = [];
  Timer _timer;
  var _searchController = TextEditingController();
  var onLoadMore = true;
  var dataOver = false;
  var widgetRefresher = "".obs;
  static const int perPage = 10;
  String _searchText = "";
  String uniqueKey = "";

  @override
  void initState() {
    super.initState();
    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.pageSize = perPage;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;
    _searchText = "";
    uniqueKey = Utilities.getRandomString();
    _callGetAllUsersApi();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _callGetAllUsersApi() {
    LogicalComponents.suggestedUsersModel.pageNumber++;
    var body = {
      Parameters.CpageNumber: LogicalComponents.suggestedUsersModel.pageNumber,
      Parameters.CpageSize: LogicalComponents.suggestedUsersModel.pageSize,
      Parameters.Csearch: _searchText,
      Parameters.CtotalRecords:
          LogicalComponents.suggestedUsersModel.totalRecords,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CUniqueKey: uniqueKey,
    };
    RequestManager.postRequest(
        uri: endPoints.UpdatedGetAllUsers,
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
          }
          widgetRefresher.value = Utilities.getRandomString();
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

  void _callFollowApi(int index) {
    var body = {
      Parameters.CuserIdSmall: SessionImpl.getId(),
      Parameters.CFollowerId: _list[index].id
    };
    RequestManager.postRequest(
        uri: endPoints.follow,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
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
          _list.removeAt(index);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callDeleteSuggested(int id) {
    var body = {
      Parameters.CuserIdSmall: SessionImpl.getId(),
      Parameters.CDeleteUserId: id
    };
    RequestManager.postRequest(
        uri: endPoints.deleteSuggested,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        onSuccess: (response) {},
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
              color: roundedcontainer),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(22),
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(20)),
            child: Column(
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
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.blue,
                        enabled: true,
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
                Padding(
                  padding: EdgeInsets.only(
                    top: ScreenUtil().setHeight(18),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            LabelStr.lblSuggested,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: MyFont.Poppins_semibold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 12.0,
                ),
                Expanded(
                    child: Obx(() => widgetRefresher.value == ''
                        ? _skeletonList()
                        : _list.length == 0
                            ? Widgets.dataNotFound()
                            : _favoritelist())),
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
    uniqueKey = Utilities.getRandomString();
    _callGetAllUsersApi();
  }

  _skeletonList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return ItemSkeleton();
        });
  }

  _favoritelist() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (!onLoadMore) {
            onLoadMore = true;
            //call api
            if (!dataOver) {
              _callGetAllUsersApi();
            }
          }
        } else {
          if (scrollInfo.metrics.pixels == 0) {
            onLoadMore = false;
          }
        }
        return true;
      },
      child: Obx(() => ListView.builder(
            shrinkWrap: true,
            restorationId: widgetRefresher.value,
            itemCount: dataOver ? _list.length : _list.length + 1,
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
                  : _list[index].isfollow == 1
                      ? Container()
                      : Container(
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: index == _list.length - 1
                                        ? Colors.transparent
                                        : chatTextBorderColor)),
                          ),
                          child: Slidable(
                            key: ValueKey(_list[index].id),
                            actionPane: SlidableDrawerActionPane(),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: LabelStr.lbldelete,
                                color: Colors.red,
                                icon: Icons.delete,
                                closeOnTap: true,
                                onTap: () {
                                  _callDeleteSuggested(_list[index].id);
                                  _list.removeAt(index);
                                  widgetRefresher.value =
                                      Utilities.getRandomString();
                                },
                              )
                            ],
                            dismissal: SlidableDismissal(
                              child: SlidableDrawerDismissal(),
                              onDismissed: (actionType) {
                                _callDeleteSuggested(_list[index].id);
                                _list.removeAt(index);
                                widgetRefresher.value =
                                    Utilities.getRandomString();
                              },
                            ),
                            child: InkWell(
                              onTap: () {
                                Get.to(OtherUserProfile(
                                    _list[index].id,
                                    _list[index].firstname +
                                        " " +
                                        _list[index].lastname,
                                    _list[index].username,
                                    _list[index].profileVerified,
                                    _list[index].image));
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: dimen.paddingSmall,
                                    bottom: dimen.paddingSmall),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 0.0),
                                      child: CommonNetworkImage(
                                        height: 50,
                                        width: 50,
                                        radius: 25,
                                        imageUrl: _list[index].image,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Widgets.userNameWithIndicator(
                                                OpenProfileNeedDataModel(
                                                    _list[index].id,
                                                    _list[index].firstname +
                                                        " " +
                                                        _list[index].lastname,
                                                    _list[index].username,
                                                    _list[index]
                                                        .profileVerified,
                                                    _list[index].image),
                                                overflow: TextOverflow.ellipsis,
                                                textSize: dimen.textSmall,
                                                fontFamily:
                                                    MyFont.poppins_regular,
                                                color: Colors.white),
                                            Text(
                                              _list[index].mutualCount > 0
                                                  ? (_list[index]
                                                          .mutualCount
                                                          .toString() +
                                                      " ${LabelStr.lblMutualConnection}")
                                                  : LabelStr
                                                      .lblNoMutualConnection,
                                              style: TextStyle(
                                                  fontFamily:
                                                      MyFont.poppins_regular,
                                                  fontSize: 10,
                                                  color: HexColor.textColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          if (_list[index].isfollow == 0) {
                                            _callFollowApi(index);
                                          }
                                        },
                                        child: Container(
                                          width: 75,
                                          height: 20,
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(
                                              right: dimen.marginNormal),
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
                                              _list[index].isfollow == 0
                                                  ? LabelStr.lblFollow
                                                  : LabelStr.lblRequested,
                                              style: TextStyle(
                                                  fontFamily:
                                                      MyFont.Poppins_medium,
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
            },
          )),
    );
  }
}
