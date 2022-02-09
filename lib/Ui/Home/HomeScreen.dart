import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Home/HomeEvent.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import 'HomeFeed.dart';

class HomeScreen extends StatefulWidget {
  int selectedSegmentOption = 0;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> pageList = [
    HomeFeed(0, SessionImpl.getId(), 0, false),
    HomeEvent(true, false)
  ];

  Intro intro;

  void setupIntro() {
    intro = Intro(
      noAnimation: false,
      maskColor: Colors.black.withAlpha(170),
      stepCount: 2,
      maskClosable: false,
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          IntroMessage.lblIntro3,
          IntroMessage.lblIntro31,
        ],
        buttonTextBuilder: (currPage, totalPage) {
          if (currPage < totalPage - 1) {
            return LabelStr.lblNext;
          } else {
            SessionImpl.setIntro5(true);
            return LabelStr.lblNext;
          }
        },
      ),
    );
    intro.setStepConfig(1, padding: EdgeInsets.only(top: 70));
  }

  var isIntroDone = false;

  void startIntro5() {
    if (!SessionImpl.getIntro5()) {
      if (!isIntroDone) {
        isIntroDone = true;
        intro.start(context);
      }
    }
  }

  @override
  void initState() {
    setupIntro();
    super.initState();
    _callGetAllUserStatus();
  }

  void _callGetAllUserStatus() {
    var body = {
      Parameters.Cid: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.GetAllUserStatus,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          UserInfoModel userModel = UserInfoModel.fromJson(response);
          SessionImpl.setNewToken(userModel.token);
          SessionImpl.setLoginProfileModel(userModel);
          startIntro5();
        },
        onFailure: (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sliderSegementView(),
        SizedBox(height: 5),
        Expanded(
          flex: 1,
          child: Container(
            child: pageList[widget.selectedSegmentOption],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            key: intro.keys[1],
            width: 60,
            height: 60,
          ),
        ),
      ],
    );
  }

  Widget sliderSegementView() {
    return Container(
      key: intro.keys[0],
      height: 40,
      margin:
          EdgeInsets.only(left: dimen.marginMedium, right: dimen.marginMedium),
      padding:
          EdgeInsets.only(left: dimen.paddingTiny, right: dimen.paddingTiny),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(color: HexColor.hintColor, width: 1),
          borderRadius: BorderRadius.circular(8)),
      child: CupertinoSlidingSegmentedControl(
        thumbColor: tabActiveColor,
        groupValue: widget.selectedSegmentOption,
        children: <int, Widget>{
          0: Text(
            LabelStr.lblFeed,
            style: TextStyle(
              fontFamily: MyFont.Poppins_medium,
              fontSize: 14,
              color: (widget.selectedSegmentOption == 0)
                  ? Colors.white
                  : greyLightColor,
            ),
          ),
          1: Text(LabelStr.lblEvent,
              style: TextStyle(
                fontFamily: MyFont.Poppins_medium,
                fontSize: 14,
                color: (widget.selectedSegmentOption == 1)
                    ? Colors.white
                    : greyLightColor,
              ))
        },
        onValueChanged: (selectedValue) {
          setState(() {
            widget.selectedSegmentOption = selectedValue as int;
          });
        },
      ),
    );
  }
}
