import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Ui/Setting/BlockAccount.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class Privacy extends StatefulWidget {
  bool isPrivate = false;

  @override
  _PrivacyState createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  var isSucesson;
  var selectedSegmentOption = 0.obs;

  @override
  void initState() {
    isSucesson = SessionImpl.getprivacy();
    selectedSegmentOption.value = isSucesson ? 1 : 0;
    super.initState();
  }

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
                        LabelStr.lblPrivacy,
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
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(
                horizontal: dimen.paddingMedium, vertical: dimen.paddingMedium),
            margin: EdgeInsets.symmetric(horizontal: dimen.paddingMedium),
            decoration: BoxDecoration(
              color: commentBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(dimen.paddingMedium),
                  child: Text(
                    LabelStr.lbldetails,
                    style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 0.44,
                        fontFamily: MyFont.Poppins_medium,
                        color: Colors.white),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: dimen.paddingSmall, left: dimen.paddingMedium),
                      child: Text(
                        LabelStr.lblPrivateAccount,
                        style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 0.38,
                            fontFamily: MyFont.Poppins_medium,
                            color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: dimen.paddingMedium),
                      child: Text(
                        LabelStr.lblprivacydetails,
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: MyFont.poppins_regular,
                            color: Colors.white60),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: dimen.paddingMedium),
                        alignment: Alignment.topRight,
                        child: Obx(() => sliderSegementView())),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: dimen.paddingLarge,
          ),
          InkWell(
            onTap: () {
              Get.to(BlockAccount());
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                  horizontal: dimen.paddingMedium,
                  vertical: dimen.paddingMedium),
              margin: EdgeInsets.symmetric(horizontal: dimen.paddingMedium),
              decoration: BoxDecoration(
                color: commentBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(dimen.paddingMedium),
                    child: Text(
                      LabelStr.lblConnections,
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
                                left: dimen.paddingMedium),
                            child: Text(
                              LabelStr.lblBlockedAccounts,
                              style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 0.38,
                                  fontFamily: MyFont.Poppins_medium,
                                  color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: dimen.paddingMedium),
                            child: Text(
                              LabelStr.lblfriends,
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
                            right: dimen.paddingLarge,
                            bottom: dimen.paddingExtraLarge),
                        child: SvgPicture.asset(MyImage.ic_rightarrow),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _callEditPrivacy() {
    bool isSucesson = selectedSegmentOption.value == 1;
    var body = {
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CisPrivate: isSucesson,
    };
    RequestManager.postRequest(
        uri: endPoints.EditPrivacy,
        body: body,
        onSuccess: (response) {
          SessionImpl.setprivacy(isSucesson);
        },
        onFailure: () {});
  }

  Widget sliderSegementView() {
    return Container(
      height: 40,
      padding:
          EdgeInsets.only(left: dimen.paddingTiny, right: dimen.paddingTiny),
      decoration: BoxDecoration(
          border: Border.all(color: HexColor.hintColor, width: 1),
          borderRadius: BorderRadius.circular(8)),
      child: CupertinoSlidingSegmentedControl(
        thumbColor: tabActiveColor,
        groupValue: selectedSegmentOption.value,
        children: <int, Widget>{
          0: Text(
            LabelStr.lblPublic,
            style: TextStyle(
              // fontWeight: FontWeight.w800,
              fontFamily: MyFont.Poppins_medium,
              fontSize: 14,
              color: (selectedSegmentOption.value == 0)
                  ? Colors.white
                  : greyLightColor,
            ),
          ),
          1: Text(LabelStr.lblPrivate,
              style: TextStyle(
                fontFamily: MyFont.Poppins_medium,
                fontSize: 14,
                color: (selectedSegmentOption.value == 1)
                    ? Colors.white
                    : greyLightColor,
              )),
        },
        onValueChanged: (selectedValue) {
          setState(() {
            if (selectedValue != selectedSegmentOption.value) {
              selectedSegmentOption.value = selectedValue as int;
              _callEditPrivacy();
            }
          });
        },
      ),
    );
  }
}
