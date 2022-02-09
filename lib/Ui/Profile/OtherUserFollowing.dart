import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Ui/Profile/FollowingTab.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class OtherUserFollowing extends StatefulWidget {
  final int id;

  OtherUserFollowing(this.id);

  @override
  _OtherUserFollowingState createState() => _OtherUserFollowingState();
}

class _OtherUserFollowingState extends State<OtherUserFollowing> {
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
          title: Text(LabelStr.lblFollowing,
              style: TextStyle(
                  fontSize: 16, fontFamily: MyFont.Poppins_semibold))),
      body: FollowingTab(id: widget.id),
    );
  }
}
