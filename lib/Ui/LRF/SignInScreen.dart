import 'dart:io';
import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/CommonStuff.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/DatePicker.dart';
import 'package:totem_app/GeneralUtils/FirestoreService.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/RecaptchaV2.dart';
import 'package:totem_app/GeneralUtils/SocialLogin.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Ui/LRF/FrogotPassword.dart';
import 'package:totem_app/Ui/LRF/SignUpScreen.dart';
import 'package:totem_app/Ui/LRF/VerificationScreen.dart';
import 'package:totem_app/Ui/NavigationDrawerScreen.dart';
import 'package:totem_app/Ui/Profile/CreateProfile.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();

  GoogleSignInClass googleSignInClass = GoogleSignInClass();
  FaceBookSignInClass faceBookSignInClass = FaceBookSignInClass();
  var _socailPhoneController = TextEditingController();
  var _usernameControllerDialog = TextEditingController();
  var isButtonLoaderEnabled = false.obs;
  var inValidCounter = 0;
  var signUserName = "";
  String verifyResult = "";
  RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();

  dynamic appleAuthDetail;
  DateTime bdayDate;
  var bdateStr;
  var bdateStrFinal;
  var bdateStrDialog = ''.obs;
  var countryCode = "+1";
  var isShow = false.obs;

  @override
  void initState() {
    inValidCounter = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil().setHeight(195),
                          left: ScreenUtil().setWidth(30),
                          right: ScreenUtil().setWidth(30)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LabelStr.lblsignin.toUpperCase(),
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
                                  LabelStr.lblphoneemailId, _emailController,
                                  autocorrect: false,
                                  maxLength: 50,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.none,
                                  prefixIcon: Container(
                                    padding: EdgeInsets.all(13),
                                    child: SvgPicture.asset(MyImage.ic_email),
                                  ),
                                  keyboardType: TextInputType.emailAddress)),
                          SizedBox(
                            height: dimen.paddingLarge,
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
                                            color: MyColor.hintTextColor()))),
                          ),
                          SizedBox(
                            height: dimen.paddingMedium,
                          ),
                          InkWell(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FrogotPassword()))
                            },
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                LabelStr.lblForgotPasswordSignIn,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: HexColor.textColor),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: dimen.paddingBig,
                          ),
                          Obx(
                            () => Container(
                                child: ButtonRegular(
                                    buttonText: isButtonLoaderEnabled.value
                                        ? null
                                        : LabelStr.lblsignin.toUpperCase(),
                                    onPressed: () {
                                      _pressedOnSignInButton();
                                    })),
                          ),
                          SizedBox(
                            height: dimen.paddingExtra,
                          ),
                          _dotline(),
                          SizedBox(
                            height: dimen.paddingBigLarge,
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
                                        _pressedOnFBSignInButton();
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
                                                  .copyWith(
                                                      color: Colors.white),
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
                                        _pressedOnGoogleSignInButton();
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
                                                  .copyWith(
                                                      color: Colors.black),
                                            ),
                                          ),

                                          //Image.asset(MyImage.splashBgImage,fit: BoxFit.fill),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (Platform.isIOS) appleSignInBtn(),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(
                          bottom: ScreenUtil().setHeight(33),
                          top: dimen.paddingXXLarge),
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              LabelStr.lblsigninaccount,
                              style: AppTheme.regularSFTextStyle()
                                  .copyWith(color: lightGrey),
                            ),
                            InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen())),
                              child: Padding(
                                padding: EdgeInsets.all(dimen.paddingVerySmall),
                                child: Text(
                                  LabelStr.lblsignupaccount,
                                  style: AppTheme.semiBoldSFTextStyle()
                                      .copyWith(color: buttonPrimary),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: dimen.paddingBigLarge),
              child: RecaptchaV2(
                apiKey: ApiKey,
                apiSecret: ApiSecret,
                controller: recaptchaV2Controller,
                onVerifiedError: (err) {
                  print(err);
                },
                onVerifiedSuccessfully: (success) {
                  setState(() {
                    if (success) {
                      verifyResult = Messages.CVerify;
                    } else {
                      verifyResult = Messages.CFailedVerify;
                    }
                  });
                },
              ),
            ),
          ],
        ));
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

  Widget _buildPhoneNumberPopupDialog(
      BuildContext context, dynamic currentUser) {
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
                      currentUser[Parameters.CPhone] =
                          _socailPhoneController.text.replaceAll('-', '');
                      currentUser[Parameters.CUserName] =
                          _usernameControllerDialog.text.toString();
                      checkMailExist(currentUser, true);
                    }
                  }))),
        ],
      ),
    );
  }

  checkMailExist(Map<String, dynamic> params, bool isLoader) {
    if (isLoader) Widgets.showLoading();
    RequestManager.postRequest(
        uri: endPoints.checkMailExist,
        body: params,
        isLoader: false,
        isSuccessMessage: false,
        onSuccess: (response) {
          isButtonLoaderEnabled.value = false;
          if (int.parse(params[Parameters.CSignInType]) == SignInType.CGoogle)
            signInWithGoogle(params);
          else if (int.parse(params[Parameters.CSignInType]) ==
              SignInType.CFacebook)
            signInWithFB(params);
          else if (int.parse(params[Parameters.CSignInType]) ==
              SignInType.CApple) signInWithApple(params);
        },
        onFailure: (error) {
          if (isLoader) Widgets.loadingDismiss();
          isButtonLoaderEnabled.value = false;
        });
  }

  signInWithGoogle(dynamic currentUser) {
    Map<String, dynamic> params = {
      Parameters.CFirstName: currentUser[Parameters.CFirstName],
      Parameters.CLastName: currentUser[Parameters.CLastName],
      Parameters.CUserName: currentUser[Parameters.CUserName],
      Parameters.CEmail: currentUser[Parameters.CEmailId],
      Parameters.CBirthDate: bdateStrDialog.value,
      Parameters.CPhone: currentUser[Parameters.CPhone],
      Parameters.CRole: '0',
      Parameters.CSignInType: SignInType.CGoogle.toString(),
      Parameters.CFCM: currentUser[Parameters.CFCM],
      Parameters.CPassword: currentUser[Parameters.CEmailId],
    };
    _phoneNumberVerification(params);
  }

  signInWithApple(dynamic currentUser) {
    Map<String, dynamic> params = {
      Parameters.CFirstName: currentUser[Parameters.CFirstName],
      Parameters.CLastName: currentUser[Parameters.CLastName],
      Parameters.CUserName: currentUser[Parameters.CUserName],
      Parameters.CEmail: currentUser[Parameters.CEmailId],
      Parameters.CBirthDate: bdateStrDialog.value,
      Parameters.CPhone: currentUser[Parameters.CPhone],
      Parameters.CRole: '0',
      Parameters.CSignInType: SignInType.CApple.toString(),
      Parameters.CFCM: currentUser[Parameters.CFCM],
      Parameters.CPassword: currentUser[Parameters.CEmailId],
    };

    _phoneNumberVerification(params);
  }

  signInWithFB(dynamic currentUser) {
    Map<String, dynamic> params = {
      Parameters.CFirstName: currentUser[Parameters.CFirstName],
      Parameters.CLastName: currentUser[Parameters.CLastName],
      Parameters.CUserName: currentUser[Parameters.CUserName],
      Parameters.CEmail: currentUser[Parameters.CEmailId],
      Parameters.CBirthDate: bdateStrDialog.value,
      Parameters.CPhone: currentUser[Parameters.CPhone],
      Parameters.CRole: '0',
      Parameters.CSignInType: SignInType.CFacebook.toString(),
      Parameters.CFCM: currentUser[Parameters.CFCM],
      Parameters.CPassword: currentUser[Parameters.CEmailId],
    };
    _phoneNumberVerification(params);
  }

  Widget appleSignInBtn() {
    return Padding(
      padding: EdgeInsets.only(
        top: dimen.paddingExtraLarge,
      ),
      child: SignInWithAppleButton(onPressed: () {
        _pressedOnAppleSignIn();
      }),
    );
  }

  _pressedOnSignInButton() {
    if (_emailController.text.trim().isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEmail,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_emailController.text.trim().isNumeric() &&
        _emailController.text.trim().length < 10) {
      RequestManager.getSnackToast(
          message: Messages.CInValidPhoneNumber,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_emailController.text.trim().isValidEmail() == false) {
      RequestManager.getSnackToast(
          message: Messages.CInvalidEmail,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_passwordController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankPassword,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (!_passwordController.text.isValidPassword()) {
      RequestManager.getSnackToast(
          message: Messages.CInvalidPassword,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    }
    isButtonLoaderEnabled.value = true;
    String fcm = SessionImpl.getFCMToken();
    _signInUser({
      Parameters.CEmailId: _emailController.text.trim(),
      Parameters.CPassword: _passwordController.text,
      Parameters.CSignInType: SignInType.CNormal.toString(),
      Parameters.CFCM: fcm,
    }, false);
  }

  _pressedOnFBSignInButton() {
    faceBookSignInClass.signInWithFB(context).then((currentUser) {
      if (currentUser != null) {
        String fcm = SessionImpl.getFCMToken();
        _signInUser({
          Parameters.CEmailId: currentUser[Parameters.CEmail],
          Parameters.CSignInType: SignInType.CFacebook.toString(),
          Parameters.CFCM: fcm,
          Parameters.CFirstName: currentUser[Parameters.CFirst_Name],
          Parameters.CLastName: currentUser[Parameters.CLast_Name],
        }, true);
      }
    });
  }

  _pressedOnAppleSignIn() {
    AppleSignInClass().appleSignIn().then((authDetail) async {
      appleAuthDetail = authDetail;

      if (authDetail[Parameters.CFamilyName] == null) {
        String fcm = SessionImpl.getFCMToken();
        _signInUser({
          Parameters.CEmailId: authDetail[Parameters.CEmail],
          Parameters.CSignInType: SignInType.CApple.toString(),
          Parameters.CFCM: fcm,
          Parameters.CFirstName: "NA",
          Parameters.CLastName: "NA",
        }, true);
      } else {
        String fcm = SessionImpl.getFCMToken();
        var user = {
          Parameters.CEmailId: authDetail[Parameters.CEmail],
          Parameters.CSignInType: SignInType.CApple.toString(),
          Parameters.CFirstName: authDetail[Parameters.CGiveName],
          Parameters.CLastName: authDetail[Parameters.CFamilyName],
          Parameters.CFCM: fcm
        };
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              _buildPhoneNumberPopupDialog(context, user),
        );
      }
    });
  }

  _pressedOnGoogleSignInButton() {
    googleSignInClass.googleSignIn().then((currentUser) {
      String fcm = SessionImpl.getFCMToken();
      if (getUserName(currentUser.displayName) != null) {
        _signInUser({
          Parameters.CEmailId: currentUser.email,
          Parameters.CSignInType: SignInType.CGoogle.toString(),
          Parameters.CFCM: fcm,
          Parameters.CFirstName: getUserName(currentUser.displayName)['fName'],
          Parameters.CLastName: getUserName(currentUser.displayName)['lName'],
        }, true);
      } else {
        RequestManager.getSnackToast(message: Messages.CSomethingWorng);
      }
    });
  }

  _callLockAccount(Map<String, dynamic> params) {
    RequestManager.postRequest(
        uri: endPoints.InvalidLoginAttempts,
        body: params,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {},
        onFailure: (error) {});
  }

  _signInUser(Map<String, dynamic> params, bool isLoader) {
    RequestManager.postRequest(
        uri: endPoints.signIn,
        body: params,
        isLoader: isLoader,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          isButtonLoaderEnabled.value = false;
          UserInfoModel userModel = UserInfoModel.fromJson(response);
          SessionImpl.setNewToken(userModel.token);
          SessionImpl.setLoginProfileModel(userModel);
          SessionImpl.setLogIn(true);
          if (userModel.latitude == "0.0") {
            Get.off(CreateProfile(isEdit: false));
          } else {
            Get.off(NavigationDrawerScreen(9));
          }

          FirestoreService().signInWithEmailAndPasswordInFireStore(
              userModel.email, _passwordController.text, (response, error) {});
        },
        onFailure: (error) {
          if (params[Parameters.CSignInType] == SignInType.CNormal.toString()) {
            RequestManager.getSnackToast(
              title: "Error",
              message: error.toString(),
            );

            if (signUserName != params[Parameters.CEmailId]) {
              inValidCounter = 0;
              signUserName = params[Parameters.CEmailId];
            }
            inValidCounter++;
            isButtonLoaderEnabled.value = false;
            if (inValidCounter % 3 == 0 && inValidCounter != 0) {
              recaptchaV2Controller.show();
            }
            if (inValidCounter == 8) {
              //call lock api
              _callLockAccount({Parameters.CEmailId: signUserName});
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  _buildPhoneNumberPopupDialog(context, params),
            );
          }
        });
  }

  _phoneNumberVerification(Map<String, dynamic> params) {
    Widgets.showLoading();

    VerifyPhoneNumber().registerPhoneNumber(
        params[Parameters.CPhone], countryCode, context, (verificationId) {
      if (verificationId != "-1") {
        Widgets.loadingDismiss();
        Get.to(VerificationScreen(verificationId, params, countryCode, false));
      }
      return;
    });
  }
}
