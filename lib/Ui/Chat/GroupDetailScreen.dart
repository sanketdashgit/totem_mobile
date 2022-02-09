import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/ConversationDetailModel.dart';
import 'package:totem_app/Models/ConversationListModel.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class GroupDetailScreen extends StatefulWidget {
  ConversationInfoModel conversationInfoModel;

  GroupDetailScreen(this.conversationInfoModel);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor, body: groupInfoView());
  }

  Widget groupInfoView() {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(50)),
      child: Column(
        children: [
          appBarView(),
          groupProfileImgView(),
          groupMemberListHeaderView(),
          groupMemberList()
        ],
      ),
    );
  }

  Widget appBarView() {
    return SizedBox(
        width: screenWidth(context),
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(
                right: ScreenUtil().setWidth(20),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: SvgPicture.asset(MyImage.ic_arrow),
                  ),
                ),
                Expanded(
                    child: Center(
                  child: Text(
                    widget.conversationInfoModel.groupName,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: MyFont.Poppins_semibold,
                        color: Colors.white),
                  ),
                )),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(16)),
            child: Container(
              height: 1,
              color: purpleDimColor,
            ),
          )
        ]));
  }

  Widget groupProfileImgView() {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setHeight(20), bottom: ScreenUtil().setHeight(20)),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(100) / 2),
          child: CachedNetworkImage(
              imageUrl: widget.conversationInfoModel.groupProfile,
              fit: BoxFit.fill,
              width: ScreenUtil().setWidth(100),
              height: ScreenUtil().setWidth(100),
              errorWidget: (context, url, error) => Image.asset(
                  "assets/bg_image/profile-pic-dummy.png",
                  fit: BoxFit.fill)),
        ),
      ),
    );
  }

  Widget groupMemberListHeaderView() {
    return Container(
        color: chatTextBorderColor,
        width: screenWidth(context),
        height: ScreenUtil().setHeight(40),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LabelStr.CGroupMember,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(14),
                    fontFamily: MyFont.poppins_regular,
                    color: Colors.white),
              ),
            ],
          ),
        ));
  }

  Widget groupMemberList() {
    return Expanded(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.conversationInfoModel.users.length,
          itemBuilder: (context, index) {
            return groupMemberInfoCardView(
                widget.conversationInfoModel.users[index]);
          }),
    );
  }

  Widget groupMemberInfoCardView(MessageUserInfoModel userInfo) {
    return Padding(
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(40) / 2),
                    child: CachedNetworkImage(
                        imageUrl: userInfo.userProfile,
                        fit: BoxFit.fill,
                        width: ScreenUtil().setWidth(40),
                        height: ScreenUtil().setWidth(40),
                        errorWidget: (context, url, error) => Image.asset(
                            "assets/bg_image/profile-pic-dummy.png",
                            fit: BoxFit.fill))),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  userInfo.userName,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(12),
                      fontFamily: MyFont.Poppins_semibold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            color: purpleDimColor,
          ),
        ],
      ),
    );
  }
}
