import 'package:flutter/material.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        LabelStr.lblINProgress,
        style: TextStyle(
            fontFamily: MyFont.Poppins_semibold,
            fontSize: 26,
            color: Colors.white),
      ),
    );
  }
}
