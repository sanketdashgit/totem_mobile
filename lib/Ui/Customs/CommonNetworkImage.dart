import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Ui/Customs/FullImageViewScreen.dart';

class CommonNetworkImage extends StatefulWidget {
  CommonNetworkImage(
      {this.imageUrl, this.height, this.width, this.radius, this.model});

  final String imageUrl;
  final double height;
  final double width;
  final double radius;
  final OpenProfileNeedDataModel model;

  @override
  _CommonNetworkImageState createState() => _CommonNetworkImageState();
}

class _CommonNetworkImageState extends State<CommonNetworkImage> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(HeroPhotoViewRouteWrapper(
          imageProvider: CachedNetworkImageProvider(widget.imageUrl),
          model: widget.model,
        ));
      },
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(widget.radius == null ? 20.0 : widget.radius),
        child: Container(
          height: widget.height == null ? 40.0 : widget.height,
          width: widget.width == null ? 40.0 : widget.width,
          color: Colors.grey.shade300,
          child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.fill,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Image.asset("assets/bg_image/profile-pic-dummy.png",
                      fit: BoxFit.fill),
              errorWidget: (context, url, error) => Image.asset(
                  "assets/bg_image/profile-pic-dummy.png",
                  fit: BoxFit.fill)),
        ),
      ),
    );
  }
}

class CommonImage extends StatelessWidget {
  CommonImage(this.imageUrl, this.height, this.width);

  final String imageUrl;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(HeroPhotoViewRouteWrapper(
          imageProvider: CachedNetworkImageProvider(imageUrl),
        ));
      },
      child: CachedNetworkImage(
          height: height,
          width: width,
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Image.asset("assets/bg_image/preview.png", fit: BoxFit.fill),
          errorWidget: (context, url, error) =>
              Image.asset("assets/bg_image/preview.png", fit: BoxFit.fill)),
    );
  }
}

class CommonChatImage extends StatelessWidget {
  CommonChatImage(this.imageUrl, this.width);

  final String imageUrl;
  double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(HeroPhotoViewRouteWrapper(
          imageProvider: CachedNetworkImageProvider(imageUrl),
        ));
      },
      child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.fill,
          width: width,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Container(
                  width: width,
                  child: Center(
                      child: SizedBox(
                    width: ScreenUtil().setWidth(20),
                    height: ScreenUtil().setWidth(20),
                    child: CircularProgressIndicator(
                        strokeWidth: 1, color: Colors.white),
                  ))),
          errorWidget: (context, url, error) =>
              Image.asset("assets/bg_image/preview.png", fit: BoxFit.fill)),
    );
  }
}

class CommonChatThumbnail extends StatelessWidget {
  CommonChatThumbnail(this.imageUrl, this.width, this.height);

  final String imageUrl;
  double width;
  double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(HeroPhotoViewRouteWrapper(
          imageProvider: CachedNetworkImageProvider(imageUrl),
        ));
      },
      child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.fill,
          width: width,
          height: height,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Container(
                  width: width,
                  height: height,
                  child: Center(
                      child: SizedBox(
                    width: ScreenUtil().setWidth(20),
                    height: ScreenUtil().setWidth(20),
                    child: CircularProgressIndicator(
                        strokeWidth: 1, color: Colors.white),
                  ))),
          errorWidget: (context, url, error) =>
              Image.asset("assets/bg_image/preview.png", fit: BoxFit.fill)),
    );
  }
}
