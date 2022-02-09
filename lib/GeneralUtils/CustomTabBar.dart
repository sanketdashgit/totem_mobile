import 'package:flutter/material.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

import 'ColorExtension.dart';


class CustomTabBar extends StatelessWidget {
  final int index;

  const CustomTabBar({Key key, this.index}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(left: 20.0, right: 20.0,top: 10.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
          //borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 2,
            color: HexColor.borderColor,
          )
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CustomTabBarButton(
              text: LabelStr.lblPosts,
              textColor:   Colors.white,
              borderColor:  HexColor.textColor,
            ),
          ),
          Expanded(
            child: CustomTabBarButton(
              text: LabelStr.lblMemories,
              textColor:   HexColor.textColor,
              borderColor:  HexColor.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTabBarButton extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color textColor;
  final double borderWidth;

  const CustomTabBarButton({
    Key key,
    this.text,
    this.borderColor,
    this.textColor,
    this.borderWidth=3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
          shape: BoxShape.rectangle,
        color: buttonPrimary

      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontFamily: MyFont.Poppins_semibold,
          color: textColor,
        ),
      ),
    );
  }
}