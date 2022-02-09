import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/Models/UserComments.dart';
import 'package:get/get.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class CommentBarBottomSheet extends StatelessWidget {

  List<UserComments> _listforyou = <UserComments>[].obs;


  @override
  Widget build(BuildContext context) {

    return _bottomSheet(context);
  }

  _bottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: commentBottomSheetBgColor,
        builder: (BuildContext c) {
          return Container(
            height: ScreenUtil().setHeight(300),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: screenBgLightColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SingleChildScrollView(
                  child: _favoritelist(),
                )
              ],
            ),
          );
        });
  }

  _favoritelist() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _listforyou.length,
      itemBuilder: (context, index) {
        var item = _listforyou[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: CircleAvatar(
                backgroundImage: AssetImage(item.pic),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: MyFont.poppins_regular,
                          color: Colors.white),
                    ),
                    Text(
                      item.comment,
                      maxLines: 3,
                      style: TextStyle(
                          fontFamily: MyFont.poppins_regular,
                          fontSize: 10,
                          color: HexColor.textColor),
                    ),
                    Divider(
                      color: chatTextBorderColor,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
