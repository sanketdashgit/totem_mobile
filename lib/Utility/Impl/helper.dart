import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FilterBadWord.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class Helper {
  BuildContext context;

  Helper();

  Helper.of(this.context);

  bool equalsIgnoreCase(String string1, String string2) {
    return string1?.toLowerCase()?.contains(string2?.toLowerCase());
  }

  hideKeyBoard() {
    if (context != null)
      FocusScope.of(context).requestFocus(FocusNode());
    else {
      print('context required to hide the keyboard!!');
    }
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  Future<void> _selectTime(BuildContext context, selectedTime) async {
    final TimeOfDay picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child,
          );
        });
  }

  Future<double> getFileSize(String filepath) async {
    var file = File(filepath);
    int bytes = await file.length();
    return bytes / 1000;
  }

  static String getAdId() {
    if (Platform.isAndroid) {
      return AndroidAdId; //test:"ca-app-pub-3940256099942544/2247696110";//old app id:"ca-app-pub-6510884247700598/3949204599";//test
    } else {
      return iOSAdId; //test"ca-app-pub-3940256099942544/3986624511";
    }
  }

  Future<String> badWordAlert(comment) async {
    String msgStr /* = FilterBadWord().clean(comment.trim())*/;
    var returnValue = await Get.defaultDialog(
        title: LabelStr.lblOffenciveWord,
        titleStyle:
            TextStyle(fontSize: dimen.textLarge, fontFamily: MyFont.SFPro_bold),
        middleText: LabelStr.lblBadWordAlertMsg,
        middleTextStyle: TextStyle(
            fontSize: dimen.textNormal, fontFamily: MyFont.Poppins_medium),
        textConfirm: "  ${LabelStr.lblRemove}  ",
        confirmTextColor: whiteTextColor,
        textCancel: "  Edit  ",
        cancelTextColor: Colors.green.withOpacity(.8),
        buttonColor: Colors.green,
        onConfirm: () {
          msgStr = FilterBadWord().clean(comment.trim());
          // return msgStr;
          Get.back(result: msgStr);
          return msgStr;
        });
    return returnValue;
  }
}
