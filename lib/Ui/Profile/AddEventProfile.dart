import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';
import 'package:totem_app/Models/CreateEventModel.dart';
import 'package:totem_app/Models/EventHomeModel.dart';
import 'package:get/get.dart';
import 'package:totem_app/Models/EventTicketMaster.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class AddEventProfile extends StatefulWidget {

  @override
  _AddEventProfileState createState() => _AddEventProfileState();
}

class _AddEventProfileState extends State<AddEventProfile> {

  Timer _timer;
  var widgetRefresher = "".obs;
  var _searchController = TextEditingController();
  String _searchText = "";
  List<EventHomeModel> _list = [];
  List<EventHomeModel> _selectedData = [];
  List<String> _selectedIds = [];
  List<String> duplicateEvents = [];

  @override
  void initState() {
    super.initState();
    _searchText = "";
    _selectedData.addAll(rq.selectedEvents);
    _selectedData.forEach((element) {
      _selectedIds.add(element.eventId.toString());
    });
    _callEventsApi();
  }

  @override
  void dispose() {
    _timer.cancel();
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
        uri: endPoints.getAllEvent,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          duplicateEvents = [];
          _list = List<EventHomeModel>.from(
              response['data'].map((x) => EventHomeModel.fromJson(x)));
          _list.forEach((element) {
            duplicateEvents.add(
                element.eventName + " " + element.vanueId);
          });
          if(_searchText.isNotEmpty){
            _callTicketMasterApi();
          }else
            widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callTicketMasterApi() {
    RequestManager.getTicketMasterEvents(
        keyword: _searchText,
        onSuccess: (response) {
          try {
            var temp = List<EventTicketMaster>.from(
                response['events'].map((x) => EventTicketMaster.fromJson(x)));
            temp.forEach((element) {
              List<EventImage> images = [];
              if (!duplicateEvents.contains(
                  element.name + " " + element.embedded.venues[0].id)) {
                duplicateEvents.add(
                    element.name + " " + element.embedded.venues[0].id);
                images.add(EventImage(downloadlink: element.images[0].url));
                EventHomeModel model = EventHomeModel(id: 0,
                    eventId: 0,
                    vanueId: element.embedded.venues[0].id,
                    eventName: element.name,
                    startDate: element.dates.start.dateTime,
                    address: element.embedded.venues[0].name + ' ' +
                        element.embedded.venues[0].address.line1 + ' ' +
                        element.embedded.venues[0].city.name + ' ' +
                        element.embedded.venues[0].country.name,
                    details: '',
                    longitude: element.embedded.venues[0].location.longitude,
                    latitude: element.embedded.venues[0].location.latitude,
                    eventImages: images);
                _list.add(model);
              }
            });
          }catch(e){}
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  //make ticket master event in our DB
  void callCreateEvent(int index){
    var param = {
      Parameters.CeventId: 0,
      Parameters.CEventName: _list[index].eventName,
      Parameters.CStartDate: _list[index].startDate.toIso8601String(),
      Parameters.Caddress: _list[index].address,
      Parameters.Clatitude: _list[index].latitude,
      Parameters.Clongitude: _list[index].longitude,
      Parameters.CVanueId: _list[index].vanueId,
      Parameters.Cimage: _list[index].eventImages[0].downloadlink,
    };
    RequestManager.postRequest(
        uri: endPoints.CreateEventwithvanueId,
        body: param,
        isSuccessMessage: false,
        isLoader: true,
        onSuccess: (response) {
          CreateEventresult event = CreateEventresult.fromJson(response);
          _list[index].eventId = event.eventId;
          _list[index].id = event.id;
          _selectedIds.add(
              _list[index].eventId.toString());
          _selectedData.add(_list[index]);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: () {
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
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                    child: Icon(Icons.arrow_back_ios_outlined),
                  )),
              title: Text(
                LabelStr.lblAddEvents,
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
                            hintText: LabelStr.lblSearchEvents,
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
                        ? Container()
                        : _list.length == 0 && _searchText.isNotEmpty
                        ? Widgets.dataNotFound()
                        : _favoritelist())),
                Padding(
                  padding: const EdgeInsets.only(bottom: 26, top: 8),
                  child: Container(
                      child: ButtonRegular(
                          buttonText: LabelStr.lblSave,
                          onPressed: () {
                            rq.selectedEvents.clear();
                            rq.selectedEvents.addAll(_selectedData);
                            Get.back();
                          })),
                )
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
          _list.clear();
          _callEventsApi();
        }
      },
    );
  }

  resetSearch() {
    _list.clear();
    widgetRefresher.value = Utilities.getRandomString();
  }

  _favoritelist() {
    return Obx(() => ListView.builder(
      shrinkWrap: true,
      restorationId: widgetRefresher.value,
      itemCount: _list.length,
      itemBuilder: (context, index) {
        return Column(
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
                          _list[index].eventName.toTitleCase(),
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
                Center(
                  child: InkWell(
                    onTap: () {
                      if (!_selectedIds
                          .contains(_list[index].eventId.toString())) {
                        if(_selectedData.length < 20) {
                          _selectedIds.add(_list[index].eventId.toString());
                          _selectedData.add(_list[index]);
                        }else{
                          RequestManager.getSnackToast(title: LabelStr.lblLimitOver,message: Messages.CMoreThanEvent);
                        }

                      } else {
                        _selectedIds
                            .remove(_list[index].eventId.toString());
                        var removeIndex = 0;
                        _selectedData.forEach((element) {
                          if (element.eventId == _list[index].eventId) {
                            removeIndex = _selectedData.indexOf(element);
                          }
                        });
                        _selectedData.removeAt(removeIndex);
                      }
                      widgetRefresher.value = Utilities.getRandomString();
                    },
                    child: Container(
                      margin: EdgeInsets.all(3.0),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconPrimerColor,
                          border: Border.all(color: HexColor.borderColor)),
                      child: Center(
                          child: Icon(_selectedIds.contains(_list[index].eventId.toString()) ? Icons.remove : Icons.add,color: Colors.white,)
                      ),
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
                color: chatTextBorderColor,
              ),
            )
          ],
        );
      },
    ));
  }
}
