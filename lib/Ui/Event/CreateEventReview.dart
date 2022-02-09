import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/CreateEventModel.dart';
import 'package:totem_app/Models/EventHomeModel.dart';
import 'package:totem_app/Ui/Customs/ButtonHalfWidth.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';


class CreateEventReview extends StatefulWidget {
  @override
  _CreateEventReview createState() => _CreateEventReview();
}
//comment in sanket branch

class _CreateEventReview extends State<CreateEventReview> {
  var isButtonLoaderEnabled = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Padding(
          padding: EdgeInsets.only(
              top: ScreenUtil().setHeight(54),
              left: dimen.paddingBigLarge,
              right: dimen.paddingBigLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                            child: SvgPicture.asset(MyImage.ic_arrow),
                          )),
                      Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              LabelStr.lbleventdetails,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: MyFont.Poppins_semibold,
                                  color: Colors.white),
                            ),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 27.0,
                  ),
                  _tabController(),
                  SizedBox(
                    height: dimen.marginLarge,
                  ),
                ],
              ),
              Obx(() => Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        imagePicker(rq.createEventImage.value.isEmpty? rq.coverUrl.value :rq.createEventImage.value),
                        SizedBox(
                          height: dimen.marginLarge,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(

                              rq.createEventName.value,
                              style: TextStyle(
                                  fontFamily: MyFont.Poppins_semibold,
                                  fontSize: dimen.textExtraMedium,
                                  color: whiteTextColor),
                              maxLines: 1,
                              overflow:TextOverflow.ellipsis,
                            ),
                            Text(
                              rq.createEventStartDate.value +
                                  " at " +
                                  rq.createEventStartTime.value,
                              style: TextStyle(
                                  fontFamily: MyFont.poppins_regular,
                                  fontSize: dimen.textSemiNormal,
                                  color: whiteTextColor),
                              maxLines: 1,
                            ),
                            SizedBox(
                              height: dimen.paddingSmall,
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(MyImage.ic_event_name_flag),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: dimen.paddingSmall,
                                  ),
                                  child: Text(
                                    '${LabelStr.lblEventBy} ' + SessionImpl.getName(),
                                    style: TextStyle(
                                        fontFamily: MyFont.poppins_regular,
                                        fontSize: dimen.textNormal,
                                        color: textColorGreyLight),
                                    maxLines: 1,
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              height: dimen.dividerHeightLarge,
                              color: createEventReviewDividerColor,
                            ),
                            Text(
                              LabelStr.lbldescription,
                              style: TextStyle(
                                  fontFamily: MyFont.Poppins_medium,
                                  fontSize: dimen.textNormal,
                                  color: whiteTextColor),
                              maxLines: 1,
                            ),
                            Text(
                              rq.createEventDetails.value,
                              style: TextStyle(
                                  fontFamily: MyFont.poppins_regular,
                                  fontSize: dimen.textSmall,
                                  color: whiteTextColor),
                            ),
                            Divider(
                              height: dimen.dividerHeightLarge,
                              color: createEventReviewDividerColor,
                            ),
                            Text(
                              LabelStr.lbladdressvenue,
                              style: TextStyle(
                                  fontFamily: MyFont.Poppins_semibold,
                                  fontSize: dimen.textNormal,
                                  color: whiteTextColor),
                              maxLines: 1,
                            ),
                            SizedBox(
                              height: dimen.paddingSmall,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(MyImage.ic_map_pin),
                                Flexible(
                                    child: Padding(
                                  padding: EdgeInsets.only(
                                    left: dimen.paddingSmall,
                                  ),
                                  child: Text(
                                    rq.createEventAddressVenue.value +
                                        " " +
                                        rq.createEventCity.value +
                                        " " +
                                        rq.createEventState.value,
                                    style: TextStyle(
                                        fontFamily: MyFont.poppins_regular,
                                        fontSize: dimen.textNormal,
                                        color: textColorGreyLight),
                                  ),
                                ))
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))),
              Container(
                margin: EdgeInsets.only(
                    top: dimen.marginNormal, bottom: dimen.marginNormal),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        // height: 55,
                        decoration: BoxDecoration(
                            color: buttonPrimary,
                            borderRadius: BorderRadius.all(Radius.circular(3))),
                        child: ButtonHalfWidth(
                          width: MediaQuery.of(context).size.width * 0.4,
                          fillColor: buttonPrimary,
                          buttonText: isButtonLoaderEnabled.value
                              ? null
                              : LabelStr.lblNext,
                          onPressed: () {
                            _pressedToSaveData();
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                          color: buttonPrimary,
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: ButtonHalfWidth(
                        width: MediaQuery.of(context).size.width * 0.4,
                        prefixIcon: MyImage.ic_delete,
                        fillColor: buttonRed,
                        buttonText: LabelStr.lbldelete,
                        onPressed: () {
                          _pressedToDeleteData();
                        },
                      ),
                      // ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
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
              _circleContainerTic(),
              _lineContainer(true),
              _circleContainerTic(),
              _lineContainer(true),
              _circleContainer(true),
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
                    fontSize: dimen.textSmall,
                    color: purpleTextColor),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  LabelStr.lbladdphoto,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: dimen.textSmall,
                      color: purpleTextColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text(
                  LabelStr.lblreview,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: dimen.textSmall,
                      color: whiteTextColor),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget imagePicker(String cropImagePath) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.56,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: cropImagePath == ''
                ? Image.asset(
                    MyImage.ic_preview,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.56,
                    fit: BoxFit.cover,
                  )
                : rq.createEventImage.value.isEmpty
                    ? Image(
                        image: NetworkImage(cropImagePath),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.56,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(cropImagePath),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.56,
                      ),
          ),
        ],
      ),
    );
  }

  Widget _circleContainer(bool isActive) {
    return Container(
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setHeight(30),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: isActive ? purpleTextColor : greyTextColor, width: 2)),
    );
  }

  Widget _circleContainerTic() {
    return Container(
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setHeight(30),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: purpleTextColor, width: 2)),
      child: Padding(
          padding: const EdgeInsets.all(dimen.paddingVerySmall),
          child: SvgPicture.asset(MyImage.ic_done)),
    );
  }

  Widget _lineContainer(bool isActive) {
    return Expanded(
      child: Divider(
        color: isActive ? purpleTextColor : greyTextColor,
        height: 8.0,
      ),
    );
  }

  _pressedToDeleteData() {
    if(!rq.isEditEvent.value) {
      rq.createEventName.value = '';
      rq.startDate.value = '';
      rq.endDate.value = '';
      rq.createEventAddressVenue.value = '';
      rq.createEventCity.value = '';
      rq.createEventState.value = '';
      rq.createEventDetails.value = '';
      rq.createEventLat.value = 0;
      rq.createEventLong.value = 0;
      _goBack();
    }else{
      showAlertDialogLogout(context);
    }
  }
  showAlertDialogLogout(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(LabelStr.lblCancel),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: Text(LabelStr.lblRemove),
      onPressed: () {
        Get.back();
       removeEvent();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("${LabelStr.lblRemove}?"),
      content: Text(Messages.CEventRemoveMessage),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  _pressedToSaveData() {
    isButtonLoaderEnabled.value = true;
    var param = {
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CeventId: rq.isEditEvent.value ? rq.eventDetails.value.eventId : '0',
      Parameters.CEventName: rq.createEventName.value,
      Parameters.CStartDate: rq.startDate.value,
      Parameters.CEndDate: rq.endDate.value,
      Parameters.Caddress: rq.createEventAddressVenue.value,
      Parameters.CCity: rq.createEventCity.value,
      Parameters.CState: rq.createEventState.value,
      Parameters.Cdetails: rq.createEventDetails.value,
      Parameters.Clatitude: rq.createEventLat.value,
      Parameters.Clongitude: rq.createEventLong.value
    };
    _callCreateEvent(param, false);
  }

  _callCreateEvent(Map<String, dynamic> params, bool isLoader) {
    RequestManager.postRequest(
        uri: endPoints.createEvent,
        body: params,
        isSuccessMessage: false,
        isLoader: isLoader,
        onSuccess: (response) {
          CreateEventresult event = CreateEventresult.fromJson(response);
          _checkNextFileToUpload(0,event.eventId);
        },
        onFailure: () {
          isButtonLoaderEnabled.value = false;
        });
  }

  _uploadImage(image, String documentType, int eventId,int index) async {
    RequestManager.uploadImage(
        uri: endPoints.eventFileUpload,
        isLoader: false,
        moduleType: documentType,
        file: File(image),
        moduleId: eventId,
        onSuccess: (response) {
          index++;
          _checkNextFileToUpload(index,eventId);
        },
        onFailure: () {
          index++;
          _checkNextFileToUpload(index,eventId);
        });
  }

  _checkNextFileToUpload(int index,int eventId){
    if(index == 0) {
      if (rq.createEventImage.value.isNotEmpty) {
        _uploadImage(rq.createEventImage.value, LabelStr.lblCover, eventId, 0);
      } else {
        _checkNextFileToUpload(1, eventId);
        return;
      }
    }
    if(index ==1) {
      if (rq.createEventImage1.value.isNotEmpty && index == 1)
        _uploadImage(rq.createEventImage1.value, LabelStr.lblMap, eventId, 1);
      else {
        _checkNextFileToUpload(2, eventId);
        return;
      }
    }
    if(index == 2) {
      if (rq.createEventImage2.value.isNotEmpty && index == 2)
        _uploadImage(rq.createEventImage2.value, LabelStr.lblHeadliners, eventId, 2);
      else {
        _checkNextFileToUpload(3, eventId);
        return;
      }
    }
    if(index == 3){
      if (rq.isEditEvent.value) {
        _callEventDetails({
          Parameters.CUserId: SessionImpl.getId(),
          Parameters.CeventId: eventId
        }, false);
      } else {
        _goBack();
      }
    }

  }

  _callEventDetails(Map<String, dynamic> params, bool isLoader) {
    RequestManager.postRequest(
        uri: endPoints.getByEventID,
        body: params,
        isLoader: isLoader,
        isSuccessMessage: false,
        onSuccess: (response) {
          rq.eventDetails.value = EventHomeModel.fromJson(response);
          if (rq.eventDetails.value.eventImages.length != 0) {
            for (int i = 0; i < rq.eventDetails.value.eventImages.length; i++) {
              if (rq.eventDetails.value.eventImages[i].fileType == LabelStr.lblCover)
                rq.coverUrl.value =
                    rq.eventDetails.value.eventImages[i].downloadlink;
              if (rq.eventDetails.value.eventImages[i].fileType == LabelStr.lblMap)
                rq.mapUrl.value =
                    rq.eventDetails.value.eventImages[i].downloadlink;
              if (rq.eventDetails.value.eventImages[i].fileType == LabelStr.lblHeadliners)
                rq.lineupUrl.value =
                    rq.eventDetails.value.eventImages[i].downloadlink;
            }
          }
          rq.eventList[rq.editEventIndex] = rq.eventDetails.value;
          _goBack();
        },
        onFailure: () {
          _goBack();
        });
  }

  _goBack(){
    Get.back();
    Get.back();
    Get.back();
  }

  void removeEvent() {
    var body = {
      Parameters.CUserId: SessionImpl.getId(),
      Parameters.CeventId: rq.eventDetails.value.eventId,
    };
    RequestManager.postRequest(
        uri: endPoints.removeEvent,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: true,
        onSuccess: (response) {
          rq.eventList.removeAt(rq.editEventIndex);
          _goBack();
          Get.back();
          RequestManager.getSnackToast(title: LabelStr.lblRemoved,message: Messages.Cremovedsuccessfully,backgroundColor: Colors.black);
        },
        onFailure: (error) {});
  }
}
