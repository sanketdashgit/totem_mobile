import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';

import 'Models/GetfollowerCountModel.dart';
import 'Ui/Post/PostDetail.dart';
import 'Ui/Profile/OtherUserProfile.dart';
import 'Utility/UI/ColorPallete.dart';
import 'WebService/RequestManager.dart';

class TotemApp extends StatefulWidget {
  TotemApp({Key key, this.defaultWidgets}) : super(key: key);
  final Widget defaultWidgets;

  @override
  _TotemAppState createState() => _TotemAppState();
}

class _TotemAppState extends State<TotemApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    _callUserLiveStatus(1);
    WidgetsBinding.instance.addObserver(this);
    _initDynamicLinks();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.index == 0) {
      _callUserLiveStatus(1);
    } else if (state.index == 2) {
      _callUserLiveStatus(0);
    }
  }

  void _initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;
          _fetchDeepLinkData(deepLink);
        },
        onError: (OnLinkErrorException e) async {});
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    _fetchDeepLinkData(deepLink);
  }

  _fetchDeepLinkData(Uri deepLink) {
    var id = deepLink.queryParameters[Parameters.Cid];
    var type = deepLink.queryParameters[Parameters.CType];
    if (deepLink != null) {
      if (SessionImpl.getId() != 0) {
        if (type == ShareType.CShareUser) {
          _getFollowerCount({
            Parameters.CUserId: SessionImpl.getId(),
            Parameters.Cid: int.parse(id)
          });
        } else if (type == ShareType.CSharePost) {
          //open post page
          Get.to(PostDetail(int.parse(id)));
        }
      }
      if (type == ShareType.CReferUser) {
        rq.referId = int.parse(id);
      }
    }
  }

  _getFollowerCount(Map<String, dynamic> params) {
    RequestManager.postRequest(
        uri: endPoints.GetfollowerCount,
        body: params,
        isLoader: true,
        isFailedMessage: false,
        isSuccessMessage: false,
        onSuccess: (response) {
          GetfollowerCountModel countModel =
              GetfollowerCountModel.fromJson(response);
          Get.to(OtherUserProfile(
              countModel.profileDetails.id,
              countModel.profileDetails.firstname,
              countModel.profileDetails.username,
              countModel.profileDetails.profileVerified,
              countModel.profileDetails.image));
        },
        onFailure: () {});
  }

  _callUserLiveStatus(int status) {
    var param = {
      Parameters.CPresentLiveStatus: status,
      Parameters.Cid: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.PresentLiveStatus,
        body: param,
        isLoader: false,
        isFailedMessage: false,
        isSuccessMessage: false,
        onSuccess: (response) {},
        onFailure: () {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: screenBgColor,
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: screenBgLightColor,
      systemNavigationBarIconBrightness: Brightness.light, //navigation bar icon
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: () => GetMaterialApp(
        title: LabelStr.lblTotem,
        color: primarySwatchOrg,
        theme: ThemeData(
          primaryColor: primaryColor,
          primarySwatch: primarySwatchOrg,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: widget.defaultWidgets,
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
      ),
    );
  }
}
