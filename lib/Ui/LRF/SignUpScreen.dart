import 'dart:core';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:fdottedline/fdottedline.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/CommonStuff.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/DatePicker.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/SocialLogin.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Ui/LRF/SignInScreen.dart';
import 'package:totem_app/Ui/LRF/TermAndConditionScreen.dart';
import 'package:totem_app/Ui/LRF/VerificationScreen.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  RxBool isAcceptTermsCondition = true.obs;
  var _firstNameController = TextEditingController();
  var _lastNameController = TextEditingController();
  var _emailController = TextEditingController();
  var _usernameController = TextEditingController();
  var _usernameControllerDialog = TextEditingController();
  var _phoneController = TextEditingController();
  var _passwordController = TextEditingController();
  var _conformpasswordController = TextEditingController();
  var _socailPhoneController = TextEditingController();

  DateTime bdayDate;
  var bdateStr;
  var bdateStrFinal;
  var bdateStrDialog = ''.obs;
  var countryCode = "+1";

  GoogleSignInClass googleSignInClass = GoogleSignInClass();
  FaceBookSignInClass faceBookSignInClass = FaceBookSignInClass();
  var isButtonLoaderEnabled = false.obs;
  var isShow = false.obs;
  var isShowConfirm = false.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(80),
                  left: ScreenUtil().setWidth(30),
                  right: ScreenUtil().setWidth(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LabelStr.lblsignup,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontFamily: MyFont.Poppins_semibold),
                  ),
                  SizedBox(
                    height: dimen.paddingBig,
                  ),
                  Container(
                      child: textFieldFor(
                          LabelStr.lblFullName, _firstNameController,
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
                    height: dimen.paddingMedium,
                  ),
                  Container(
                      child: textFieldFor(
                          LabelStr.lblLastName, _lastNameController,
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
                    height: dimen.paddingMedium,
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
                    height: dimen.paddingMedium,
                  ),
                  Container(
                      child: textFieldFor(LabelStr.lblEmailId, _emailController,
                          textInputAction: TextInputAction.next,
                          maxLength: 50,
                          textCapitalization: TextCapitalization.none,
                          prefixIcon: Container(
                            padding: EdgeInsets.all(13),
                            child: SvgPicture.asset(MyImage.ic_email),
                          ),
                          keyboardType: TextInputType.emailAddress)),
                  SizedBox(
                    height: dimen.paddingMedium,
                  ),
                  Container(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        padding: const EdgeInsets.all(0),
                        textStyle: AppTheme.regularSFTextStyle(),
                      ),
                      Expanded(
                        child: textFieldFor(LabelStr.lblphone, _phoneController,
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
                    height: dimen.paddingMedium,
                  ),
                  InkWell(
                    onTap: () {
                      DatePicker()
                          .selectDate('MM-dd-yyyy', bdayDate, context)
                          .then((selectedDate) => setState(() {
                                bdateStr = selectedDate[Parameters.CSelectedDate];
                                bdayDate = selectedDate[Parameters.CDate];
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
                            margin: EdgeInsets.all(10.0),
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
                  SizedBox(
                    height: dimen.paddingMedium,
                  ),
                  Container(
                      child: textFieldFor(
                          LabelStr.lblpassword, _passwordController,
                          autocorrect: false,
                          obscure: !isShow.value,
                          maxLength: 15,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          prefixIcon: Container(
                            padding: EdgeInsets.all(13),
                            child: SvgPicture.asset(MyImage.ic_lock),
                          ),
                          keyboardType: TextInputType.text,
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isShow.value
                                      ? isShow.value = false
                                      : isShow.value = true;
                                });
                              },
                              child: isShow.value
                                  ? Icon(Icons.visibility,
                                      color: MyColor.hintTextColor())
                                  : Icon(Icons.visibility_off,
                                      color: MyColor.hintTextColor())))),
                  SizedBox(
                    height: dimen.paddingMedium,
                  ),
                  Container(
                      child: textFieldFor(LabelStr.lblconfirmpassword,
                          _conformpasswordController,
                          autocorrect: false,
                          obscure: !isShowConfirm.value,
                          maxLength: 15,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.none,
                          prefixIcon: Container(
                            padding: EdgeInsets.all(13),
                            child: SvgPicture.asset(MyImage.ic_lock),
                          ),
                          keyboardType: TextInputType.text,
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isShowConfirm.value
                                      ? isShowConfirm.value = false
                                      : isShowConfirm.value = true;
                                });
                              },
                              child: isShowConfirm.value
                                  ? Icon(Icons.visibility,
                                  color: MyColor.hintTextColor())
                                  : Icon(Icons.visibility_off,
                                  color: MyColor.hintTextColor())))),
                  //_singleCheckbox(),
                  SizedBox(
                    height: dimen.paddingBig,
                  ),
                  Obx(() => Container(
                      child: ButtonRegular(
                          buttonText: isButtonLoaderEnabled.value
                              ? null
                              : LabelStr.lblsignup,
                          onPressed: () {
                            _pressedOnSignUp();
                          }))),
                  SizedBox(
                    height: dimen.paddingBigLarge,
                  ),
                  _dotline(),
                  SizedBox(
                    height: dimen.paddingExtraLarge,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(
                                right: dimen.paddingExtraLarge,
                                left: dimen.paddingExtraLarge),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.blue),
                            child: InkWell(
                              onTap: () {
                                _pressedOnFBLogin();
                              },
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: dimen.paddingSmall,
                                        bottom: dimen.paddingSmall,
                                        left: dimen.paddingSmall),
                                    child: SvgPicture.asset(
                                      MyImage.ic_fb,
                                      height: dimen.paddingExtraLarge,
                                      width: dimen.paddingExtraLarge,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: dimen.paddingSmall),
                                    child: Text(
                                      LabelStr.lblfacebook,
                                      style: AppTheme.boldSFTextStyle()
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        Container(
                            padding: EdgeInsets.only(
                                right: dimen.paddingBig,
                                left: dimen.paddingBig),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                            child: InkWell(
                              onTap: () {
                                _pressedOngoogleSignIn();
                              },
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: dimen.paddingSmall,
                                        bottom: dimen.paddingSmall,
                                        left: dimen.paddingSmall),
                                    child: Image.asset(
                                      MyImage.ic_google,
                                      height: dimen.paddingExtraLarge,
                                      width: dimen.paddingExtraLarge,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: dimen.paddingSmall),
                                    child: Text(
                                      LabelStr.lblgoogle,
                                      style: AppTheme.boldSFTextStyle()
                                          .copyWith(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        bottom: ScreenUtil().setHeight(30),
                        top: ScreenUtil().setHeight(24)),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            LabelStr.lblsigninnow,
                            style: AppTheme.regularSFTextStyle()
                                .copyWith(color: lightGrey),
                          ),
                          InkWell(
                            onTap: () => Get.to(SignInScreen()),
                            // Navigator.push(
                            // context,
                            // MaterialPageRoute(
                            //     builder: (context) => SignInScreen())),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                LabelStr.lblsinaccount,
                                style: AppTheme.semiBoldSFTextStyle()
                                    .copyWith(color: buttonPrimary),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dotline() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FDottedLine(
          color: lightSky,
          width: ScreenUtil().setWidth(70),
          strokeWidth: 2.0,
          dottedLength: 7.0,
          space: 2.0,
        ),
        Padding(
          padding: EdgeInsets.only(
              left: dimen.paddingVerySmall, right: dimen.paddingVerySmall),
          child: Text(
            LabelStr.lblconnect.toUpperCase(),
            style: AppTheme.sfProLightTextStyle()
                .copyWith(color: lightSky),
          ),
        ),
        FDottedLine(
          color: lightSky,
          width: ScreenUtil().setWidth(70),
          strokeWidth: 2.0,
          dottedLength: 7.0,
          space: 2.0,
        ),
      ],
    );
  }

  Widget _singleCheckbox() {
    return Container(
      alignment: Alignment.center,
      child: Row(children: <Widget>[
        Theme(
          child: Obx(
            () => Checkbox(
                activeColor: buttonPrimary,
                checkColor: Colors.white,
                value: isAcceptTermsCondition.value,
                onChanged: (bool newValue) {
                  this.isAcceptTermsCondition.value = newValue;
                }),
          ),
          data: ThemeData(
            unselectedWidgetColor: blueShadow600, // Your color
          ),
        ),
        Text(
          LabelStr.lbltermconditionagree,
          style: TextStyle(
              fontFamily: MyFont.poppins_regular,
              fontSize: 12,
              color: blueShadow600),
        ),
        InkWell(
          onTap: () {
            Get.to(TermAndConditionScreen(LabelStr.lblNew))
                .then((value) => this.isAcceptTermsCondition.value = value);
          },
          child: Text(
            LabelStr.lbltermcondition,
            style: TextStyle(
                decoration: TextDecoration.underline,
                fontFamily: MyFont.Poppins_semibold,
                fontSize: 12,
                color: blueShadow600),
          ),
        ),
      ]),
    );
  }

  Widget _buildPhoneNumberPopupDialog(
      BuildContext context, dynamic currentUser, bool isGoogleSignIn) {
    return new AlertDialog(
      backgroundColor: roundedcontainer,
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              LabelStr.lblphone,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: MyFont.Poppins_semibold),
            ),
          ),
          SizedBox(
            height: dimen.paddingMedium,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                padding: const EdgeInsets.all(0),
                textStyle: AppTheme.regularSFTextStyle(),
              ),
              Expanded(
                flex: 1,
                child: Container(
                    //width: MediaQuery.of(context).size.width,
                    //height: 55,
                    child: textFieldFor(
                        LabelStr.lblphone, _socailPhoneController,
                        autocorrect: false,
                        maxLength: 12,
                        isMobile: true,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.none,
                        keyboardType: TextInputType.phone)),
              ),
            ],
          ),
          SizedBox(
            height: dimen.paddingMedium,
          ),
          Container(
              child:
                  textFieldFor(LabelStr.lblUserName, _usernameControllerDialog,
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
            height: dimen.paddingMedium,
          ),
          Obx(() => InkWell(
                onTap: () {
                  DatePicker()
                      .selectDate('MM-dd-yyyy', bdayDate, context)
                      .then((selectedDate) => setState(() {
                            bdateStrDialog.value = selectedDate[Parameters.CSelectedDate];
                            bdayDate = selectedDate[Parameters.CDate];
                          }));
                },
                child: Container(
                  height: 48,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      border: Border.all(color: HexColor.borderColor)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(10.0),
                        alignment: Alignment.topLeft,
                        child: Text(
                          (bdateStrDialog.value == '')
                              ? LabelStr.lblbirthdate
                              : bdateStrDialog.value,
                          style: TextStyle(
                            fontFamily: MyFont.Poppins_medium,
                            fontSize: 14,
                            color: (bdateStrDialog.value == '')
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
              )),
          SizedBox(
            height: dimen.paddingMedium,
          ),
          Obx(() => Container(
              child: ButtonRegular(
                  buttonText:
                      isButtonLoaderEnabled.value ? null : LabelStr.lblSubmit,
                  onPressed: () {
                    if (_socailPhoneController.text
                        .replaceAll('-', '')
                        .isEmpty) {
                      RequestManager.getSnackToast(
                          message: Messages.CBlankPhoneNumber);
                    } else if (_socailPhoneController.text
                            .replaceAll('-', '')
                            .length <
                        10) {
                      RequestManager.getSnackToast(
                          message: Messages.CInValidPhoneNumber);
                      return;
                    } else if (_usernameControllerDialog.text.isEmpty) {
                      RequestManager.getSnackToast(
                          message: Messages.CBlankUserName,
                          title: Messages.CErrorMessage,
                          backgroundColor: Colors.black);
                      return;
                    } else if (!DatePicker.isAdult2(bdateStrDialog.value)) {
                      RequestManager.getSnackToast(
                          message: Messages.CValidBirthDate);
                      return;
                    } else {
                      Navigator.pop(context);
                      checkMailExist(
                          {
                            Parameters.CEmailId: currentUser[Parameters.CEmail],
                            Parameters.CPhone:
                                _socailPhoneController.text.replaceAll('-', ''),
                            Parameters.CUserName: _usernameControllerDialog.text
                          },
                          isGoogleSignIn
                              ? SignInType.CGoogle
                              : SignInType.CFacebook,
                          currentUser,
                          true);
                    }
                  }))),
        ],
      ),
    );
  }

  _pressedOnSignUp() {
    if (_firstNameController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankFirstName,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_lastNameController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankLastName,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_usernameController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankUserName,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_emailController.text.trim().isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEmail,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_emailController.text.trim().isValidEmail() == false) {
      RequestManager.getSnackToast(
          message: Messages.CInvalidEmail,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_phoneController.text.replaceAll('-', '').isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankPhoneNumber,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_phoneController.text.replaceAll('-', '').length < 10) {
      RequestManager.getSnackToast(
          message: Messages.CInValidPhoneNumber,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (bdateStr == null) {
      RequestManager.getSnackToast(
          message: Messages.CBlankBirthDate,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (!DatePicker.isAdult2(bdateStr)) {
      RequestManager.getSnackToast(
          message: Messages.CValidBirthDate,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_passwordController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankPassword,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_passwordController.text.isValidPassword() == false) {
      RequestManager.getSnackToast(
          message: Messages.CInvalidPassword,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_conformpasswordController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankConfirmPassword,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_conformpasswordController.text != _passwordController.text) {
      RequestManager.getSnackToast(
          message: Messages.CPasswordDoesNotMatch,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    }
    isButtonLoaderEnabled.value = true;
    checkMailExist({
      Parameters.CEmailId: _emailController.text.trim(),
      Parameters.CPhone: _phoneController.text.replaceAll('-', ''),
      Parameters.CUserName: _usernameController.text
    }, SignInType.CNormal, null, true);
  }

  checkMailExist(Map<String, dynamic> params, int signIntype,
      dynamic currentUser, bool isLoader) {
    if (isLoader) Widgets.showLoading();
    RequestManager.postRequest(
        uri: endPoints.checkMailExist,
        body: params,
        isLoader: false,
        isSuccessMessage: false,
        onSuccess: (response) {
          isButtonLoaderEnabled.value = false;
          if (signIntype == SignInType.CNormal)
            signUpWithNormal();
          else if (signIntype == SignInType.CGoogle)
            signInWithGoogle(currentUser, params[Parameters.CUserName]);
          else if (signIntype == SignInType.CFacebook)
            signInWithFB(currentUser, params[Parameters.CUserName]);
        },
        onFailure: (error) {
          if (isLoader) Widgets.loadingDismiss();
          isButtonLoaderEnabled.value = false;
        });
  }

  signUpWithNormal() {
    String fcm = SessionImpl.getFCMToken();
    Map<String, dynamic> params = {
      Parameters.CFirstName: _firstNameController.text,
      Parameters.CLastName: _lastNameController.text,
      Parameters.CUserName: _usernameController.text,
      Parameters.CEmail: _emailController.text.trim(),
      Parameters.CPassword: _passwordController.text,
      Parameters.CBirthDate: bdateStr,
      Parameters.CPhone: _phoneController.text.replaceAll('-', ''),
      Parameters.CRole: '0',
      Parameters.CSignInType: SignInType.CNormal.toString(),
      Parameters.CFCM: fcm,
    };
    //rq.phoneNumber.value = _phoneController.text;
    _phoneNumberVerification(params);
  }

  Future<void> _pressedOngoogleSignIn() async {
    googleSignInClass.googleSignIn().then((currentUser) {
      if (currentUser == null) return;
      showDialog(
        context: context,
        builder: (BuildContext context) => _buildPhoneNumberPopupDialog(
            context,
            {
              Parameters.CDisplayName: currentUser.displayName,
              Parameters.CEmail: currentUser.email
            },
            true),
      );
    });
  }

  signInWithGoogle(dynamic currentUser, String userName) {
    if (getUserName(currentUser[Parameters.CDisplayName]) != null) {
      String fcm = SessionImpl.getFCMToken();
      var fName = getUserName(currentUser[Parameters.CDisplayName])['fName'];
      var lName = getUserName(currentUser[Parameters.CDisplayName])['lName'];
      Map<String, dynamic> params = {
        Parameters.CFirstName:
            (fName == null) ? currentUser[Parameters.CDisplayName] : fName,
        Parameters.CLastName:
            (lName == null) ? currentUser[Parameters.CDisplayName] : lName,
        Parameters.CUserName: userName,
        Parameters.CEmail: currentUser[Parameters.CEmail],
        Parameters.CBirthDate: bdateStrDialog.value,
        Parameters.CPhone: _socailPhoneController.text.replaceAll('-', ''),
        Parameters.CRole: '0',
        Parameters.CSignInType: SignInType.CGoogle.toString(),
        Parameters.CFCM: fcm,
        Parameters.CPassword: currentUser[Parameters.CEmail],
      };
      _phoneNumberVerification(params);
    } else {
      RequestManager.getSnackToast(message: Messages.CSomethingWorng);
    }
  }

  _pressedOnFBLogin() {
    faceBookSignInClass.signInWithFB(context).then((currentUser) {
      if (currentUser != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              _buildPhoneNumberPopupDialog(context, currentUser, false),
        );
      }
    });
  }

  signInWithFB(dynamic currentUser, String userName) {
    String fcm = SessionImpl.getFCMToken();
    Map<String, dynamic> params = {
      Parameters.CFirstName: currentUser[Parameters.CFirst_Name],
      Parameters.CLastName: currentUser[Parameters.CLast_Name],
      Parameters.CUserName: userName,
      Parameters.CEmail: currentUser[Parameters.CEmail],
      Parameters.CBirthDate: bdateStrDialog.value,
      Parameters.CPhone: _socailPhoneController.text.replaceAll('-', ''),
      Parameters.CRole: '0',
      Parameters.CSignInType: SignInType.CFacebook.toString(),
      Parameters.CFCM: fcm,
      Parameters.CPassword: currentUser[Parameters.CEmail],
    };
    _phoneNumberVerification(params);
  }

  _phoneNumberVerification(Map<String, dynamic> params) {
    _sendAnalyticsEvent(params[Parameters.CEmail].toString());
    VerifyPhoneNumber().registerPhoneNumber(
        params[Parameters.CPhone], countryCode, context, (verificationId) {
      if (verificationId != "-1") {
        Widgets.loadingDismiss();
        Get.to(VerificationScreen(verificationId, params, countryCode, false));
      }
      return;
    });
  }

  Future<void> _sendAnalyticsEvent(String email) async {
    FirebaseAnalytics analytics = FirebaseAnalytics();
    await analytics.logEvent(
      name: Parameters.CSignUp,
      parameters: <String, dynamic>{Parameters.CSignUpEmail: email},
    );
  }
}
