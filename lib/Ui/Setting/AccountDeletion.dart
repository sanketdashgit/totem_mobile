import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/CommonStuff.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/LRF/SignInScreen.dart';
import 'package:totem_app/Ui/NavigationDrawerScreen.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:get/get.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';

import '../Customs/ButtonHalfWidth.dart';

class AccountDeletion extends StatefulWidget {
  @override
  _AccountDeletionState createState() => _AccountDeletionState();
}

class _AccountDeletionState extends State<AccountDeletion> {
  var isButtonLoaderEnabled = false.obs;
  bool _isVisible = false;
  var _passwordController = TextEditingController();
  bool isAcceptTermsCondition = false;

  @override
  void initState() {
    super.initState();
    UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
    if(user.signInType == SignInType.CNormal){
      _isVisible = true;
    }else{
      _isVisible = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
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
                              LabelStr.lblAccountDeletion,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: MyFont.Poppins_semibold,
                                  color: Colors.white),
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: dimen.dividerHeightLarge,
                ),
                Divider(
                  color: dividerLineColor,
                ),
                SizedBox(
                  height: dimen.dividerHeightLarge,
                ),
              ],
            ),
            Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(30),
                      right: ScreenUtil().setWidth(30),
                    ),
                    child: Column(
                      children: [
                        Text(
                          LabelStr.lblAccountDeletionTitle,
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: MyFont.poppins_regular,
                              color: HexColor.textColor),
                        ),
                        SizedBox(
                          height: dimen.dividerHeightLarge,
                        ),
                        Text(
                          LabelStr.lblAccountDeletionTitle1,
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: MyFont.poppins_regular,
                              color: HexColor.textColor),
                        ),
                        SizedBox(
                          height: dimen.dividerHeightLarge,
                        ),
                        Text(
                          LabelStr.lblAccountDeletionTitle2,
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: MyFont.poppins_regular,
                              color: HexColor.textColor),
                        ),
                        SizedBox(
                          height: dimen.dividerHeightLarge,
                        ),
                        Visibility(
                          visible: _isVisible,
                          child: Container(
                              child: textFieldFor(
                                  LabelStr.lblpassword, _passwordController,
                                  autocorrect: false,
                                  maxLength: 15,
                                  obscure: true,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.none,
                                  keyboardType: TextInputType.text)),
                        ),
                        Theme(
                          child: CheckboxListTile(
                              title: Padding(
                                padding: const EdgeInsets.only(
                                  top: dimen.paddingExtraLarge,
                                ),
                                child: Text(
                                  LabelStr.lblcheckbooktitle,
                                  style: TextStyle(
                                      fontFamily: MyFont.poppins_regular,
                                      fontSize: 12,
                                      color: checkBoxactiveColor),
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: buttonPrimary,
                              checkColor: Colors.white,
                              value: isAcceptTermsCondition,
                              onChanged: (bool newValue) {
                                setState(() {
                                  this.isAcceptTermsCondition = newValue;
                                });
                              }),
                          data: ThemeData(
                            unselectedWidgetColor:
                                checkBoxactiveColor, // Your color
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Container(
              margin: EdgeInsets.only(
                  left: ScreenUtil().setWidth(30),
                  right: ScreenUtil().setWidth(30),
                  bottom: ScreenUtil().setWidth(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: ButtonHalfWidth(
                        width: MediaQuery.of(context).size.width * 0.4,
                        prefixIcon: MyImage.ic_delete,
                        fillColor: buttonRed,
                        buttonText: isButtonLoaderEnabled.value
                            ? null
                            : LabelStr.lbldelete,
                        onPressed: () {
                          _pressedOnSubmit();
                        },
                      ),
                      // ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                    child: ButtonHalfWidth(
                      width: MediaQuery.of(context).size.width * 0.4,
                      fillColor: buttonPrimary,
                      buttonText: LabelStr.lblCancel,
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  _pressedOnSubmit() {
    UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);

    if (user.signInType == SignInType.CNormal) {
      if (_passwordController.text.isEmpty) {
        RequestManager.getSnackToast(message: Messages.CBlankPassword,title: Messages.CErrorMessage,backgroundColor: Colors.black);
        return;
      }else if (!_passwordController.text.isValidPassword()) {
        RequestManager.getSnackToast(message: Messages.CInvalidPassword,title: Messages.CErrorMessage,backgroundColor: Colors.black);
        return;
      }
    }
    if (!isAcceptTermsCondition) {
      RequestManager.getSnackToast(message: Messages.CCheckbox,title: Messages.CErrorMessage,backgroundColor: Colors.black);
      return;
    }
    showAlertDialogLogout(context);

  }



  showAlertDialogLogout(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        _callDeleteuser();
         Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(LabelStr.lblAccountDeletion),
      content: Text(Messages.CAccountDeleteMessage),
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

  void _callDeleteuser() {
    UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
    var body = {
      Parameters.CSignInType: user.signInType,
      Parameters.CPassword: _passwordController.text,
      Parameters.CemailId: user.email
    };
    isButtonLoaderEnabled.value = true;
    RequestManager.postRequest(
        uri: endPoints.Deleteuser,
        body: body,
        onSuccess: (response) {
          isButtonLoaderEnabled.value = false;
          logOut();
          Get.offAll(SignInScreen());
          RequestManager.getSnackToast(
              title: LabelStr.lbldelete,
              backgroundColor: Colors.black,
              message: Messages.CAccountDeleted);
        },
        onFailure: (error) {
          isButtonLoaderEnabled.value = false;
        });
  }
}
