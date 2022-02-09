import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/BNBCustomPainter%20.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/CommonStuff.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/NavigationIndicatorCustomPainter.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Chat/ChatListScreen.dart';
import 'package:totem_app/Ui/ExploreScreen.dart';
import 'package:totem_app/Ui/Home/HomeScreen.dart';
import 'package:totem_app/Ui/Notification/NotificationScreen.dart';
import 'package:totem_app/Ui/Post/AddNewPost.dart';
import 'package:totem_app/Ui/Profile/CreateProfile.dart';
import 'package:totem_app/Ui/Profile/ProfileScreen.dart';
import 'package:totem_app/Ui/Setting/ApplyforVerifcation.dart';
import 'package:totem_app/Ui/Setting/BusinessAccount.dart';
import 'package:totem_app/Ui/Setting/InviteFriends.dart';
import 'package:totem_app/Ui/Setting/ReferFriends.dart';
import 'package:totem_app/Ui/Setting/Setting.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

import 'Customs/CommonNetworkImage.dart';
import 'LRF/SignInScreen.dart';

class NavigationDrawerScreen extends StatefulWidget {
  int index = 7;

  NavigationDrawerScreen(this.index);

  @override
  _NavigationDrawerScreenState createState() => _NavigationDrawerScreenState();
}

class _NavigationDrawerScreenState extends State<NavigationDrawerScreen> {
  int listindex = 7;
  Intro intro;
  GlobalKey<ProfileScreenState> _profileKey = GlobalKey();
  List<Widget> list = [];

  setBottomBarIndex(index) {
    if (index == 8 || index == 1) {
      Get.to(ChatListScreen());
    } else {
      setState(() {
        listindex = index;
      });
    }
  }

  @override
  void initState() {
    list = <Widget>[
      ProfileScreen(
        SessionImpl.getId(),
        key: _profileKey,
      ),
      ChatListScreen(),
      BusinessAccount(),
      ApplyforVerifcation(),
      Setting(),
      InviteFriends(),
      Setting(),
      HomeScreen(),
      ChatListScreen(),
      ProfileScreen(SessionImpl.getId(), key: _profileKey),
      ExploreScreen(),
    ];
    listindex = widget.index;
    List<String> texts = [
      IntroMessage.lblIntro5,
      IntroMessage.lblIntro6,
      IntroMessage.lblIntro7,
    ];
    intro = Intro(
      noAnimation: false,
      maskColor: Colors.black.withAlpha(170),
      stepCount: 3,
      maskClosable: false,
      widgetBuilder: StepWidgetBuilder.useAdvancedTheme(
        widgetBuilder: (params) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.6),
            ),
            child: Column(
              children: [
                Text(
                  texts[params.currentStepIndex],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    overlayColor: MaterialStateProperty.all<Color>(
                      Colors.white.withOpacity(0.1),
                    ),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 8,
                      ),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      StadiumBorder(),
                    ),
                  ),
                  onPressed: () {
                    if (params.currentStepIndex < params.stepCount - 1) {
                      params.onNext();
                    } else {
                      params.onFinish();
                      SessionImpl.setIntro1(true);
                      _profileKey.currentState.startIntro();
                    }
                  },
                  child: Text(
                    params.currentStepIndex < params.stepCount - 1
                        ? LabelStr.lblNext
                        : LabelStr.lblNext,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );

    Future.delayed(Duration(seconds: 1)).then((value) => startIntro());
    super.initState();
  }

