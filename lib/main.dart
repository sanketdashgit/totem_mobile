//@dart=2.9
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:totem_app/Ui/LRF/SignInScreen.dart';
import 'package:totem_app/Ui/NavigationDrawerScreen.dart';
import 'package:totem_app/app.dart';

import 'GeneralUtils/CommonStuff.dart';
import 'GeneralUtils/FCMService.dart';
import 'GeneralUtils/LabelStr.dart';
import 'Utility/Impl/sessionImpl.dart';
import 'Utility/UI/ColorPallete.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionImpl().init();
  await Firebase.initializeApp();
  FCMService().registerNotification();
  FCMService().getFCMToken();
  await forceUpdate();

  MobileAds.initialize();
  // This is my device id. Ad yours here
  //MobileAds.setTestDeviceIds(['9345804C1E5B8F0871DFE29CA0758842']);

  HttpOverrides.global = new MyHttpOverrides();
  TotemApp app = TotemApp();
  if (SessionImpl.isLogin()) {
    app = TotemApp(defaultWidgets: NavigationDrawerScreen(9));
  } else {
    app = TotemApp(defaultWidgets: SignInScreen());
  }
  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(375, 812),
        builder: () => GetMaterialApp(
              title: LabelStr.lblTotem,
              home: SignInScreen(),
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  primaryColor: screenBgColor,
                  iconTheme: IconThemeData(color: grey500)),
            ));
  }
}
