import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:get/get.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class PushNotification extends StatefulWidget {

  @override
  _PushNotificationState createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> {
  bool isEventNotification = false;
  bool isFollowNotification = false;
  bool isMessageNotification = false;
  UserInfoModel info;


  @override
  void initState() {
    super.initState();
    info = SessionImpl.getLoginProfileModel();
    isEventNotification = info.eventNotification;
    isFollowNotification = info.followNotification;
    isMessageNotification = info.messageNotification;
  }

  void _manageNotificationApi() {
    var body = {
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CMessageNotification: isMessageNotification,
      Parameters.CEventNotification: isEventNotification,
      Parameters.CFollowNotification: isFollowNotification,

    };
    RequestManager.postRequest(
        uri: endPoints.ConfigNotification,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          info.messageNotification = isMessageNotification;
          info.followNotification = isFollowNotification;
          info.eventNotification = isEventNotification;
          SessionImpl.setLoginProfileModel(info);
        },
        onFailure: (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Column(
        children: <Widget>[
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
                        LabelStr.lblPrivacyNav,
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
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.symmetric(
                horizontal: dimen.paddingMedium, vertical: dimen.paddingMedium),
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
                      top: dimen.paddingExtraLarge,
                      left: dimen.paddingMedium),
                  child: Text(
                    LabelStr.lblPrivacyNav,
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
                            left: dimen.paddingMedium,),
                          child: Text(
                            LabelStr.lblEvents,
                            //LabelStr.lblPersonalInformation,
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
                              ),
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
                      padding: EdgeInsets.only(bottom: dimen.paddingMedium),
                      child: Switch(
                        value: isEventNotification,
                        onChanged: (value) {
                          setState(() {
                            isEventNotification = value;
                          });
                          _manageNotificationApi();
                        },
                        activeTrackColor: switchButtonColor,
                        activeColor: switchButtonactiveColor,
                        inactiveThumbColor:switchButtonactiveColor,
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: dividerLineColor,
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
                            left: dimen.paddingMedium,),
                          child: Text(
                            LabelStr.lblFollowRequests,
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
                            LabelStr.lblRequestaccount,
                            //LabelStr.lblPersonalInfo,
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: MyFont.poppins_regular,
                                color: Colors.white60),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: dimen.paddingExtraLarge),
                      child: Switch(
                        value: isFollowNotification,
                        onChanged: (value) {
                          setState(() {
                            isFollowNotification = value;
                          });
                          _manageNotificationApi();
                        },
                        activeTrackColor: switchButtonColor,
                        activeColor: switchButtonactiveColor,
                        inactiveThumbColor:switchButtonactiveColor,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
          SizedBox(
            height: dimen.paddingExtraLarge,
          ),
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: EdgeInsets.symmetric(
                horizontal: dimen.paddingMedium, vertical: dimen.paddingMedium),
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
                    LabelStr.lblTextMessageNotification,
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
                            top: dimen.paddingLarge,
                            left: dimen.paddingMedium,),
                          child: Text(
                            LabelStr.lblMessage,
                            //LabelStr.lblPersonalInformation,
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
                      padding: EdgeInsets.only(bottom: dimen.paddingExtraLarge),
                      child: Switch(
                        value: isMessageNotification,
                        onChanged: (value) {
                          setState(() {
                            isMessageNotification = value;
                          });
                          _manageNotificationApi();
                        },
                        activeTrackColor: switchButtonColor,
                        activeColor: switchButtonactiveColor,
                        inactiveThumbColor:switchButtonactiveColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
