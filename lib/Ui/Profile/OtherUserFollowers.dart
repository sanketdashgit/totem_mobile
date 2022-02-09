import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

import 'FollowerTab.dart';

class OtherUserFollowers extends StatefulWidget {
  final int id;
  const OtherUserFollowers(this.id);

  @override
  _OtherUserFollowersState createState() => _OtherUserFollowersState();
}

class _OtherUserFollowersState extends State<OtherUserFollowers> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      appBar: AppBar(
        centerTitle: true,
          brightness: Brightness.dark,
        backgroundColor: screenBgColor,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined),
              onPressed: () {
                Get.back();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: Text(LabelStr.lblFollowers,
            style: TextStyle(
                fontSize: 16, fontFamily: MyFont.Poppins_semibold))

      ),
      body: FollowerTab(
          id : widget.id
      ),
    );
  }
}
