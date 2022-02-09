
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Ui/Profile/OtherUserProfile.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';

import 'CommonNetworkImage.dart';

class FullImageViewScreen extends StatefulWidget {
  FullImageViewScreen(this.imageUrl, {this.pageTitle, this.level});

  String imageUrl;
  String pageTitle = "";
  String level = "";

  @override
  _FullImageViewScreenState createState() => _FullImageViewScreenState();
}

class _FullImageViewScreenState extends State<FullImageViewScreen> {
  bool isPortrait = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        isPortrait = orientation == Orientation.portrait;
        return Scaffold(
            backgroundColor: screenBgColor,
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(49),
                      left: ScreenUtil().setWidth(30),
                      right: ScreenUtil().setWidth(30)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: SvgPicture.asset(
                            MyImage.ic_arrow,
                            color: tabActiveColor,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          widget.level != null ? widget.level : " ",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: MyFont.Poppins_semibold,
                              color: tabActiveColor),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              widget.pageTitle != null ? widget.pageTitle : " ",
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
                  height: dimen.dividerHeightNormal,
                ),
                Expanded(
                  flex: 1,
                  child: Stack(
                    fit: isPortrait ? StackFit.loose : StackFit.expand,
                    children: <Widget>[
                      Align(
                          alignment: Alignment.center,
                          child: PhotoView(
                            imageProvider: NetworkImage(widget.imageUrl),
                            heroAttributes:
                                const PhotoViewHeroAttributes(tag: "someTag"),
                          ))
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }
}

class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper({
    this.imageProvider,
    this.model,
  });

  final ImageProvider imageProvider;
  final OpenProfileNeedDataModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(49),
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.all(dimen.paddingForBackArrow),
                        child: SvgPicture.asset(MyImage.ic_arrow),
                      )),
                ),
                SizedBox(
                  width: dimen.marginSmall,
                ),
                model == null
                    ? Container()
                    : InkWell(
                        onTap: () => openProfile(),
                        child: CommonNetworkImage(
                          imageUrl: model.image,
                          height: 35,
                          width: 35,
                          radius: 18,
                        ),
                      ),
                SizedBox(
                  width: dimen.marginSmall,
                ),
                model == null
                    ? Container()
                    : Widgets.userNameWithIndicator(model, textSize: 16.0),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Stack(
              fit: StackFit.loose,
              children: <Widget>[
                Align(
                    alignment: Alignment.center,
                    child: PhotoView(
                      imageProvider: imageProvider,
                      heroAttributes:
                          const PhotoViewHeroAttributes(tag: "someTag"),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  openProfile() {
    if (model != null)
      Get.to(OtherUserProfile(model.id, model.name, model.username,
          model.profileVerified, model.image));
  }
}
