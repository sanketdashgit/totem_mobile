import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Profile/OtherUserProfile.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class PeopleExplore extends StatefulWidget {
  @override
  _PeopleExploreState createState() => _PeopleExploreState();
}

class _PeopleExploreState extends State<PeopleExplore> {
  List<SuggestedUser> _list = [];
  Timer _timer;
  var onLoadMore = true;
  var dataOver = false;
  var widgetRefresher = "".obs;
  static const int perPage = 10;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.pageSize = perPage;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;
    _searchText = "";
    //_callGetAllUsersApi();
    startTimer();
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
      Parameters.Cid: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.GetAllExploreUsers,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          onLoadMore = false;
          LogicalComponents.suggestedUsersModel =
              SuggestedUsersModel.fromJson(response);
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

  void _callFollowApi(int index) {
    var body = {
      Parameters.CuserIdSmall: SessionImpl.getId(),
      Parameters.CFollowerId: _list[index].id
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(10, 5, 37, 1),
        body: Padding(
          padding: EdgeInsets.only(
              top: ScreenUtil().setHeight(22),
              left: ScreenUtil().setWidth(20),
              right: ScreenUtil().setWidth(20)),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 12.0,
              ),
              Expanded(
                  child: Obx(() => widgetRefresher.value == ''
                      ? Container()
                      : _list.length == 0
                          ? Widgets.dataNotFound()
                          : _favoriteList())),
            ],
          ),
        ));
  }

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (rq.searchText.value != _searchText) {
          _searchText = rq.searchText.value;
          resetSearch();
        }
      },
    );
  }

  resetSearch() {
    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;
    _callGetAllUsersApi();
  }

  _favoriteList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (!onLoadMore) {
            onLoadMore = true;
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
            padding: EdgeInsets.only(bottom: dimen.paddingNavigationBar),
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
                  : InkWell(
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
                                                " " +
                                                LabelStr.lblMutualConnection)
                                            : "No " +
                                                LabelStr.lblMutualConnection,
                                        style: TextStyle(
                                            fontFamily: MyFont.poppins_regular,
                                            fontSize: 10,
                                            color: HexColor.textColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _list[index].isfollow == 0
                                  ? Center(
                                      child: InkWell(
                                        onTap: () {
                                          _callFollowApi(index);
                                        },
                                        child: Container(
                                          width: 75,
                                          height: 20,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              shape: BoxShape.rectangle,
                                              color: darkBlue,
                                              border: Border.all(
                                                  color: HexColor.borderColor)),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              LabelStr.lblFollow,
                                              style: TextStyle(
                                                  fontFamily:
                                                      MyFont.Poppins_medium,
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                          index == _list.length - 1
                              ? Container()
                              : Divider(
                                  color: blueShadow600,
                                )
                        ],
                      ),
                    );
            },
          )),
    );
  }
}
