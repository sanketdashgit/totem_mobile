import 'package:flutter/material.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

// ignore: must_be_immutable
class ButtonRegular extends StatelessWidget {
  ButtonRegular({
    @required this.buttonText,
    this.onPressed,
    this.padding,
    this.borderRadius = 4.0,
    this.widget,
    this.fontSize,
    this.leadIconSize,
  });

  final String buttonText;
  final Function onPressed;
  final double borderRadius;
  bool isDisabled;
  EdgeInsetsGeometry padding;
  Widget widget;
  final double fontSize;
  final double leadIconSize;

  @override
  Widget build(BuildContext context) {
    if (widget == null)
      widget = Center(
        child: Container(
          height: 17,
          width: 17,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.0,
          ),
        ),
      );
    return Material(
        borderRadius: BorderRadius.all(
          Radius.circular(this.borderRadius == null
              ? dimen.paddingVerySmall
              : this.borderRadius),
        ),
        color: buttonPrimary,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(
              this.borderRadius == null
                  ? dimen.paddingVerySmall
                  : this.borderRadius)),
          child: Container(
            height: dimen.buttonHeight,
            child: Center(
              child: buttonText == null
                  ? widget
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: TextStyle(
                              fontSize: 16,
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
