import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import  'package:get/get.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import '../Customs/ButtonRegular.dart';

class Support extends StatefulWidget {

  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> {

  var _emailController = TextEditingController();
  var _typeController = TextEditingController();
  var isButtonLoaderEnabled = false.obs;


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
                          LabelStr.lblSupport,
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
                    LabelStr.lblEmailId, _emailController,
                    autocorrect: false,
                    maxLength: 50,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text)),
            SizedBox(
              height: dimen.paddingBig,
            ),
            Container(
                child: textFieldFor(
                    LabelStr.lblLableText, _typeController,
                    autocorrect: false,
                    maxLength: 255,
                    maxLine: 5,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.text)),

            Expanded(child: Container()),
            Obx(
                    () => Container(
                      padding: const EdgeInsets.only(bottom: dimen.buttonHeight),
                    child: ButtonRegular(
                        buttonText: isButtonLoaderEnabled.value
                            ? null
                            : LabelStr.lblSend,
                        onPressed: () {
                        _pressedOnSumbit();
                        })),
              ),
          ],
        ),
      ),
    );
  }
  _pressedOnSumbit() {
    if (_emailController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBlankEmail);
      return;
    } else if (!_emailController.text.isValidEmail()) {
      RequestManager.getSnackToast(message: Messages.CInvalidEmail);
      return;
    } else if (_typeController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBlankMessage);
      return;
    }
    isButtonLoaderEnabled.value = true;
    _callAddSupport();
  }
  _callAddSupport(){
    var body = {
      Parameters.CsupportID:SessionImpl.getId(),
      Parameters.CUserId:SessionImpl.getId(),
      Parameters.CEmail: _emailController.text,
      Parameters.Cbody: _typeController.text,
    };
    RequestManager.postRequest(
        uri: endPoints.AddSupport,
        body: body,
        isSuccessMessage: false,
        onSuccess: (response){
          isButtonLoaderEnabled.value = false;
          Get.back();
          RequestManager.getSnackToast(
              title: LabelStr.lblSubmitted,
              backgroundColor: Colors.black,
              message: Messages.CMessagesuccessfully);
        },
        onFailure: (error){
          isButtonLoaderEnabled.value = false;
        });
  }


}
