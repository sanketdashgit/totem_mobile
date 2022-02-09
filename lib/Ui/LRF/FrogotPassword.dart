import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class FrogotPassword extends StatefulWidget {
  @override
  _FrogotPasswordState createState() => _FrogotPasswordState();
}

class _FrogotPasswordState extends State<FrogotPassword> {
  var _emailController = TextEditingController();

  var isButtonLoaderEnabled = false.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor,
        body: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    top: ScreenUtil().setHeight(80),
                    left: ScreenUtil().setHeight(30),
                    right: ScreenUtil().setHeight(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.all(dimen.paddingForBackArrow),
                          child: SvgPicture.asset(MyImage.ic_arrow),
                        )),
                    Container(
                      margin: EdgeInsets.only(top: ScreenUtil().setHeight(120)),
                      child: Text(
                        LabelStr.lblForgotPassword,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontFamily: MyFont.Poppins_semibold),
                      ),
                    ),
                    SizedBox(
                      height: 26.0,
                    ),
                    Container(
                        child:
                            textFieldFor(LabelStr.lblEmailId, _emailController,
                                textInputAction: TextInputAction.next,
                                maxLength: 50,
                                textCapitalization: TextCapitalization.none,
                                prefixIcon: Container(
                                  padding: EdgeInsets.all(13),
                                  child: SvgPicture.asset(MyImage.ic_email),
                                ),
                                keyboardType: TextInputType.emailAddress)),
                    SizedBox(
                      height: 33.0,
                    ),
                    Obx(() => Container(
                        child: ButtonRegular(
                            buttonText: isButtonLoaderEnabled.value
                                ? null
                                : LabelStr.lblSubmit,
                            onPressed: () {
                              _pressedOnSubmit();
                            }))),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  _pressedOnSubmit() {
    if (_emailController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEmail,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (!_emailController.text.isValidEmail()) {
      RequestManager.getSnackToast(
          message: Messages.CInvalidEmail,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else {
      isButtonLoaderEnabled.value = true;
      forgotPwdAPI({Parameters.CEmailId: _emailController.text}, false);
    }
  }

  forgotPwdAPI(Map<String, dynamic> params, bool isLoader) {
    RequestManager.postRequest(
        uri: endPoints.forgotPwd,
        body: params,
        isLoader: isLoader,
        isSuccessMessage: false,
        onSuccess: (response) {
          isButtonLoaderEnabled.value = false;
          Get.back();
          RequestManager.getSnackToast(
              title: LabelStr.lblSent,
              backgroundColor: Colors.black,
              message: Messages.CPasswordRestLink);
        },
        onFailure: (error) {
          isButtonLoaderEnabled.value = false;
        });
  }
}
