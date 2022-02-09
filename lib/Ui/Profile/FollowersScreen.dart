import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Ui/Profile/FollowerTab.dart';
import 'package:totem_app/Ui/Profile/FollowingTab.dart';
import 'package:totem_app/Ui/Profile/SuggestedTab.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:get/get.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class FollowersScreen extends StatefulWidget {
  int id;

  FollowersScreen(this.id);

  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Widget> list = <Widget>[
    FollowerTab(),
    FollowingTab(),
    SuggestedTab(),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      initialIndex: 1,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        widget.id = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          SessionImpl.getName(),
          style: TextStyle(
              color: Colors.white,
              fontFamily: MyFont.Poppins_semibold,
              fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 45.0),
          child: Padding(
            padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: Row(
              children: [
                SizedBox(
                  width: 15.0,
                ),
                Expanded(child: sliderSegementView())
              ],
            ),
          ),
        ),
      ),
      body: list[widget.id],
    );
  }

  Widget sliderSegementView() {
    return Padding(
      padding: EdgeInsets.only(
          left: 20.0, right: 20.0, top: ScreenUtil().setHeight(10)),
      child: Container(
        height: 35,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border.all(color: HexColor.hintColor, width: 1),
            borderRadius: BorderRadius.circular(8)),
        child: CupertinoSlidingSegmentedControl(
          //backgroundColor: Colors.white,
          thumbColor: tabActiveColor,
          groupValue: widget.id,
          children: <int, Widget>{
            0: Text(
              LabelStr.lblFollowers,
              style: TextStyle(
                fontFamily: MyFont.Poppins_medium,
                fontSize: 14,
                color: (widget.id == 0) ? Colors.white : blueGrayColor,
              ),
            ),
            1: Text(LabelStr.lblFollowing,
                style: TextStyle(
                  fontFamily: MyFont.Poppins_medium,
                  fontSize: 14,
                  color: (widget.id == 1) ? Colors.white : blueGrayColor,
                )),
            2: Text(
              LabelStr.lblSuggested,
              style: TextStyle(
                fontFamily: MyFont.Poppins_medium,
                fontSize: 14,
                color: (widget.id == 2) ? Colors.white : blueGrayColor,
              ),
            ),
          },
          onValueChanged: (selectedValue) {
            setState(() {
              widget.id = selectedValue as int;
              //pullToRefresh();
            });
          },
        ),
      ),
    );
  }
}
