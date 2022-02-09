import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:totem_app/Ui/Home/HomeFeed.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class PostDetail extends StatefulWidget {
  final int id;
  const PostDetail(this.id);

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
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
      ),
      body: HomeFeed(0,SessionImpl.getId(),0,false,postId: widget.id,),
    );
  }
}