  void startIntro() {
    if (!SessionImpl.getIntro1()) {
      intro.start(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: darkPurple,
          extendBody: true,
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: dimen.dividerHeightXLarge,
                ),
                width: double.infinity,
                height: dimen.appBarHeight,
                padding: EdgeInsets.only(
                    left: dimen.paddingExtraLarge,
                    right: dimen.paddingExtraLarge),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      MyImage.ic_totemText,
                      height: 15,
                      width: 30,
                    ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(left: dimen.paddingSmall),
                        child: Text(
                          SessionImpl.getName(),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: dimen.textMedium,
                              fontFamily: MyFont.Poppins_semibold,
                              color: whiteTextColor),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                              key: intro.keys[1],
                            ),
                            onPressed: () {
                              Get.to(NotificationScreen());
                            }),
                        Builder(
                            key: intro.keys[2],
                            builder: (context) => InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: (() =>
                                      Scaffold.of(context).openDrawer()),
                                  child: SvgPicture.asset(
                                    MyImage.ic_drawer_icon,
                                    color: Colors.white,
                                  ),
                                )),
                      ],
                    )
                  ],
                ),
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 0,
                  child: Center(
                    key: intro.keys[0],
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                      margin: EdgeInsets.only(top: dimen.marginSmall),
                      child: list[listindex])),
            ],
          ),
          drawer: Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: MyDrawerApp(onTap: (context, i) {
              setBottomBarIndex(i);
            }),
          ),
          floatingActionButton: rq.isShowFloatBtn.value
              ? FloatingActionButton(
                  splashColor: Colors.transparent,
                  backgroundColor: purple550,
                  child: SvgPicture.asset(
                    MyImage.ic_navcreate,
                    color: whiteTextColor,
                  ),
                  onPressed: () {
                    Get.to(AddNewPost(LabelStr.lblAddPost)).then((value) => {
                          rq.widgetRefresher.value = Utilities.getRandomString()
                        });
                  },
                )
              : Container(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: Stack(
            children: [
              Container(
                height: 100,
                color: Colors.transparent,
                padding: EdgeInsets.only(
                    left: dimen.paddingExtraLarge,
                    right: dimen.paddingExtraLarge,
                    bottom: dimen.paddingExtraLarge),
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 100),
                  painter: BNBCustomPainter(),
                ),
              ),
              bottomNavigationBar()
            ],
          ),
        ));
  }

  Widget bottomNavigationBar() {
    return Container(
      height: 66,
      margin: EdgeInsets.only(left: 20, right: 20, top: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MaterialButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  minWidth: 40,
                  padding: EdgeInsets.only(left: 30.0),
                  onPressed: () {
                    setBottomBarIndex(7);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(MyImage.ic_navhome,
                          color: listindex == 7
                              ? purple450
                              : purple300),
                      Text(
                        LabelStr.lblHome,
                        style: TextStyle(
                            color: listindex == 7
                                ? purple450
                                : purple400,
                            fontSize: 13,
                            fontFamily: MyFont.Poppins_medium),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 4),
                          height: 7,
                          width: 30,
                          child: CustomPaint(
                            painter: NavigationIndicatorCustomPainter(
                                listindex == 7
                                    ? purple450
                                    : colorZero),
                          ))
                    ],
                  ),
                ),
                MaterialButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  padding: EdgeInsets.only(top: 5.0, left: 30.0),
                  minWidth: 40,
                  onPressed: () {
                    setBottomBarIndex(8);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        MyImage.ic_floaticon,
                        height: dimen.navigationBarIconHeight,
                        width: dimen.navigationBarIconWidth,
                        color: listindex == 8
                            ? purple450
                            : purple300,
                      ),
                      Text(
                        LabelStr.lblChat,
                        style: TextStyle(
                            color: listindex == 8
                                ? purple450
                                : purple400,
                            fontSize: 13,
                            fontFamily: MyFont.Poppins_medium),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 4),
                          height: 7,
                          width: 30,
                          child: CustomPaint(
                            painter: NavigationIndicatorCustomPainter(
                                listindex == 8
                                    ? purple450
                                    : colorZero),
                          ))
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MaterialButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  padding: EdgeInsets.only(top: 8.0, right: 28.0),
                  minWidth: 40,
                  onPressed: () {
                    setBottomBarIndex(9);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        MyImage.ic_profile_person,
                        height: 23,
                        color: listindex == 9
                            ? purple450
                            : purple300,
                      ),
                      Text(
                        LabelStr.lblProfile,
                        style: TextStyle(
                            color: listindex == 9
                                ? purple450
                                : purple400,
                            fontSize: 13,
                            fontFamily: MyFont.Poppins_medium),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 4),
                          height: 7,
                          width: 30,
                          child: CustomPaint(
                            painter: NavigationIndicatorCustomPainter(
                                listindex == 9
                                    ? purple450
                                    : colorZero),
                          ))
                    ],
                  ),
                ),
                MaterialButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  padding: EdgeInsets.only(top: 8.0, right: 30.0),
                  minWidth: 40,
                  onPressed: () {
                    setBottomBarIndex(10);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        MyImage.ic_search,
                        height: 23,
                        color: listindex == 10
                            ? purple450
                            : purple300,
                      ),
                      Text(
                        LabelStr.lblExplore,
                        style: TextStyle(
                            color: listindex == 10
                                ? purple450
                                : purple400,
                            fontSize: 13,
                            fontFamily: MyFont.Poppins_medium),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 4),
                          height: 7,
                          width: 30,
                          child: CustomPaint(
                            painter: NavigationIndicatorCustomPainter(
                                listindex == 10
                                    ? purple450
                                    : colorZero),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ]),
    );
  }
}

