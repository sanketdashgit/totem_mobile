import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';


class AboutUs extends StatefulWidget {

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(58),left: 30.0,right: 30.0,bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(onTap: (){
              Get.back(result: false);
            },
                child: Padding(
                  padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                  child: SvgPicture.asset(MyImage.ic_cross),
                )),
            Padding(
              padding: EdgeInsets.only(top:ScreenUtil().setHeight(30)),
              child: Text(
                LabelStr.lblAboutUS,
                style: TextStyle(
                    fontSize: 26,
                    fontFamily: MyFont.Poppins_semibold,
                    color: Colors.white
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(30)),
            Text(
              Messages.CAboutUsMessage,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: MyFont.poppins_regular,
                  color: Colors.white
              ),
            ),
            Expanded(child: Container()),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  Messages.CTotemLLC,
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: MyFont.poppins_regular,
                      color: Colors.white
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
