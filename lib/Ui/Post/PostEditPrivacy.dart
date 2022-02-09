import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class PostEditPrivacy extends StatefulWidget {
  int postId = 0;
  bool isPrivate = false;
  PostEditPrivacy(this.postId,this.isPrivate);
  @override
  _PostEditPrivacyState createState() => _PostEditPrivacyState();
}

class _PostEditPrivacyState extends State<PostEditPrivacy> {
  var pageSelectOption = 0.obs;

  @override
  void initState() {
    super.initState();
    pageSelectOption.value = widget.isPrivate ? 1 : 0;
  }

  _editPostPrivacy() {
    bool isSwitched = pageSelectOption.value == 1;
    var params = {
      Parameters.CPostId: widget.postId,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CIsPrivate: isSwitched,
    };
    RequestManager.postRequest(
        uri: endPoints.editPostPrivacy,
        body: params,
        isFailedMessage: true,
        isSuccessMessage: true,
        isLoader: false,
        onSuccess: (response) {
          //Get.back(result: isSwitched);
          //RequestManager.getSnackToast(title: "Changed",message: "Post privacy successfully Changed",backgroundColor: Colors.black);
        },
        onFailure: () {

        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Get.back(result: pageSelectOption.value == 1);
        return false;
      },
      child: Scaffold(
        backgroundColor: screenBgColor,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(50),
                  left: ScreenUtil().setWidth(20),
                  right: ScreenUtil().setWidth(20)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                      onTap: () {
                        Get.back(result: pageSelectOption.value == 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                        child: SvgPicture.asset(MyImage.ic_arrow),
                      )),
                  Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          LabelStr.lblEditPrivacy,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: MyFont.Poppins_semibold,
                              color: Colors.white),
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(
              height: dimen.paddingExtraLarge,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  top: ScreenUtil().setHeight(29),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0)),
                    color: roundedcontainer),
                height: double.infinity,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(
                    left: dimen.paddingExtraLarge,
                    right: dimen.paddingExtraLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(top: dimen.paddingExtraLarge),
                      child: Text(
                        Messages.CWhoPost,
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: MyFont.Poppins_semibold,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: dimen.paddingSmall,
                    ),
                    Text(
                      Messages.CPublicPost,
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: MyFont.poppins_regular,
                          color: Colors.white60),
                    ),
                    SizedBox(
                      height: dimen.paddingMedium,
                    ),
                    Divider(
                      color: dividerLineColordark,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: dimen.paddingMedium),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(MyImage.ic_plussquare),
                          Padding(
                            padding: EdgeInsets.only(left: dimen.paddingMedium),
                            child: Text(
                              LabelStr.lblPosts,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: MyFont.Poppins_semibold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: dimen.paddingBigLarge),
                      child: Text(
                        LabelStr.lblPoststoggle,
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: MyFont.poppins_regular,
                            color: Colors.white60),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: dimen.paddingMedium),
                      alignment: Alignment.topRight,
                        child: Obx(() => toggleView())),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget toggleView(){
    return  Container(
      padding:
      EdgeInsets.only(left: dimen.paddingTiny, right: dimen.paddingTiny),
      height: 40,
      decoration: BoxDecoration(
          border: Border.all(color: HexColor.hintColor, width: 1),
          borderRadius: BorderRadius.circular(8)),
      child: CupertinoSlidingSegmentedControl(
        thumbColor: Color.fromRGBO(85, 199, 205, 1),
        groupValue: pageSelectOption.value,
        children: <int, Widget>{
          0: Text(
            LabelStr.lblPublic,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: (pageSelectOption.value == 0)
                  ? Colors.white
                  : Color.fromRGBO(137, 143, 170, 1),
            ),
          ),
          1: Text(LabelStr.lblPrivate,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: (pageSelectOption.value == 1)
                    ? Colors.white
                    : Color.fromRGBO(137, 143, 170, 1),
              )),
        },
        onValueChanged: (selectedValue) {
          if(selectedValue != pageSelectOption.value) {
            pageSelectOption.value = selectedValue as int;
            _editPostPrivacy();
          }
        },
      ),
    );
  }
}