class MyDrawerApp extends StatelessWidget {
  final Function onTap;

  MyDrawerApp({this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(50)),
                      color: switchButtonactiveColor),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(30),
                        right: ScreenUtil().setWidth(30)),
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              rq.selectedEvents = [];
                              rq.selectedArtist = [];
                              rq.selectedGener = [];
                              rq.selectedTracks = [];
                              Get.to(CreateProfile(
                                isEdit: true,
                              ));
                            },
                            child: Row(
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2,
                                          color: HexColor.borderColor),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CommonNetworkImage(
                                      height: 60,
                                      width: 60,
                                      radius: 30,
                                      imageUrl:
                                          (SessionImpl.getLoginProfileModel()
                                                  as UserInfoModel)
                                              .image,
                                    )),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(15)),
                                      child: Text(
                                        SessionImpl.getName(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: MyFont.Poppins_semibold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: ScreenUtil().setHeight(84)),
                              child: SvgPicture.asset(MyImage.ic_cross)),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: SvgPicture.asset(MyImage.ic_usericon),
                  title: Text(
                    LabelStr.lblReferFnd,
                    style: TextStyle(
                        fontFamily: MyFont.Poppins_medium,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  onTap: () async {
                    Get.to(ReferFriends());
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(MyImage.ic_messageicon),
                  title: Text(
                    LabelStr.lblMessage,
                    style: TextStyle(
                        fontFamily: MyFont.Poppins_medium,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  onTap: () => onTap(context, 1),
                ),
                ListTile(
                  leading: SvgPicture.asset(MyImage.ic_toggleLefticon),
                  title: Text(
                    Messages.CSwitchBusiness,
                    style: TextStyle(
                        fontFamily: MyFont.Poppins_medium,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  onTap: () {
                    UserInfoModel user =
                        (SessionImpl.getLoginProfileModel() as UserInfoModel);
                    if (user.bussinessUser == true) {
                      showAlertDialog(
                          context, Messages.CBusinessUser);
                    } else if (user.isBusinessRequestSend == true) {
                      showAlertDialog(context,
                          Messages.CRequestAdmin);
                    } else {
                      Get.to(BusinessAccount());
                    }
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    MyImage.ic_smartphoneicon,
                  ),
                  title: Text(
                    LabelStr.lblapplyforVerifcation,
                    style: TextStyle(
                        fontFamily: MyFont.Poppins_medium,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  onTap: () {
                    UserInfoModel user =
                        (SessionImpl.getLoginProfileModel() as UserInfoModel);
                    if (user.profileVerified == true) {
                      showAlertDialog(
                          context, Messages.CVerifyProfile);
                    } else if (user.isProfileVarificationRequestSend == true) {
                      showAlertDialog(context,
                          Messages.CVerifySMS);
                    } else {
                      Get.to(ApplyforVerifcation());
                    }
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(MyImage.ic_settings),
                  title: Text(
                    LabelStr.lblSettings,
                    style: TextStyle(
                        fontFamily: MyFont.Poppins_medium,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                  onTap: () {
                    Get.to(Setting());
                  },
                ),
                Expanded(child: Container()),
                Padding(
                  padding: const EdgeInsets.only(bottom: dimen.paddingBigLarge),
                  child: ListTile(
                    leading: SvgPicture.asset(MyImage.ic_logouticon),
                    title: Text(
                      LabelStr.lblLogout,
                      style: TextStyle(
                          fontFamily: MyFont.Poppins_medium,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                    onTap: () {
                      showAlertDialogLogout(context);
                      // logOut();
                      // Get.offAll(SignInScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String title) {
    Widget okButton = TextButton(
      child: Text(LabelStr.lblOK),
      onPressed: () {
        Get.back();
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style: TextStyle(fontFamily: MyFont.Poppins_medium, fontSize: 14),
      ),
      actions: [
        okButton,
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

  showAlertDialogForEvent(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(LabelStr.lblOK),
      onPressed: () {
        Get.back();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        Messages.CVerifyEmail,
        style: TextStyle(fontFamily: MyFont.Poppins_medium, fontSize: 14),
      ),
      actions: [
        okButton,
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

  showAlertDialogLogout(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(LabelStr.lblNo),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: Text(LabelStr.lblYes),
      onPressed: () {
        logOut();
        Get.offAll(SignInScreen());
        // Get.back();
        // Get.back();
        //_callDeletePostApi(index);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(LabelStr.lblLogout+"?"),
      content: Text(Messages.CLogout),
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
}
