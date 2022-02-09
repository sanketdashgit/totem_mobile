import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Ui/LRF/TermAndConditionScreen.dart';
import 'package:totem_app/Ui/Notification/PushNotification.dart';
import 'package:totem_app/Ui/Setting/AboutUs.dart';
import 'package:totem_app/Ui/Setting/Account.dart';

import 'package:totem_app/Ui/Setting/Privacy.dart';
import 'package:totem_app/Ui/Setting/Support.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class Setting extends StatefulWidget {
  String title = "";

  Setting({this.title});

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  var isButtonLoaderEnabled = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(45),
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
                        LabelStr.lblSetting,
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: dimen.paddingMedium),
            margin: EdgeInsets.symmetric(horizontal: dimen.paddingMedium),
            decoration: BoxDecoration(
              color: screenBgLightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                InkWell(
                    onTap: () {
                      Get.to(Account());
                    },
                    child: _textContainer(
                        LabelStr.lblAccount, MyImage.ic_rightarrow)),
                InkWell(
                    onTap: () {
                      Get.to(Privacy());
                    },
                    child: _textContainer(
                        LabelStr.lblPrivacy, MyImage.ic_rightarrow)),
                InkWell(
                    onTap: () {
                      Get.to(PushNotification());
                    },
                    child: _textContainer(
                        LabelStr.lblNotifications, MyImage.ic_rightarrow)),
                InkWell(
                    onTap: () {
                      Get.to(Support());
                    },
                    child: _textContainer(
                        LabelStr.lblSupport, MyImage.ic_rightarrow)),
                InkWell(
                    onTap: () {
                      Get.to(TermAndConditionScreen(LabelStr.lbl_Setting));
                    },
                    child: _textContainer(
                        LabelStr.lbltermcondition, MyImage.ic_rightarrow)),
                InkWell(
                    onTap: () {
                      Get.to(AboutUs());
                    },
                    child: _dividerContainer(
                        LabelStr.lblAboutUS, MyImage.ic_rightarrow))
              ],
            ),
          ),
          SizedBox(
            height: dimen.dividerHeightMedium,
          ),
        ],
      ),
    );
  }

  Widget _textContainer(String title, String img) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: dimen.paddingLarge, left: dimen.paddingMedium),
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: MyFont.poppins_regular,
                    color: textColorGreyLight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: dimen.paddingLarge),
              child: SvgPicture.asset(img),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: dimen.paddingMedium),
          child: Divider(
            color: dividerLineColor,
          ),
        ),
      ],
    );
  }

  Widget _dividerContainer(String title, String img) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: dimen.paddingLarge,
                  left: dimen.paddingMedium,
                  bottom: dimen.paddingLarge),
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: MyFont.poppins_regular,
                    color: textColorGreyLight),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: dimen.paddingLarge, bottom: dimen.paddingLarge),
              child: SvgPicture.asset(img),
            ),
          ],
        ),
      ],
    );
  }
}
