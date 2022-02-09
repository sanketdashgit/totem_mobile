import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/Ui/Home/HomeFeed.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class PostListing extends StatefulWidget {
  const PostListing(this.getSelf,this.title,this.id,this.eventId);
  final int getSelf;
  final String title;
  final int id;
  final int eventId;

  @override
  _PostListingState createState() => _PostListingState();
}

class _PostListingState extends State<PostListing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.dark,
        backgroundColor: screenBgColor,
        leading: Padding(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Get.back();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
              color: Colors.white,
              fontFamily: MyFont.Poppins_semibold,
              fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 5.0),
          child: Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: SizedBox(
              width: 15.0,
            ),
          ),
        ),
      ),
      body: HomeFeed(widget.getSelf,widget.id,widget.eventId,false),
    );
  }
}
