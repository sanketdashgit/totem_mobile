import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';

import 'package:totem_app/WebService/RequestManager.dart';

import '../Customs/ButtonRegular.dart';

class ChangePassword extends StatefulWidget {

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var _CurrentPasswordController = TextEditingController();
  var _NewPasswordController = TextEditingController();
  var _ConfirmController = TextEditingController();
  var isButtonLoaderEnabled = false.obs;
  var isCurrentPasswordShow = false.obs;
  var isNewPasswordShow = false.obs;
  var isConfirmPasswordShow = false.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(49), left: ScreenUtil().setWidth(30), right: ScreenUtil().setWidth(30)),
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
                   child:  Center(
                     child: Text(
                       LabelStr.lblChangePassword,
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
               child: textFieldFor(
                   LabelStr.lblCurrentPassword,_CurrentPasswordController ,
                   autocorrect: false,
                   maxLength: 15,
                   obscure: !isCurrentPasswordShow.value,
                   suffixIcon: GestureDetector(
                       onTap: () {
                         setState(() {
                           isCurrentPasswordShow.value
                               ? isCurrentPasswordShow.value = false
                               : isCurrentPasswordShow.value = true;
                         });
                       },
                       child: isCurrentPasswordShow.value
                           ? Icon(Icons.visibility,
                           color: MyColor.hintTextColor())
                           : Icon(Icons.visibility_off,
                           color: MyColor.hintTextColor())),
                   textInputAction: TextInputAction.next,
                   textCapitalization: TextCapitalization.none,
                   keyboardType: TextInputType.text)),
           SizedBox(
             height: dimen.paddingBig,
           ),
           Container(
               child: textFieldFor(
                   LabelStr.lblNewPassword,_NewPasswordController ,
                   autocorrect: false,
                   maxLength: 15,
                   obscure: !isNewPasswordShow.value,
                   suffixIcon: GestureDetector(
                       onTap: () {
                         setState(() {
                           isNewPasswordShow.value
                               ? isNewPasswordShow.value = false
                               : isNewPasswordShow.value = true;
                         });
                       },
                       child: isNewPasswordShow.value
                           ? Icon(Icons.visibility,
                           color: MyColor.hintTextColor())
                           : Icon(Icons.visibility_off,
                           color: MyColor.hintTextColor())),
                   textInputAction: TextInputAction.next,
                   textCapitalization: TextCapitalization.none,
                   keyboardType: TextInputType.text)),

           SizedBox(
             height: dimen.paddingBig,
           ),
           Container(
               child: textFieldFor(
                   LabelStr.lblConfirmPassword,_ConfirmController ,
                   autocorrect: false,
                   maxLength: 15,
                   obscure: !isConfirmPasswordShow.value,
                   suffixIcon: GestureDetector(
                       onTap: () {
                         setState(() {
                           isConfirmPasswordShow.value
                               ? isConfirmPasswordShow.value = false
                               : isConfirmPasswordShow.value = true;
                         });
                       },
                       child: isConfirmPasswordShow.value
                           ? Icon(Icons.visibility,
                           color: MyColor.hintTextColor())
                           : Icon(Icons.visibility_off,
                           color: MyColor.hintTextColor())),
                   textInputAction: TextInputAction.done,
                   textCapitalization: TextCapitalization.none,
                   keyboardType: TextInputType.text)),

           Spacer(),
           Obx(
                 () => Container(
                 padding: const EdgeInsets.only(bottom: dimen.buttonHeight),
                 child: ButtonRegular(
                     buttonText: isButtonLoaderEnabled.value
                         ? null
                         : LabelStr.lblResetPassword,
                     onPressed: () {
                        _pressedOnChangePassword();
                     })),
           ),
         ],
       ),
      ),
    );
  }
  _pressedOnChangePassword(){
    if (_CurrentPasswordController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CCurrentPassword,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    } else if (!_CurrentPasswordController.text.isValidPassword()) {
      RequestManager.getSnackToast(message: Messages.CInvalidPassword,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    }else if (_NewPasswordController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CNewPassword,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    }else if (!_NewPasswordController.text.isValidPassword()) {
      RequestManager.getSnackToast(message: Messages.CInvalidPassword,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    } else if (_ConfirmController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CConfirmPassword,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    }
    else if (!_ConfirmController.text.isValidPassword()) {
      RequestManager.getSnackToast(message: Messages.CInvalidPassword,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    }
    else if (!_NewPasswordController.text.trim().contains(_ConfirmController.text.trim())) {
      RequestManager.getSnackToast(message: Messages.CNewPasswordDoesNotMatch,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    }

    isButtonLoaderEnabled.value = true;
    _callChangePassword();
  }

  _callChangePassword(){
    var body = {
      Parameters.CaccountId: SessionImpl.getId(),
      Parameters.ColdPassword: _CurrentPasswordController.text,
      Parameters.CPassword: _ConfirmController.text
    };
    RequestManager.postRequest(
        uri: endPoints.ChangePassword,
        body: body,
        isSuccessMessage: false,
        onSuccess: (response){
          isButtonLoaderEnabled.value = false;
          Get.back();
          RequestManager.getSnackToast(
              title: LabelStr.lblChanged,
              backgroundColor: Colors.black,
              message:Messages.CPasswordUpdated);
        },
        onFailure: (errors){
          isButtonLoaderEnabled.value = false;

        });
  }
}
