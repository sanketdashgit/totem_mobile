import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/Utils.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class LearnMore extends StatefulWidget {
  @override
  _LearnMoreState createState() => _LearnMoreState();
}

class _LearnMoreState extends State<LearnMore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Stack(
        children: [
          setBackground(),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              title(),
              Expanded(child: body()),
              //bottomBtn(),
            ],
          ),
        ],
      ),
    );
  }

  Container setBackground() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            screenBgColor.withAlpha(255),
            screenBgColor.withAlpha(128),
            screenBgColor.withAlpha(64)
          ],
              stops: [
            0.0,
            0.8,
            1
          ])),
    );
  }

  Widget title() {
    return Padding(
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
                  LabelStr.lblReferEarn,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: MyFont.Poppins_semibold,
                      color: Colors.white),
                ),
              ))
        ],
      ),
    );
  }

  Widget bottomBtn() {
    return Expanded(
      flex: 0,
      child: Column(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: dimen.paddingExtra),
              child: Container(
                  child: ButtonRegular(
                      buttonText: LabelStr.lblInviteFnd,
                      onPressed: () async {
                        String shareUrl = await Utils.createFirstPostLink(
                            SessionImpl.getId(),
                            (SessionImpl.getLoginProfileModel()
                                    as UserInfoModel)
                                .image,
                            Messages.CDownloadApp,
                            ShareType.CReferUser);
                        share(shareUrl);
                      })),
            ),
          ),
          SizedBox(
            height: dimen.paddingExtra,
          ),
        ],
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: dimen.paddingLarge*2,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: dimen.marginLarge, right: dimen.marginLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: dimen.smallIconSize,
                  height: dimen.smallIconSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  width: dimen.paddingLarge,
                ),
                Flexible(
                  child: Text(
                    Messages.CPoint1,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: MyFont.Poppins_medium,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: dimen.paddingSmall,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: dimen.marginLarge, right: dimen.marginLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: dimen.smallIconSize,
                  height: dimen.smallIconSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  width: dimen.paddingLarge,
                ),
                Flexible(
                  child: Text(
                    Messages.CPoint2,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: MyFont.Poppins_medium,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: dimen.paddingSmall,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: dimen.marginLarge, right: dimen.marginLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: dimen.smallIconSize,
                  height: dimen.smallIconSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  width: dimen.paddingLarge,
                ),
                Flexible(
                  child: Text(
                    Messages.CPoint3,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: MyFont.Poppins_medium,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: dimen.paddingSmall,
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: dimen.marginLarge, right: dimen.marginLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: dimen.smallIconSize,
                  height: dimen.smallIconSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(
                  width: dimen.paddingLarge,
                ),
                Flexible(
                  child: Text(
                    Messages.CPoint4,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: MyFont.Poppins_medium,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> share(String shareUrl) async {
    await FlutterShare.share(
        title: LabelStr.lblTotemShare,
        text: Messages.CDownloadApp,
        linkUrl: shareUrl.toString(),
        chooserTitle: LabelStr.lblChoose);
  }
}
