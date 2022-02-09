import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Ui/Notification/PushNotification.dart';
import 'package:totem_app/Ui/Setting/ChangePassword.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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
                        LabelStr.lblEditProfile,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: dimen.dividerHeightSmall),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(dimen.paddingLarge),
                        child: SvgPicture.asset(
                          MyImage.ic_email,
                          color: textColorGreyLight,
                        ),
                      ),
                      Text(
                        LabelStr.lblChangeEmailAddress,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: MyFont.poppins_regular,
                            color: textColorGreyLight),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: dividerLineColor,
                ),
                InkWell(
                  onTap: () {
                    Get.to(ChangePassword());
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(dimen.paddingLarge),
                        child: SvgPicture.asset(MyImage.ic_openlock),
                      ),
                      Text(
                        LabelStr.lblChangePassword,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: MyFont.poppins_regular,
                            color: textColorGreyLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: dimen.dividerHeightMedium,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: dimen.paddingMedium),
            margin: EdgeInsets.symmetric(horizontal: dimen.paddingMedium),
            decoration: BoxDecoration(
              color: screenBgLightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () {
                Get.to(PushNotification());
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(dimen.paddingLarge),
                    child: SvgPicture.asset(MyImage.ic_notificationIcon),
                  ),
                  Text(
                    LabelStr.lblNotifications,
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: MyFont.poppins_regular,
                        color: textColorGreyLight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
