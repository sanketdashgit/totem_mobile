import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/Utils.dart';
import 'package:totem_app/Models/EventUserModel.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Profile/OtherUserProfile.dart';
import 'package:totem_app/Utility/Impl/Global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class Widgets {
  static showLoading() {
    return EasyLoading.show(
        indicator: CircularProgressIndicator(),
        status: 'Loading ...',
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black);
  }

  static loadingDismiss() {
    return EasyLoading.dismiss();
  }

  static dataNotFound({title}) {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            MyImage.ic_data_not_found,
            color: buttonPrimary,
            height: 50,
            width: 50,
          ),
          Text(
            title != null ? title : LabelStr.lblDataNotfound,
            style: TextStyle(
                fontSize: 14,
                fontFamily: MyFont.Poppins_medium,
                color: buttonPrimary),
          )
        ],
      ),
    );
  }

  static usersBottomSheet({List<EventUserModel> list}) {
    return Get.bottomSheet(
        Container(
          constraints: BoxConstraints(maxHeight: Get.height / 1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(38),
              topRight: Radius.circular(38),
            ),
            color: Color.fromRGBO(31, 28, 50, 1),
          ),
          padding: EdgeInsets.only(
            left: dimen.paddingLarge,
            right: dimen.paddingLarge,
            bottom: dimen.paddingLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: dimen.paddingLarge, bottom: dimen.paddingLarge),
                  child: Container(
                    height: 3,
                    width: 100,
                    color: textColorGreyLight,
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: _userList(list),
              )
            ],
          ),
        ),
        isScrollControlled: true);
  }

  static _userList(List<EventUserModel> list) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {},
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  print("user id : " + list[index].id.toString());
                  Utils.presentScreen(
                      context,
                      OtherUserProfile(
                          list[index].id,
                          list[index].username,
                          list[index].username,
                          list[index].profileVerified,
                          list[index].image));
                  print("user id  again: " + list[index].id.toString());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: CommonNetworkImage(
                        height: 40,
                        width: 40,
                        radius: 20,
                        imageUrl: list[index].image,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            userNameWithIndicator(OpenProfileNeedDataModel(
                                list[index].id,
                                list[index].firstname +
                                    " " +
                                    list[index].lastname,
                                list[index].username,
                                list[index].profileVerified,
                                list[index].image)),
                          ],
                        ),
                      ),
                    ),
                    list[index].selfLiked > 0
                        ? selectedIcon(
                            Widgets.getLikeUrl(list[index].selfLiked),
                            Widgets.getLikeStatus(list[index].selfLiked))
                        : Container()
                  ],
                ),
              ),
              index == list.length - 1
                  ? Container()
                  : Divider(
                      color: HexColor("#3C456C"),
                    )
            ],
          ),
        );
      },
    );
  }

  static Widget buildReactionsPreviewIcon(String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Image.asset(path, height: 40),
    );
  }

  static Widget selectedIcon(String path, String type) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            path.contains("unlike")
                ? Image.asset(
                    path,
                    height: 18,
                    width: 18,
                    color: Colors.white,
                  )
                : Image.asset(
                    path,
                    height: 18,
                    width: 18,
                  ),
            Padding(padding: EdgeInsets.only(left: dimen.paddingVerySmall)),
            Text(type,
                style: TextStyle(
                    fontSize: dimen.textSmall,
                    fontFamily: MyFont.Poppins_medium,
                    color: whiteTextColor))
          ],
        ),
      );

  static Future<void> openMap(String latitude, String longitude) async {
    try {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    } catch (e) {}
  }

  static String getLikeUrl(int status) {
    if (status == 0) {
      return "assets/images/ic_unlike.png";
    }
    if (status == 1) {
      return "assets/images/ic_like.png";
    }
    if (status == 2) {
      return "assets/images/flame.png";
    }
    if (status == 3) {
      return "assets/images/mind-blown.png";
    }
    if (status == 4) {
      return "assets/images/heart-eyes.png";
    }
  }

  static String getLikeStatus(int status) {
    if (status == 1 || status == 0) {
      return "Like";
    }
    if (status == 2) {
      return "Fire";
    }
    if (status == 3) {
      return "Mind Blown";
    }
    if (status == 4) {
      return "Love";
    }
  }

//  widget for user name with verified or unverified indicator

  static Widget userNameWithIndicator(OpenProfileNeedDataModel model,
          {textSize, fontFamily, color, overflow}) =>
      Container(
        child: InkWell(
          onTap: () {
            Get.to(OtherUserProfile(model.id, model.name, model.username,
                model.profileVerified, model.image));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(model.username,
                  maxLines: 1,
                  overflow: overflow == null ? TextOverflow.ellipsis : overflow,
                  style: TextStyle(
                      fontSize: textSize == null ? dimen.textSmall : textSize,
                      fontFamily: fontFamily == null
                          ? MyFont.Poppins_medium
                          : fontFamily,
                      color: color == null ? whiteTextColor : color)),
              model.profileVerified
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
        ),
      );
}
