import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/DatePicker.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/SocialLogin.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Setting/ApplyforVerifcation.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';

import '../Customs/ButtonRegular.dart';
import '../LRF/VerificationScreen.dart';

class PersonalInformation extends StatefulWidget {

  @override
  _PersonalInformationState createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  var _emailController = TextEditingController();
  var _phoneController = TextEditingController();
  var _usernameController = TextEditingController();
  var countryCode = "+1";
  var isButtonLoaderEnabled = false.obs;
  var bdateStrDialog = ''.obs;
  DateTime bdayDate;
  var bdateStr;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _usernameController.text = user.username;
    bdateStr = user.birthDate;
    if(user.isEmailVerified == false){
      _isVisible = true;
    }else{
      _isVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(49),
            left: ScreenUtil().setWidth(30),
            right: ScreenUtil().setWidth(30)),
        child: Column(
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
                      padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                      child: SvgPicture.asset(MyImage.ic_arrow),
                    )),
                Expanded(flex: 1,
                    child: Center(
                      child: Text(
                        LabelStr.lblPersonalInformation,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: MyFont.Poppins_semibold,
                            color: Colors.white),
                      ),
                    )),
              ],
            ),
            SizedBox(
              height: dimen.paddingExtra,
            ),
            Container(
                child: textFieldFor(LabelStr.lblEmail, _emailController,
                    textInputAction: TextInputAction.next,
                    maxLength: 50,
                    textCapitalization: TextCapitalization.none,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(dimen.paddingLarge),
                      child: Visibility(
                         visible: _isVisible,
                        child: InkWell(
                          onTap: (){
                            UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
                            if(user.isEmailVerified == false){
                              _callResendMailverify();
                            }

                          },
                          child: Text(LabelStr.lblVerify,
                            style: TextStyle(
                              fontSize: 12,
                              color: purpleTextColor,
                              decoration: TextDecoration.underline,
                              fontFamily: MyFont.Poppins_medium,
                            ),
                          ),
                        ),
                      ),
                    ),
                    prefixIcon: Container(
                      padding: EdgeInsets.all(13),
                      child: SvgPicture.asset(MyImage.ic_email),
                    ),
                    keyboardType: TextInputType.emailAddress)
            ),
            SizedBox(
              height: dimen.paddingBig,
            ),
            Container(
                child: Row(
                  children: [
                    CountryCodePicker(
                      onChanged: (code) {
                        countryCode = code.dialCode;
                      },
                      dialogBackgroundColor: appColorExtraLight,
                      backgroundColor: screenBgColor,
                      initialSelection: 'US',
                      showCountryOnly: false,
                      alignLeft: false,
                      padding: const EdgeInsets.only(bottom: dimen.paddingBig),
                      textStyle: AppTheme.regularSFTextStyle(),
                    ),
                    Expanded(
                      child: textFieldFor(
                          LabelStr.lblphone, _phoneController,
                          autocorrect: false,
                          maxLength: 15,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          isMobile: true,
                          prefixIcon: Container(
                            padding: EdgeInsets.all(13),
                            child: SvgPicture.asset(MyImage.ic_phone),
                          ),
                          keyboardType: TextInputType.phone),
                    ),

                  ],
                )),
            SizedBox(
              height: dimen.paddingBig,
            ),
            Container(
                child: textFieldFor(
                    LabelStr.lblUserName, _usernameController,
                    autocorrect: false,
                    maxLength: 20,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    prefixIcon: Container(
                      padding: EdgeInsets.all(13),
                      child: SvgPicture.asset(MyImage.ic_person),
                    ),
                    keyboardType: TextInputType.text)),
            SizedBox(
              height: dimen.paddingBig,
            ),
            InkWell(
              onTap: () {
                DatePicker()
                    .selectDate('MM-dd-yyyy', bdayDate, context)
                    .then((selectedDate) =>
                    setState(() {
                      bdateStr = selectedDate['selectedDate'];
                      bdayDate = selectedDate['date'];
                    }));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    border: Border.all(color: HexColor.borderColor)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(dimen.paddingSmall),
                      alignment: Alignment.topLeft,
                      child: Text(
                        (bdateStr == null) ? LabelStr.lblbirthdate : bdateStr,
                        style: TextStyle(
                          fontFamily: MyFont.Poppins_medium,
                          fontSize: 14,
                          color: (bdateStr == null)
                              ? MyColor.hintTextColor()
                              : Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SvgPicture.asset(MyImage.ic_calendar),
                    )
                  ],
                ),
              ),
            ),
            Expanded(flex: 1,
                child: Container()),
            Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(26)),
              child: Obx(
                    () =>
                    Container(
                        child: ButtonRegular(
                            buttonText: isButtonLoaderEnabled.value
                                ? null
                                : LabelStr.lblSave,
                            onPressed: () {
                              _pressedOnSumitInfo();
                            })),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _pressedOnSumitInfo() {
    if (_emailController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBlankEmail,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    } else if (!_emailController.text.isValidEmail()) {
      RequestManager.getSnackToast(message: Messages.CInvalidEmail,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    } else if (_phoneController.text.replaceAll('-', '').isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBlankPhoneNumber,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    } else if (_phoneController.text.replaceAll('-', '').length < 10) {
      RequestManager.getSnackToast(message: Messages.CInValidPhoneNumber,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    } else if (_usernameController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBlankUserName,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    } else if (bdateStr == null) {
      RequestManager.getSnackToast(message: Messages.CBlankBirthDate,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    } else if (!DatePicker.isAdult2(bdateStr)) {
      RequestManager.getSnackToast(message: Messages.CValidBirthDate,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    }
    UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
    if(user.phone != _phoneController.text.replaceAll('-', '')){
      Map<String, dynamic> params = {
        Parameters.CPhone: _phoneController.text.replaceAll('-', ''),
      };
      _phoneNumberVerification(params);
    }else{
      _callPersonallinfoApi();
    }
  }

  _callPersonallinfoApi() {
    isButtonLoaderEnabled.value = true;
    UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
    var body = {
      Parameters.CFirstName: user.firstname,
      Parameters.CLastName: user.lastname,
      Parameters.CEmail: _emailController.text,
      Parameters.CPhone: _phoneController.text.replaceAll('-', ''),
      Parameters.CBirthDate: bdateStr,
      Parameters.CUserName: _usernameController.text,
      Parameters.CPassword: "",
      Parameters.CRole: user.role,
      Parameters.Cid: user.id,
      Parameters.Caddress: user.address,
      Parameters.Clatitude: user.latitude,
      Parameters.Clongitude: user.longitude,
      Parameters.Cbio: user.bio,
    };


    RequestManager.postRequest(
        uri: endPoints.updateUser,
        body: body,
        isSuccessMessage: false,
        onSuccess: (response) {
          isButtonLoaderEnabled.value = false;
          UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
           user.email= _emailController.text;
           user.phone = _phoneController.text.replaceAll('-', '');
           user.birthDate = bdateStr;
           user.username = _usernameController.text;
          SessionImpl.setLoginProfileModel(user);
          Get.back();
          RequestManager.getSnackToast(
              title: LabelStr.lblUpdateSuccessfully,
              backgroundColor: Colors.black,
              message: Messages.CUpdatePersonalInfo);
        },

        onFailure: (error) {
          isButtonLoaderEnabled.value = false;
        });
  }

  _phoneNumberVerification(Map<String, dynamic> params) {
    Widgets.showLoading();
    VerifyPhoneNumber().registerPhoneNumber(
        params[Parameters.CPhone], countryCode, context, (verificationId) {
      Widgets.loadingDismiss();
      Get.to(VerificationScreen(verificationId, params, countryCode,true)).then((value) => _handleVerify(value));
    });
  }

  _handleVerify(bool isVerify){
    if(isVerify) _callPersonallinfoApi();
  }

  void _callResendMailverify(){
    var body = {
      Parameters.Cid: SessionImpl.getId(),
    };

    RequestManager.postRequest(
        uri: endPoints.ResendMailverify,
        body: body,
        onSuccess: (response){
          RequestManager.getSnackToast(
              title: LabelStr.lblSent,
              backgroundColor: Colors.black,
              message: Messages.CEmailVerification);
        },
        onFailure: (error){

        });
  }

}
