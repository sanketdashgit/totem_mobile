import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path/path.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/Utils.dart';
import 'package:totem_app/Ui/Profile/ProfileScreen.dart';
import 'package:totem_app/Ui/Setting/BlockAccount.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class OtherUserProfile extends StatefulWidget {
  int id;
  String name;
  String username;
  bool profileVerified;
  String image;

  OtherUserProfile(this.id, this.name, this.username,
      this.profileVerified, this.image);

  @override
  _OtherUserProfileState createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  var isButtonLoaderEnabled = false.obs;

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
        title: widget.id == SessionImpl.getId()
            ? Text(widget.name,
                style: TextStyle(
                    fontSize: 16, fontFamily: MyFont.Poppins_semibold))
            :
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis ,
                  style: TextStyle(
                      fontSize: dimen.textMedium,
                      fontFamily: MyFont.Poppins_semibold,
                      color: whiteTextColor)),
              widget.profileVerified
                  ? Padding(
                padding:
                const EdgeInsets.only(left: dimen.paddingVerySmall),
                child: SvgPicture.asset(
                  MyImage.ic_verified,
                  height: 20,
                  width: 20,
                ),
              )
                  : Container(),
            ],
          ),
        actions: <Widget>[
          InkWell(
              onTap: () {
                _bottomSheet(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: dimen.paddingLarge),
                child: SvgPicture.asset(MyImage.ic_popup_menu_indicator),
              ))
        ],
      ),
      body: ProfileScreen(
        widget.id
      ),
    );
  }

  _bottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: screenBgColor,
        builder: (BuildContext c) {
          return Container(
            height: ScreenUtil().setHeight(200),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: roundedcontainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                  child: Center(child: SvgPicture.asset(MyImage.ic_line)),
                ),
                InkWell(
                  onTap: () {
                    isButtonLoaderEnabled.value = true;
                    _callBlockUser();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(20),
                        left: ScreenUtil().setWidth(28)),
                    child: Text(
                      LabelStr.lblBlock,
                      style: TextStyle(
                          fontFamily: MyFont.poppins_regular,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    String copyUrl = await Utils.createFirstPostLink(
                        widget.id,
                        widget.image,
                        ' ${widget.name}',ShareType.CShareUser);
                    print(copyUrl);
                    Get.back();
                    Clipboard.setData(ClipboardData(text: copyUrl.toString()));
                    RequestManager.getSnackToast(
                        title: LabelStr.lblCopied,
                        backgroundColor: Colors.black,
                        message: Messages.CURLCopied);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(15),
                        left: ScreenUtil().setWidth(28)),
                    child: Text(
                      LabelStr.lblCopyProfileURL,
                      style: TextStyle(
                          fontFamily: MyFont.poppins_regular,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(15),
                      left: ScreenUtil().setWidth(28)),
                  child: Text(
                    LabelStr.lblSendMessage,
                    style: TextStyle(
                        fontFamily: MyFont.poppins_regular,
                        fontSize: 12,
                        color: Colors.white),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    String copyUrl = await Utils.createFirstPostLink(
                        widget.id,
                        widget.image,
                        '${Messages.CCheckProfile} ${widget.name}',ShareType.CShareUser);
                    share(copyUrl);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(15),
                        left: ScreenUtil().setWidth(28),
                        bottom: ScreenUtil().setHeight(15)),
                    child: Text(
                      LabelStr.lblProfileShare,
                      style: TextStyle(
                          fontFamily: MyFont.poppins_regular,
                          fontSize: 12,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> share(String shareUrl) async {
    await FlutterShare.share(
        title: 'Totem share',
        text: 'Totem',
        linkUrl: shareUrl.toString(),
        chooserTitle: 'Choose');
  }

  void _callBlockUser() {
    var body = {
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CblockId: widget.id,
    };
    RequestManager.postRequest(
        uri: endPoints.BlockUser,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        onSuccess: (response) {
          Get.back();
          RequestManager.getSnackToast(
            message: Messages.CBlocked,
            title: LabelStr.lblBlocked,
            backgroundColor: Colors.black,
          );
        },
        onFailure: (error) {});
  }
}
