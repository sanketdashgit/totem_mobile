import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/DateTimePicker.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Ui/Event/CreateEventUploadImage.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import '../SelectLocation.dart';

class CreateEvent extends StatefulWidget {

  @override
  _CreateEventState createState() => _CreateEventState();
}
//comment in sanket branch

class _CreateEventState extends State<CreateEvent> {
  var _eventNameController = TextEditingController();

  var _detailsController = TextEditingController();

  var isButtonLoaderEnabled = false.obs;

  DateTime stEventDT = DateTime.now();
  DateTime stCurrentDt = DateTime.now();
  DateTime endEventDT = DateTime.now();
  String eventStDate, eventEndDate;

  var tempStTime, tempEndTime;

  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay startTime, endTime;
  var eventStTime = ''.obs;
  var eventEndTime = ''.obs;

  var addressStr = ''.obs;
  var latitude = 0.0;
  var longitude = 0.0;
  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (rq.isEditEvent.value) {
      _eventNameController.text = rq.eventDetails.value.eventName;
      stEventDT = rq.eventDetails.value.startDate;
      endEventDT = rq.eventDetails.value.endDate;
      eventStDate = getDateFromUtc(rq.eventDetails.value.startDate);
      eventStTime.value = getTimeFromUtc(rq.eventDetails.value.startDate);
      eventEndDate = getDateFromUtc(rq.eventDetails.value.endDate);
      eventEndTime.value = getTimeFromUtc(rq.eventDetails.value.endDate);
      addressStr.value = rq.eventDetails.value.address;
      latitude = double.parse(rq.eventDetails.value.latitude);
      longitude = double.parse(rq.eventDetails.value.longitude);
      _detailsController.text = rq.eventDetails.value.details;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Padding(
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(54), left: 30.0, right: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.all(dimen.paddingForBackArrow),
                          child: SvgPicture.asset(MyImage.ic_arrow),
                        )),
                    Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            rq.isEditEvent.value
                                ? LabelStr.lblEditEventTitle
                                : LabelStr.lblCreateEventTitle,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: MyFont.Poppins_semibold,
                                color: Colors.white),
                          ),
                        ))
                  ],
                ),
                SizedBox(
                  height: dimen.dividerHeightHuge,
                ),
                _tabController(),
                SizedBox(
                  height: dimen.dividerHeightHuge,
                ),
              ],
            ),
            Obx(
              () => Expanded(
                flex: 1,
                child: SingleChildScrollView(
                    child: Padding(
                  padding: EdgeInsets.only(bottom: dimen.paddingVerySmall),
                  child: Column(
                    children: [
                      Container(
                          child: textFieldFor(
                              LabelStr.lbleventname, _eventNameController,
                              autocorrect: false,
                              maxLength: 50,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.text)),
                      SizedBox(
                        height: dimen.dividerHeightHuge,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              DateTimePicker()
                                  .selectDate('dd MMM yyyy', stCurrentDt,
                                      stEventDT, context)
                                  .then((selectedDate) => setState(() {
                                        eventStDate =
                                            selectedDate['selectedDate'];
                                        stEventDT = selectedDate['date'];
                                      }));
                            },
                            child: Container(
                              height: dimen.formTextFieldHeight,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                  border:
                                      Border.all(color: HexColor.borderColor)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        left: dimen.paddingSmall),
                                    child: Text(
                                      (eventStDate == null)
                                          ? LabelStr.lblstartdate
                                          : eventStDate,
                                      style: TextStyle(
                                        fontFamily: MyFont.Poppins_medium,
                                        fontSize: 12,
                                        color: (eventStDate == null)
                                            ? MyColor.hintTextColor()
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child:
                                        SvgPicture.asset(MyImage.ic_calendar),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              tempStTime = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                  builder:
                                      (BuildContext context, Widget child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false),
                                      child: child,
                                    );
                                  });
                              eventStTime.value = getTimeIn12Format(tempStTime);
                            },
                            child: Container(
                              height: dimen.formTextFieldHeight,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                  border:
                                      Border.all(color: HexColor.borderColor)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  // Obx(() =>
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        left: dimen.paddingSmall),
                                    child: Text(
                                      (eventStTime.value.isEmpty)
                                          ? LabelStr.lblstarttime
                                          : eventStTime.value,
                                      style: TextStyle(
                                        fontFamily: MyFont.Poppins_medium,
                                        fontSize: 12,
                                        color: (eventStTime.value.isEmpty)
                                            ? MyColor.hintTextColor()
                                            : Colors.white,
                                      ),
                                    ),
                                    // )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child:
                                        SvgPicture.asset(MyImage.ic_calendar),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: dimen.dividerHeightHuge,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              DateTimePicker()
                                  .selectDate('dd MMM yyyy', stEventDT,
                                      stEventDT, context)
                                  .then((selectedDate) => setState(() {
                                        eventEndDate =
                                            selectedDate['selectedDate'];
                                        endEventDT = selectedDate['date'];
                                      }));
                            },
                            child: Container(
                              height: dimen.formTextFieldHeight,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                  border:
                                      Border.all(color: HexColor.borderColor)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        left: dimen.paddingSmall),
                                    child: Text(
                                      (eventEndDate == null)
                                          ? LabelStr.lblenddate
                                          : eventEndDate,
                                      style: TextStyle(
                                        fontFamily: MyFont.Poppins_medium,
                                        fontSize: 12,
                                        color: (eventEndDate == null)
                                            ? MyColor.hintTextColor()
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child:
                                        SvgPicture.asset(MyImage.ic_calendar),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              tempEndTime = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                  builder:
                                      (BuildContext context, Widget child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          alwaysUse24HourFormat: false),
                                      child: child,
                                    );
                                  });
                              eventEndTime.value =
                                  getTimeIn12Format(tempEndTime);
                              _openAddress();
                            },
                            child: Container(
                              height: dimen.formTextFieldHeight,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                  border:
                                      Border.all(color: HexColor.borderColor)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  // Obx(() =>
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(
                                        left: dimen.paddingSmall),
                                    child: Text(
                                      (eventEndTime.value.isEmpty)
                                          ? LabelStr.lblendtime
                                          : eventEndTime.value,
                                      style: TextStyle(
                                        fontFamily: MyFont.Poppins_medium,
                                        fontSize: 12,
                                        color: (eventEndTime.value.isEmpty)
                                            ? MyColor.hintTextColor()
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  // ),
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child:
                                        SvgPicture.asset(MyImage.ic_calendar),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: dimen.dividerHeightHuge,
                      ),
                      InkWell(
                        onTap: () async {
                          _openAddress();
                        },
                        child: Container(
                            padding: EdgeInsets.all(10),
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                                border:
                                    Border.all(color: HexColor.borderColor)),
                            child: Text(
                              addressStr.value == ''
                                  ? LabelStr.lbladdressvenue
                                  : addressStr.value,
                              style: TextStyle(
                                fontFamily: MyFont.Poppins_medium,
                                fontSize: 12,
                                color: (addressStr.value == '')
                                    ? MyColor.hintTextColor()
                                    : Colors.white,
                              ),
                            )),
                      ),
                      SizedBox(
                        height: dimen.dividerHeightHuge,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: TextField(
                          controller: _detailsController,
                          autocorrect: false,
                          focusNode: focusNode,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          maxLength: 500,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1.1,
                                  color: MyColor.textFieldBorderColor()),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1,
                                  color: MyColor.textFieldBorderColor()),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1,
                                  color: MyColor.textFieldBorderColor()),
                            ),
                            hintText: LabelStr.lbldetails,
                            counterStyle: TextStyle(
                              color: colorHintText,
                              fontFamily: MyFont.poppins_regular,
                            ),
                            hintStyle: TextStyle(
                              color: colorHintText,
                              fontFamily: MyFont.poppins_regular,
                            ),
                          ),
                          style: TextStyle(
                              color: whiteTextColor,
                              fontFamily: MyFont.poppins_regular,
                              fontSize: dimen.textNormal),
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ),
            Obx(
              () => Container(
                margin: EdgeInsets.only(
                    bottom: dimen.marginNormal, top: dimen.marginNormal),
                decoration: BoxDecoration(
                    color: buttonPrimary,
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                child: ButtonRegular(
                  buttonText:
                      isButtonLoaderEnabled.value ? null : LabelStr.lblNext,
                  onPressed: () {
                    _pressedOnCreateProfile();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
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

  String getTimeIn12Format(var tempTime) {
    var hr = tempTime.hour;

    if (int.parse(tempTime.hour.toString()) > 12)
      hr = tempTime.hour.toInt() - 12;

    return hr.toString() +
        ":" +
        tempTime.minute.toString() +
        (tempTime.period.index == 0 ? " AM" : " PM");
  }

  Widget _tabController() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(10),
              right: ScreenUtil().setWidth(10)),
          child: Row(
            children: [
              _circleContainer(true),
              _lineContainer(false),
              _circleContainer(false),
              _lineContainer(false),
              _circleContainer(false),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LabelStr.lblbsasicInfo,
                style: TextStyle(
                    fontFamily: MyFont.poppins_regular,
                    fontSize: 12,
                    color: Colors.white),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  LabelStr.lbladdphoto,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: 12,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text(
                  LabelStr.lblreview,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: 12,
                      color: Colors.grey),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _circleContainer(bool isActive) {
    return Container(
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setHeight(30),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: isActive
                  ? purpleTextColor
                  : greyTextColor,
              width: 2)),
    );
  }

  Widget _lineContainer(bool isActive) {
    return Expanded(
      child: Divider(
        color: isActive
            ? purpleTextColor
            : greyTextColor,
        height: 8.0,
      ),
    );
  }

  _pressedOnCreateProfile() {
    if (_eventNameController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEventName,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (eventStDate == null) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEventStartDate,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (eventEndDate == null) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEventEndDate,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (eventStTime.value.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEventStartTime,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (eventEndTime.value.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEventEndDate,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (addressStr.value.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEventAddVenue,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_detailsController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEventDetails,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    }

    DateTime endTD;
    DateTime stTD;
    if (tempStTime != null)
      stTD = convertToUtc(eventStDate, tempStTime);
    else
      stTD = new DateFormat("dd MMM yyyy HH:mm:ss")
          .parse(eventStDate + ' ' + eventStTime.value);

    if (tempEndTime != null)
      endTD = convertToUtc(eventEndDate, tempEndTime);
    else
      endTD = new DateFormat("dd MMM yyyy HH:mm:ss")
          .parse(eventEndDate + ' ' + eventEndTime.value);

    if (stTD.isAfter(endTD)) {
      RequestManager.getSnackToast(message: Messages.CEventDates);
      return;
    }

    rq.createEventName.value = _eventNameController.text.toString();
    // rq.createEventStartDate.value = eventStDate;
    rq.createEventStartDate.value =
        DateFormat('EEE d MMM yyyy').format(stEventDT);
    rq.createEventStartTime.value = eventStTime.value;
    rq.createEventEndDate.value =
        DateFormat('EEE d MMM yyyy').format(endEventDT);
    rq.createEventEndTime.value = eventEndTime.value;
    rq.createEventEndTime.value = eventEndTime.value;
    rq.startDate.value = stTD.toUtc().toString();
    rq.endDate.value = endTD.toUtc().toString();
    rq.createEventAddressVenue.value = addressStr.value;
    rq.createEventCity.value = '';
    rq.createEventState.value = '';
    rq.createEventLat.value = latitude;
    rq.createEventLong.value = longitude;
    rq.createEventDetails.value = _detailsController.text.toString();

    Get.to(CreateEventUploadImage());
  }

  DateTime convertToUtc(String date, var time) {
    DateTime parseDate = new DateFormat("dd MMM yyyy HH:mm:ss").parse(date +
        " " +
        time.hour.toString() +
        ":" +
        time.minute.toString() +
        ":00");
    return parseDate;
    //.toUtc().toString()
  }

  String getDateFromUtc(DateTime date) {
    final convertLocal = date.toLocal();
    return DateFormat('dd MMM yyyy').format(convertLocal);
  }

  String getTimeFromUtc(DateTime date) {
    final convertLocal = date.toLocal();
    return DateFormat('hh:mm:ss a').format(convertLocal);
  }
}
