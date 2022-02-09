import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/NavigationDrawerScreen.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Customs/ButtonRegular.dart';

class ApplyforVerifcation extends StatefulWidget {

  @override
  _ApplyforVerifcationState createState() => _ApplyforVerifcationState();
}

class _ApplyforVerifcationState extends State<ApplyforVerifcation> {
  var _userNameController = TextEditingController();
  var _fullNameController = TextEditingController();
  var _additionalInfoController = TextEditingController();
  var isButtonLoaderEnabled = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(49), left: ScreenUtil().setWidth(30), right: ScreenUtil().setWidth(30)),
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
                Expanded(flex: 1,
                    child:  Center(
                      child: Text(
                        LabelStr.lblapplyforVerifcation,
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
            height: dimen.dividerHeightHuge,
          ),
          Divider(
            color: dividerLineColor,
          ),
          SizedBox(
              height: dimen.dividerHeightMedium
          ),
          Expanded(
            flex: 1,
              child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(28), left: ScreenUtil().setWidth(30), right: ScreenUtil().setWidth(30)),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            LabelStr.lblrequestVerification,
                            style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 0.9,
                                fontFamily: MyFont.Poppins_medium,
                                color: Colors.white
                            ),
                          ),
                        ),

                        SizedBox(
                          height: dimen.dividerHeightNormal,
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            LabelStr.lblverifiytitle,
                            style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.9,
                                fontFamily: MyFont.poppins_regular,
                                color: verifyTitleColor
                            ),
                          ),
                        ),
                        SizedBox(
                          height: dimen.dividerHeightMedium,
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            LabelStr.lblrequestVerificationSubmit,
                            style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.9,
                                fontFamily: MyFont.poppins_regular,
                                color: verifyTitleColor
                            ),
                          ),
                        ),
                        SizedBox(
                          height: dimen.dividerHeightLarge,
                        ),
                        Container(
                            child: textFieldFor(
                                LabelStr.lblUserName, _userNameController,
                                autocorrect: false,
                                maxLength: 20,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.text)),
                        SizedBox(
                          height: dimen.dividerHeightLarge,
                        ),
                        Container(
                            child: textFieldFor(
                                LabelStr.lblfullName, _fullNameController,
                                autocorrect: false,
                                maxLength: 20,
                                textInputAction: TextInputAction.done,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.text)),
                        SizedBox(
                          height: dimen.dividerHeightLarge,
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            child: textFieldFor(LabelStr.lbladditionInfo, _additionalInfoController,
                                autocorrect: false,
                                maxLine: 3,
                                maxLength: 255,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.text)),
                        SizedBox(
                            height: dimen.dividerHeightHuge
                        ),
                        Container(
                          margin: EdgeInsets.only(top:ScreenUtil().setHeight(30)),
                          child: Text(
                            LabelStr.lblaccountTitle,
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: MyFont.poppins_regular,
                                color: HexColor.textColor
                            ),
                          ),
                        ),
                        SizedBox(
                            height: dimen.dividerHeightMedium
                        ),
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
                                text: LabelStr.lblAccountTitleLink3,
                                recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _openUrl('mailto:support@totemapp.org');
                                },
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
                        ),
                      ],
                    ),
                  ) ,)),
          Padding(
            padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(26), top: ScreenUtil().setHeight(26), left: ScreenUtil().setWidth(30), right: ScreenUtil().setWidth(30)),
            child: Obx(
                  () => Container(
                  child: ButtonRegular(
                      buttonText: isButtonLoaderEnabled.value
                          ? null
                          : LabelStr.lblSubmitRequest,
                      onPressed: () {
                        _pressedOnApplyForVerifcation();
                      })),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw '${LabelStr.lblCouldNotLaunch} $url';
    }
  }

  _pressedOnApplyForVerifcation(){
    if (_userNameController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBlankUserName,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    } else if (_fullNameController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBlankFullName,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    }else if(_additionalInfoController.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CBlankAadditionalInformation,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    }
    isButtonLoaderEnabled.value = true;
    _callProfileVerifyReq();
  }

  _callProfileVerifyReq(){
    var body = {
    Parameters.Cid: SessionImpl.getId(),
    Parameters.CprofileId: "0",
    Parameters.CuserName: _userNameController.text,
    Parameters.CfullName: _fullNameController.text,
    Parameters.CadditionalInformation: _additionalInfoController.text,
    };
    RequestManager.postRequest(
        uri: endPoints.profileVerifyReq,
        body: body,
        isSuccessMessage: false,
        onSuccess: (response){
          UserInfoModel user =
          (SessionImpl.getLoginProfileModel() as UserInfoModel);
          user.isProfileVarificationRequestSend = true;
          SessionImpl.setLoginProfileModel(user);
          isButtonLoaderEnabled.value = false;
          Get.back();
          RequestManager.getSnackToast(
              title: LabelStr.lblSubmitted,
              message: Messages.CVerifySuccessfully,
              colorText: Colors.white,
              backgroundColor: Colors.black);
        },
        onFailure: (){
          isButtonLoaderEnabled.value = false;
    });
  }
}
