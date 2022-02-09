import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/SearchEventModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/SelectLocation.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import '../Customs/ButtonRegular.dart';

class TagEvent extends StatefulWidget {
  @override
  _TagEventState createState() => _TagEventState();
}

class _TagEventState extends State<TagEvent> {
  List<SearchEventModel> _list = [];

  Timer _timer;
  var widgetRefresher = "".obs;
  var _searchController = TextEditingController();
  String _searchText = "";
  var checkBoxValue = false;

  var addViewActive = false.obs;

  var _eventNameController = TextEditingController();
  DateTime stEventDT = DateTime.now();
  DateTime stCurrentDt = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay.now();
  var eventStTime = ''.obs;

  var addressStr = ''.obs;
  var latitude = 0.0;
  var longitude = 0.0;
  var focusNode = FocusNode();

  DateTime _selectedDate;
  var selectedYear = "Select Year".obs;

  @override
  void initState() {
    super.initState();
    _searchText = "";
    _callEventsApi();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  void _callEventsApi() {
    var body = {
      Parameters.CpageNumber: 1,
      Parameters.CpageSize: 20,
      Parameters.Csearch: _searchText,
      Parameters.CtotalRecords: 0,
      Parameters.CeventId: 0,
      Parameters.CUserId: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.getAllEventByPost,
        // uri: endPoints.getAllEvent,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          _list = List<SearchEventModel>.from(
              response['data'].map((x) => SearchEventModel.fromJson(x)));
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _CreateEventByPost() {
    print("Asdfdsvgh");
    var body = {
      Parameters.CUserId: SessionImpl.getId(),
      Parameters.CeventId: 0,
      Parameters.CEventName: _eventNameController.text.toString().trim(),
      Parameters.CStartDate: _selectedDate.toString(),
    };
    RequestManager.postRequest(
        uri: endPoints.createEventByPost,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          rq.selectedEventId.value = response["eventId"];
          rq.selectedEventName.value = response["eventName"];
          Get.back();
        },
        onFailure: (error) {
          print("error  $error");
        });
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
              backgroundColor: screenBgColor,
              brightness: Brightness.dark,
              leading: InkWell(
                  onTap: () {
                    _eventNameController.text = '';
                    selectedYear.value = "Select Year";
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                    child: Icon(Icons.arrow_back_ios_outlined),
                  )),
              title: Text(
                LabelStr.lblTagEvent,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: MyFont.Poppins_semibold,
                    color: Colors.white),
              )),
          body: Obx(() => Container(
              padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(10),
                  left: ScreenUtil().setWidth(20),
                  right: ScreenUtil().setWidth(20)),
              child: _searchEventView())),
        ));
  }

  Widget _addEventView() {
    return Container(
      margin: EdgeInsets.only(top: dimen.marginLarge),
      child: Column(
        children: [
          Container(
              child: textFieldFor(LabelStr.lbleventname, _eventNameController,
                  autocorrect: false,
                  maxLength: 50,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.none,
                  keyboardType: TextInputType.text)),
          SizedBox(
            height: dimen.dividerHeightHuge,
          ),
          Container(
              height: 45,
              width: double.infinity,
              padding: EdgeInsets.all(dimen.paddingSmall),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: MyColor.textFieldBorderColor(),
                ),
              ),
              child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Select Year"),
                          content: Container(
                            // Need to use container to add size constraint.
                            width: 300,
                            height: 300,
                            child: YearPicker(
                              firstDate: DateTime(DateTime.now().year - 100, 1),
                              lastDate: DateTime(DateTime.now().year + 100, 1),
                              initialDate: DateTime.now(),
                              selectedDate: _selectedDate ?? DateTime.now(),
                              onChanged: (DateTime dateTime) {
                                _selectedDate = dateTime;
                                selectedYear.value = dateTime.year.toString();
                                Get.back();
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Obx(() => Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              selectedYear.value,
                              style: TextStyle(
                                  fontSize: dimen.textNormal,
                                  color: MyColor.hintTextColor(),
                                  fontFamily: MyFont.Poppins_medium),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            color: MyColor.hintTextColor(),
                          )
                        ],
                      )))),
          SizedBox(
            height: dimen.dividerHeightHuge,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 26, top: 8),
            child: Container(
                child: ButtonRegular(
                    buttonText: "Add Event",
                    onPressed: () {
                      _addEventData();
                      // Get.back();
                    })),
          )
        ],
      ),
    );
  }

  Widget _searchEventView() {
    return Column(
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
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: TextField(
                onChanged: onItemChanged,
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.blue,
                enabled: true,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: LabelStr.lblSearch,
                    hintStyle:
                        TextStyle(color: Color.fromRGBO(157, 160, 181, 1)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    suffixIcon: IconButton(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      icon: Icon(
                        addViewActive.value
                            ? Icons.remove_circle_outline
                            : Icons.add_circle_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        addViewActive.value =
                            addViewActive.value ? false : true;
                      },
                    )),
              ),
            ),
          ),
        ),
        addViewActive.value
            ? _addEventView()
            : Expanded(
                child: Obx(() => widgetRefresher.value == ''
                    ? Container(
                        height: 1,
                      )
                    : _list.length == 0 && _searchText.isNotEmpty
                        ? _addEventView()
                        : _favoriteList()),
              ),
      ],
    );
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
          _callEventsApi();
        }
      },
    );
  }

  resetSearch() {
    _list.clear();
    widgetRefresher.value = Utilities.getRandomString();
  }

  _addEvent() {
    return InkWell(
      child: Container(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: 13, right: 20, left: 20),
          padding: EdgeInsets.symmetric(vertical: dimen.paddingVerySmall),
          height: 34,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              shape: BoxShape.rectangle,
              color: Colors.transparent,
              border: Border.all(
                color: Color.fromRGBO(139, 115, 197, 1),
                width: 1.0,
              )),
          child: Text(
            LabelStr.lblAddNewEvent,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: MyFont.Poppins_medium),
          ),
        ),
      ),
      onTap: () => addViewActive.value = true,
    );
  }

  _favoriteList() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          restorationId: widgetRefresher.value,
          itemCount: _list.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: (() {
                if (_list[index].eventImages.length > 0)
                  rq.selectedEventImg.value =
                      _list[index].eventImages[0].downloadlink;
                rq.selectedEventName.value = _list[index].eventName;
                rq.selectedEventAdd.value = _list[index].address;
                rq.selectedEventId.value = _list[index].eventId;
                _searchText = '';
                _searchController.text = '';
                widgetRefresher.value = '';
                Get.back();
              }),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CommonNetworkImage(
                        height: 50,
                        width: 50,
                        radius: 25,
                        imageUrl: _list[index].eventImages.length > 0
                            ? _list[index].eventImages[0].downloadlink
                            : "",
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _list[index].eventName,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: MyFont.poppins_regular,
                                    color: Colors.white),
                              ),
                              Text(
                                _list[index].address,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: MyFont.poppins_regular,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  index == _list.length - 1
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(left: 56),
                          child: Divider(
                            color: HexColor("#3C456C"),
                          ),
                        )
                ],
              ),
            );
          },
        ));
  }

  String getTimeIn12Format(var tempTime) {
    var hr = tempTime.hour;

    if (int.parse(tempTime.hour.toString()) > 12)
      hr = tempTime.hour.toInt() - 12;

    return hr.toString() +
        ":" +
        tempTime.minute.toString() +
        (tempTime.period.index == 0 ? " AM" : " PM");
  }

  _openAddress() async {
    var result = await Navigator.push(
        context, new MaterialPageRoute(builder: (context) => SelectLocation()));
    if (result != null) {
      addressStr.value = result[1]['placeName'];
      latitude = result[1]['lat'];
      longitude = result[1]['lng'];
    }
    focusNode.requestFocus();
  }

  _addEventData() {
    if (_eventNameController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEventName,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
    } else if (selectedYear.value == 'Select Year') {
      RequestManager.getSnackToast(
          message: Messages.CBlankEventYear,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
    } else {
      print("asdfdgsf");
      _CreateEventByPost();
    }
  }
}
