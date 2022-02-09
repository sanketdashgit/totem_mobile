import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import '../Customs/ButtonRegular.dart';
import '../Customs/ItemSkeleton.dart';

class TagePeople extends StatefulWidget {
  @override
  _TagePeopleState createState() => _TagePeopleState();
}

class _TagePeopleState extends State<TagePeople> {
  List<SuggestedUser> _originalData = [];
  List<SuggestedUser> _filteredData = [];
  List<SuggestedUser> _selectedData = [];
  List<int> _selectedIds = [];
  Timer _timer;
  var widgetRefresher = "".obs;
  var _searchController = TextEditingController();
  String _searchText = "";

  var checkBoxValue = false;

  @override
  void initState() {
    super.initState();
    _searchText = "";
    _selectedData.addAll(rq.tagPeopleList);
    _selectedIds.addAll(rq.tagPeopleSelectedIds);
    _callGetAllUsersApi();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _callGetAllUsersApi() {
    var body = {
      Parameters.CpageNumber: 0,
      Parameters.CpageSize: 0,
      Parameters.Csearch: _searchText,
      Parameters.CtotalRecords: 3000,
      Parameters.Cid: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.TagAllFollowerList,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          _originalData = List<SuggestedUser>.from(
              response[Parameters.CData].map((x) => SuggestedUser.fromJson(x)));
          _filteredData.addAll(_originalData);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Get.back();
          return false;
        },
        child: Scaffold(
          backgroundColor: screenBgColor,
          appBar: AppBar(
              centerTitle: true,
              brightness: Brightness.dark,
              backgroundColor: screenBgColor,
              leading: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                    child: Icon(Icons.arrow_back_ios_outlined),
                  )),
              title: Text(
                LabelStr.lblTagFriends,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: MyFont.Poppins_semibold,
                    color: Colors.white),
              )),
          body: Container(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(10),
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(20)),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: screenBgLightColor,
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
                            hintStyle: TextStyle(
                                color: colorHintText),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Obx(() => widgetRefresher.value == ''
                        ? _skeletonList()
                        : _filteredData.length == 0
                            ? Widgets.dataNotFound()
                            : _favoriteList())),
                Padding(
                  padding: const EdgeInsets.only(bottom: 26, top: 8),
                  child: Container(
                      child: ButtonRegular(
                          buttonText: LabelStr.lblTab,
                          onPressed: () {
                            rq.tagPeopleList.clear();
                            rq.tagPeopleList.addAll(_selectedData);
                            rq.tagPeopleSelectedIds.clear();
                            rq.tagPeopleSelectedIds.addAll(_selectedIds);
                            rq.tagPeopleCount.value =
                                rq.tagPeopleList.length == 0
                                    ? ""
                                    : rq.tagPeopleList.length == 1
                                        ? rq.tagPeopleList[0].username
                                        : rq.tagPeopleList.length.toString() +
                                            " "+LabelStr.lblPeoples;
                            Get.back();
                          })),
                )
              ],
            ),
          ),
        ));
  }

  _skeletonList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return ItemSkeleton();
        });
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
    if (_searchText.isEmpty) {
      _filteredData.clear();
      _filteredData.addAll(_originalData);
    } else {
      _filteredData.clear();
      _originalData.forEach((element) {
        if (element.firstname
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            element.lastname
                .toLowerCase()
                .contains(_searchText.toLowerCase()) ||
            element.username
                .toLowerCase()
                .contains(_searchText.toLowerCase())) {
          _filteredData.add(element);
        }
      });
    }
    widgetRefresher.value = Utilities.getRandomString();
  }

  _favoriteList() {
    return ListView.builder(
      shrinkWrap: true,
      restorationId: widgetRefresher.value,
      itemCount: _filteredData.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: Container(
                    height: 50.0,
                    width: 50.0,
                    child: Center(
                        child: CommonNetworkImage(
                      imageUrl: _filteredData[index].image,
                    )),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      _filteredData[index].username,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: MyFont.poppins_regular,
                          color: Colors.white),
                    ),
                  ),
                ),
                Center(
                  child: Theme(
                      data: ThemeData(
                        unselectedWidgetColor: Colors.white,
                      ),
                      child: Checkbox(
                          activeColor: buttonPrimary,
                          value: _selectedIds.contains(_filteredData[index].id),
                          tristate: false,
                          onChanged: (bool newValue) {
                            if (!_selectedIds
                                .contains(_filteredData[index].id)) {
                              _selectedData.add(_filteredData[index]);
                              _selectedIds.add(_filteredData[index].id);
                            } else {
                              var removeIndex = 0;
                              _selectedData.forEach((element) {
                                if (element == _filteredData[index]) {
                                  removeIndex = _selectedData.indexOf(element);
                                }
                              });
                              _selectedData.removeAt(removeIndex);
                              _selectedIds.removeAt(removeIndex);
                            }
                            widgetRefresher.value = Utilities.getRandomString();
                          })),
                ),
              ],
            ),
            index == _filteredData.length - 1
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Divider(
                      color: blueShadow600,
                    ),
                  )
          ],
        );
      },
    );
  }
}
