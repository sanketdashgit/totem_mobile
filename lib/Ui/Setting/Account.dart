import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Ui/Setting/AccountDeletion.dart';
import 'package:totem_app/Ui/Setting/ChangePassword.dart';
import 'package:totem_app/Ui/Setting/PersonalInformation.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  var isButtonLoaderEnabled = false.obs;

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
                      //Navigator.pop(context);
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
                        LabelStr.lblAccount,
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
            height: dimen.paddingExtra,
          ),
          Column(
            children: [
              InkWell(
                  onTap: () {
                    Get.to(PersonalInformation());
                  },
                  child: _accountContainer(
                      LabelStr.lblManage,
                      LabelStr.lblPersonalInformation,
                      LabelStr.lblPersonalInfo,
                      MyImage.ic_rightarrow)),
              SizedBox(
                height: dimen.paddingLarge,
              ),
              InkWell(
                  onTap: () {
                    Get.to(ChangePassword());
                  },
                  child: _accountContainer(
                      LabelStr.lblSecurity,
                      LabelStr.lblpassword,
                      LabelStr.lblResetorchangepassword,
                      MyImage.ic_rightarrow)),
              SizedBox(
                height: dimen.paddingLarge,
              ),
              InkWell(
                  onTap: () {
                    Get.to(AccountDeletion());
                  },
                  child: _accountContainer(
                      LabelStr.lblAccountControl,
                      LabelStr.lblAccountDeletion,
                      LabelStr.lblPermanentlydelete,
                      MyImage.ic_rightarrow)),
            ],
          )
        ],
      ),
    );
  }

  Widget _accountContainer(
      String titlename, String subtitle, String titledes, String img) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dimen.paddingMedium),
      margin: EdgeInsets.symmetric(horizontal: dimen.paddingMedium),
      decoration: BoxDecoration(
        color: commentBgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: dimen.paddingExtraLarge, left: dimen.paddingMedium),
            child: Text(
              titlename,
              // LabelStr.lblManage,
              style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 0.44,
                  fontFamily: MyFont.Poppins_medium,
                  color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: dimen.paddingSmall,
                      left: dimen.paddingMedium,
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.38,
                          fontFamily: MyFont.Poppins_medium,
                          color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: dimen.paddingMedium,
                        bottom: dimen.paddingExtraLarge),
                    child: Text(
                      titledes,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: MyFont.poppins_regular,
                          color: Colors.white60),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    right: dimen.paddingLarge, bottom: dimen.paddingExtraLarge),
                child: SvgPicture.asset(img),
              ),
            ],
          )
        ],
      ),
    );
  }
}
