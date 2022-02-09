import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FirestoreService.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/SocialLogin.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Ui/LRF/TermAndConditionScreen.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class VerificationScreen extends StatefulWidget {
  String verificationId;
  String countryCode;
  bool isUpdateUser;
  Map<String, dynamic> userInfo;

  VerificationScreen(
      this.verificationId, this.userInfo, this.countryCode, this.isUpdateUser);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Timer _timer;
  int timeCounter = 60;

  TextEditingController _pinCodeController = TextEditingController();

  var isButtonLoaderEnabled = false.obs;
  var isResendVisible = false.obs;
  var timestart = "01:00".obs;
  var phoneAuthID = '';

  final FocusNode _pinPutFocusNode = FocusNode();

  final BoxDecoration pinPutDecoration = BoxDecoration(
    border: Border.all(color: HexColor.borderColor),
    borderRadius: BorderRadius.all(
      Radius.circular(5),
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
          color: Colors.black26,
          blurRadius: 25.0,
          spreadRadius: 1,
          offset: Offset(0.0, 0.75))
    ],
  );

  @override
  void initState() {
    super.initState();
    widget.userInfo.addIf(true, Parameters.CReferredBy, rq.referId);
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  formatHHMMSS() {
    if (timeCounter > 0) {
      int minutes = (timeCounter / 60).truncate();
      int second = timeCounter - (minutes * 60);
      String minutesStr = (minutes).toString().padLeft(2, '0');
      String secondsStr = (second).toString().padLeft(2, '0');
      timestart.value = "$minutesStr:$secondsStr";
    } else {
      timestart.value = "";
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
        if (timeCounter < 1) {
          _timer.cancel();
          isResendVisible.value = true;
        } else {
          formatHHMMSS();
          timeCounter--;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: false);
        return false;
      },
      child: Scaffold(
          backgroundColor: screenBgColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(60), left: 30.0, right: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(MyImage.ic_arrow)),
                      Container(
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(120)),
                        child: Text(
                          LabelStr.lblVerification,
                          style: TextStyle(
                              fontFamily: MyFont.Poppins_semibold,
                              fontSize: 26,
                              letterSpacing: 2.0,
                              color: Colors.white),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: ScreenUtil().setHeight(6)),
                        child: Text(
                          widget.isUpdateUser
                              ? Messages.lblverificationPINUpdate
                              : Messages.lblverificationPIN,
                          style: AppTheme.sfProLightTextStyle()
                              .copyWith(color: lightSky),
                        ),
                      ),
                      SizedBox(
                        height: 23.0,
                      ),
                      PinPut(
                        fieldsCount: 6,
                        textStyle: const TextStyle(
                            fontSize: 25.0, color: Colors.white),
                        eachFieldWidth: 40.0,
                        eachFieldHeight: 40.0,
                        focusNode: _pinPutFocusNode,
                        controller: _pinCodeController,
                        submittedFieldDecoration: pinPutDecoration,
                        selectedFieldDecoration: pinPutDecoration,
                        followingFieldDecoration: pinPutDecoration,
                        pinAnimationType: PinAnimationType.fade,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                                top: ScreenUtil().setHeight(23)),
                            child: Text(
                              LabelStr.lblResendpin,
                              style: TextStyle(
                                  color: lightSky,
                                  fontFamily: MyFont.Poppins_medium,
                                  fontSize: 14),
                            ),
                          ),
                          Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(23)),
                              child: Obx(
                                () => isResendVisible.value
                                    ? InkWell(
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
                                              LabelStr.lblResend,
                                              style: TextStyle(
                                                  fontFamily:
                                                      MyFont.Poppins_medium,
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          _pressedOnResendPin();
                                        },
                                      )
                                    : Text(timestart.value.toString(),
                                        style: TextStyle(
                                            color: lightSky,
                                            fontFamily: MyFont.Poppins_medium,
                                            fontSize: 14)),
                              )),
                        ],
                      ),
                      Obx(
                        () => Container(
                            margin: EdgeInsets.only(
                                top: ScreenUtil().setHeight(31)),
                            child: ButtonRegular(
                                buttonText: isButtonLoaderEnabled.value
                                    ? null
                                    : LabelStr.lblVerify,
                                onPressed: () {
                                  isButtonLoaderEnabled.value = true;
                                  _pressedOnVerify();
                                })),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  _pressedOnResendPin() {
    Widgets.showLoading();
    VerifyPhoneNumber().registerPhoneNumber(
        widget.userInfo[Parameters.CPhone], widget.countryCode, context,
        (verificationId) {
      Widgets.loadingDismiss();
      if (verificationId == "-1") {
        RequestManager.getSnackToast(
            message: Messages.CSomethingWorng,
            title: LabelStr.lblFailed,
            backgroundColor: Colors.black);
      } else {
        widget.verificationId = verificationId;
        timeCounter = 60;
        startTimer();
        isResendVisible.value = false;
        RequestManager.getSnackToast(
            message: Messages.CVerificationCode,
            title: LabelStr.lblSend,
            backgroundColor: Colors.black);
      }
      return;
    });
  }

  _pressedOnVerify() {
    VerifyPhoneNumber()
        .verifyOTPCode(widget.verificationId, _pinCodeController.text.trim(),
            (userCredential, isValid) {
      if (isValid) {
        if (widget.isUpdateUser) {
          Get.back(result: true);
        } else {
          phoneAuthID = userCredential.user.uid;
          signUpAPI();
        }
      } else {
        RequestManager.getSnackToast(message: Messages.CCorrectOTP);
        isButtonLoaderEnabled.value = false;
      }
      return;
    });
  }

  signUpAPI() {
    RequestManager.postRequest(
        uri: endPoints.signUp,
        body: widget.userInfo,
        isSuccessMessage: false,
        onSuccess: (response) {
          isButtonLoaderEnabled.value = false;
          UserInfoModel userInfo = UserInfoModel.fromJson(response);
          SessionImpl.setNewToken(userInfo.token);
          SessionImpl.setLoginProfileModel(userInfo);
          SessionImpl.setLogIn(true);
          Get.offAll(TermAndConditionScreen(LabelStr.lblNew));
          rq.referId = 0;
          FirestoreService().createUserWithEmailInFireStore({
            Parameters.CuserIdSmall: userInfo.id,
            Parameters.CEmail: widget.userInfo[Parameters.CEmail],
            Parameters.CPassword_: widget.userInfo[Parameters.CPassword],
            Parameters.CuserName: widget.userInfo[Parameters.CUserName]
          });
        },
        onFailure: (error) {
          isButtonLoaderEnabled.value = false;
        });
  }
}
