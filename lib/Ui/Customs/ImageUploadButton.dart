import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

// ignore: must_be_immutable
class ImageUploadButton extends StatelessWidget {
  ImageUploadButton({
    @required this.buttonText,
    this.onPressed,
    this.padding,
    this.borderRadius = 4.0,
    this.fontSize,
    this.leadIconSize,
    this.width,
    this.color
  });

  final String buttonText;
  final Function onPressed;
  final double borderRadius;
  bool isDisabled;
  EdgeInsetsGeometry padding;
  final double fontSize;
  final double leadIconSize;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.all(
          Radius.circular(this.borderRadius == null
              ? dimen.paddingVerySmall
              : this.borderRadius),
        ),
        color: color != null ? color : uploadImgBtnClr,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(
              this.borderRadius == null
                  ? dimen.paddingVerySmall
                  : this.borderRadius)),
          child: Container(
            height: dimen.buttonHeight,
            width: width != null?width:MediaQuery.of(context).size.width * 0.45,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.only(right: dimen.paddingVerySmall,bottom: dimen.paddingVerySmall ),
                      child: SvgPicture.asset(
                        MyImage.ic_camera,
                        color: appColorExtraLight,
                      )),
                  Text(
                    buttonText,
                    style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 0.41,
                        fontFamily: MyFont.Poppins_medium,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          onTap: onPressed,
        ));
  }
}
