import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import '../Customs/ButtonRegular.dart';
import '../NavigationDrawerScreen.dart';
import '../SelectLocation.dart';

class BusinessAccount extends StatefulWidget {
  @override
  _BusinessAccountState createState() => _BusinessAccountState();
}

class _BusinessAccountState extends State<BusinessAccount> {
  var _legalNameController = TextEditingController();
  var _CommunicationIDController = TextEditingController();
  var _CommunicationPhoneController = TextEditingController();
  var _designationController = TextEditingController();
  var _organizationNameController = TextEditingController();
  var isButtonLoaderEnabled = false.obs;
  var addressStr = ''.obs;
  var latitude = 0.0;
  var longitude = 0.0;

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                      child: SvgPicture.asset(MyImage.ic_arrow),
                    )),
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        LabelStr.lblbusinessAccount,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: MyFont.Poppins_semibold,
                            color: Colors.white),
                      ),
                    ))
              ],
            ),
          ),
          SizedBox(
            height: dimen.dividerHeightLarge,
          ),
          Divider(
            color: dividerLineColor,
          ),
          Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(28),
                        left: ScreenUtil().setWidth(30),
                        right: ScreenUtil().setWidth(30)),
                    child: Column(
                      children: [
                        Container(
                            child: textFieldFor(
                                LabelStr.lbllegalName, _legalNameController,
                                autocorrect: false,
                                maxLength: 20,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.text)),
                        SizedBox(
                          height: dimen.dividerHeightHuge,
                        ),
                        Container(
                            child: textFieldFor(LabelStr.lblcommunication,
                                _CommunicationIDController,
                                autocorrect: false,
                                maxLength: 50,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.emailAddress)),
                        SizedBox(
                          height: dimen.dividerHeightHuge,
                        ),
                        Container(
                            child: textFieldFor(LabelStr.lblcommunicationPhone,
                                _CommunicationPhoneController,
                                autocorrect: false,
                                maxLength: 15,
                                isMobile: true,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.phone)),
                        SizedBox(
                          height: dimen.dividerHeightHuge,
                        ),
                        Container(
                           // width: MediaQuery.of(context).size.width,
                            child: textFieldFor(
                                LabelStr.lbldesignation, _designationController,
                                autocorrect: false,
                                maxLength: 20,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.text)),
                        SizedBox(
                          height: dimen.dividerHeightHuge,
                        ),
                        Container(
                            child: textFieldFor(LabelStr.lblorganizationName,
                                _organizationNameController,
                                autocorrect: false,
                                maxLength: 50,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.text)),
                        SizedBox(
                          height: dimen.dividerHeightHuge,
                        ),
                        Container(
                            //width: MediaQuery.of(context).size.width,
                            child: InkWell(
                                onTap: () async {
                                  var result = await Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              SelectLocation()));
                                  if (result != null) {
                                    addressStr.value = result[1]['placeName'];
                                    latitude = result[1]['lat'];
                                    longitude = result[1]['lng'];
                                  }
                                },
                                child: Obx(
                                  () => Container(
                                      padding: EdgeInsets.all(10),
                                      height: 70,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3)),
                                          border: Border.all(
                                              color: HexColor.borderColor)),
                                      child: Text(
                                        addressStr.value == ''
                                            ? LabelStr.lblorganizationAddress
                                            : addressStr.value,
                                        style: TextStyle(
                                          fontFamily: MyFont.Poppins_medium,
                                          fontSize: 14,
                                          color: (addressStr.value == '')
                                              ? MyColor.hintTextColor()
                                              : Colors.white,
                                        ),
                                      )),
                                ))),
                        SizedBox(height: dimen.dividerHeightHuge),
                        Container(
                          margin:
                              EdgeInsets.only(top: ScreenUtil().setHeight(30)),
                          child: Text(
                            LabelStr.lblaccountTitle,
                            style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.1,
                                fontFamily: MyFont.poppins_regular,
                                color: HexColor.textColor),
                          ),
                        ),
                        SizedBox(height: dimen.dividerHeightMedium),
                        RichText(
                          text: TextSpan(
                            text:
                                LabelStr.lblAccountTitleLink1,
                            style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.1,
                                fontFamily: MyFont.poppins_regular,
                                color: HexColor.textColor),
                            children: [
                              TextSpan(
                                  text: LabelStr.lblAccountTitleLink2,
                                  style: TextStyle(
                                      fontSize: 12,
                                      letterSpacing: 1.1,
                                      fontFamily: MyFont.poppins_regular,
                                      color: Colors.white),),
                              TextSpan(
                                  text: LabelStr.lblAccountTitleLink3,
                                  style: TextStyle(
                                      fontSize: 12,
                                      letterSpacing: 1.1,
                                      fontFamily: MyFont.poppins_regular,
                                      color: HexColor.textColor),),
                            ],
                          ),
                        )
                      ],
                    )),
              )),
          Padding(
            padding: EdgeInsets.only(
                bottom: ScreenUtil().setHeight(26),
                top: ScreenUtil().setHeight(26),
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30)),
            child: Obx(
              () => Container(
                  child: ButtonRegular(
                      buttonText: isButtonLoaderEnabled.value
                          ? null
                          : LabelStr.lblSubmitRequest,
                      onPressed: () {
                        _pressedOnBusinessAccount();
                      })),
            ),
          ),
        ],
      ),
    );
  }

  _pressedOnBusinessAccount() {
    if (_legalNameController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBlankLegalName);
      return;
    } else if (_CommunicationIDController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBCommunicationID);
      return;
    }  else if (_CommunicationIDController.text.isValidEmail() == false) {
      RequestManager.getSnackToast(message: Messages.CInvalidEmail);
      return;
    } else if (_CommunicationPhoneController.text.replaceAll('-', '').isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBCommunicationphone);
      return;
    } else if (_CommunicationPhoneController.text.replaceAll('-', '').length < 10) {
      RequestManager.getSnackToast(message: Messages.CInValidPhoneNumber);
      return;
    } else if (_designationController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBDesignation);
      return;
    } else if (_organizationNameController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBOrganizationName);
      return;
    } else if (addressStr.value.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBOrganizationAddress);
      return;
    }

    _callBusinessUserReq();
  }

  _callBusinessUserReq() {
    isButtonLoaderEnabled.value = true;
    var body = {
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CbusinessId: "0",
      Parameters.CLegal: _legalNameController.text,
      Parameters.CcomumuunicationEmailId: _CommunicationIDController.text,
      Parameters.CcomumuunicationPhone: _CommunicationPhoneController.text,
      Parameters.Cdesignation: _designationController.text,
      Parameters.CorganizationName: _organizationNameController.text,
      Parameters.CorganizationAddress: addressStr.value,
    };
    RequestManager.postRequest(
        uri: endPoints.businessUserReq,
        body: body,
        isSuccessMessage: false,
        onSuccess: (response) {
          isButtonLoaderEnabled.value = false;
          UserInfoModel user =
          (SessionImpl.getLoginProfileModel() as UserInfoModel);
          user.isBusinessRequestSend = true;
          SessionImpl.setLoginProfileModel(user);
          Get.back();
          RequestManager.getSnackToast(
              title: LabelStr.lblSubmitted,
              message:
                  Messages.CBusinessAccount,
              colorText: Colors.white,
              backgroundColor: Colors.black );
        },
        onFailure: () {
          isButtonLoaderEnabled.value = false;
        });
  }
}
