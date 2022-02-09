import 'package:flutter/material.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';

class InviteFriends extends StatefulWidget {

  @override
  _InviteFriendsState createState() => _InviteFriendsState();
}

class _InviteFriendsState extends State<InviteFriends> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:Center(
        child: Text(LabelStr.lblInProgressInviteFriend,
        style: TextStyle(
          fontFamily: MyFont.Poppins_semibold,
          fontSize: 26,
          color: Colors.white
        ),),
      )
    );
  }
}
