import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'ColorExtension.dart';

class AppTheme {
  static TextStyle headerTextStyle() {
    return TextStyle(
        fontFamily: MyFont.Poppins_medium, fontSize: 18, color: Colors.black);
  }

  static TextStyle textFieldHintTextStyle() {
    return TextStyle(
        fontFamily: MyFont.Poppins_medium,
        fontSize: 14,
        color: MyColor.hintTextColor());
  }

  static TextStyle regularSFTextStyle() {
    return TextStyle(
      fontFamily: MyFont.Poppins_medium,
      fontSize: 12,
      color: MyColor.normalTextColor(),
    );
  }

  static TextStyle mediumSFTextStyle() {
    return TextStyle(
        fontFamily: MyFont.Poppins_medium,
        fontSize: 12,
        color: MyColor.normalTextColor());
  }

  static TextStyle semiBoldSFTextStyle() {
    return TextStyle(
        fontFamily: MyFont.Poppins_semibold,
        fontSize: 12,
        color: MyColor.normalTextColor());
  }

  static TextStyle boldSFTextStyle() {
    return TextStyle(
        fontFamily: MyFont.Poppins_semibold,
        fontSize: 14,
        color: MyColor.normalTextColor());
  }

  static TextStyle sfProLightTextStyle() {
    return TextStyle(
        fontFamily: MyFont.poppins_regular, fontSize: 14, color: Colors.black);
  }
}

class MyFont {
  static const Poppins_medium = "Poppins Medium";
  static const Poppins_semibold = "Poppins SemiBold";
  static const poppins_regular = "Poppins Regular";
  static const SFPro_bold = "SFPro_bold";
  static const SFPro_light = "SFPro_light";
}

class MyImage {
  static const splashBgImage = "assets/bg_image/splash_bg.png";
  static const profileImage = "assets/bg_image/ic_profile.png";
  static const ic_favprofile = "assets/bg_image/ic_favprofile.png";
  static const ic_splashicon = "assets/bg_image/ic_splashicon.png";
  static const ic_notificationIcon = "assets/icons/ic_notificationIcon.svg";
  static const ic_rightarrow = "assets/icons/ic_rightarrow.svg";
  static const ic_email = "assets/icons/ic_emailid.svg";
  static const ic_line = "assets/icons/ic_line.svg";
  static const ic_map_pin = "assets/icons/ic_map_pin.svg";
  static const ic_floaticon = "assets/icons/ic_floaticon.svg";
  static const ic_chaticon = "assets/icons/ic_chaticon.svg";
  static const ic_bgimage = "assets/icons/ic_bgimage.svg";
  static const ic_totemText = "assets/icons/ic_totem_text.svg";
  static const ic_navsearch = "assets/icons/ic_navsearch.svg";
  static const ic_navcreate = "assets/icons/ic_navcreate.svg";
  static const ic_arrow = "assets/icons/ic_arrow.svg";
  static const ic_person = "assets/icons/ic_person.svg";
  static const ic_ovalprofile = "assets/icons/ic_ovalprofile.png";
  static const ic_ovalprofile1 = "assets/icons/ic_ovalprofile1.png";
  static const ic_navicon = "assets/icons/ic_navicon.svg";
  static const ic_search = "assets/icons/ic_search.svg";
  static const ic_share_outline = "assets/icons/ic_share_outline.svg";
  static const ic_like = "assets/images/ic_like.png";
  static const ic_heart_filled = "assets/icons/ic_heart_filled.svg";
  static const ic_heart_outline = "assets/icons/ic_heart_outline.svg";
  static const ic_comment_outline = "assets/icons/ic_comment_outline.svg";
  static const ic_profile_person = "assets/icons/ic_profile_person.svg";
  static const ic_delete = "assets/icons/ic_delete.svg";
  static const ic_addedit = "assets/icons/ic_addedit.svg";
  static const ic_dash = "assets/icons/ic_dash.svg";
  static const ic_phone = "assets/icons/ic_phone.svg";
  static const ic_navhome = "assets/icons/ic_navhome.svg";
  static const ic_tick = "assets/icons/ic_tick_icon.svg";
  static const ic_tick_outline = "assets/icons/ic_tick_outline.svg";
  static const ic_star_outline = "assets/icons/ic_star_outline.svg";
  static const ic_event_name_flag = "assets/icons/ic_event_name_flag.svg";
  static const ic_photo_filter = "assets/icons/ic_photo_filter_icon.svg";
  static const ic_crop_icon = "assets/icons/ic_crop_icon.svg";
  static const ic_filter_tab_icon = "assets/icons/ic_filter_tab_icon.svg";
  static const ic_popup_menu_indicator = "assets/icons/ic_popup_menu_indicator.svg";
  static const ic_popup_lock = "assets/icons/ic_popup_lock.svg";
  static const ic_edit = "assets/icons/ic_edit.svg";

  // static const ic_clock_icon = "assets/icons/ic_clock_icon.svg";
  static const ic_lock = "assets/icons/ic_lock.svg";
  static const ic_openlock = "assets/icons/ic_lockicon.svg";
  static const ic_share = "assets/icons/ic_share.svg";
  static const ic_goin_indicator = "assets/icons/ic_goin_indicator.svg";
  static const ic_star_filled = "assets/icons/ic_star_filled.svg";
  static const ic_tick_unfilled = "assets/icons/ic_tick_unfilled.svg";
  static const ic_toggleLefticon = "assets/icons/ic_toggleLefticon.svg";
  static const ic_logouticon = "assets/icons/ic_logouticon.svg";
  static const ic_cross = "assets/icons/ic_cross.svg";
  static const ic_calendar = "assets/icons/ic_calendar.svg";
  static const ic_messageicon = "assets/icons/ic_messageicon.svg";
  static const ic_settings = "assets/icons/ic_settings.svg";
  static const ic_spotify = "assets/icons/ic_spotify.svg";
  static const ic_smartphoneicon = "assets/icons/ic_smartphoneicon.svg";
  static const ic_usericon = "assets/icons/ic_usericon.svg";
  static const ic_plus = "assets/icons/ic_plus.svg";
  static const ic_plussquare = "assets/icons/ic_plussquare.svg";
  static const ic_done = "assets/icons/ic_done.svg";
  static const ic_music = "assets/icons/ic_music.svg";
  static const ic_camera = "assets/icons/ic_camera.svg";
  static const ic_right = "assets/icons/ic_right.svg";
  static const ic_city = "assets/icons/ic_city.svg";
  static const ic_bio = "assets/icons/ic_bio.svg";
  static const ic_google = "assets/images/google.jpg";
  static const ic_fb = "assets/images/facebook.svg";
  static const ic_gift = "assets/images/gift.svg";
  static const ic_app_logo = "assets/images/app_logo.jpg";
  static const ic_data_not_found = "assets/icons/ic_data_not_found.svg";
  static const ic_dummy_profile = "assets/bg_image/profile-pic-dummy.png";
  static const ic_artist_lineup = "assets/bg_image/artist_lineup.png";
  static const ic_roadmap = "assets/bg_image/roadmap.png";
  static const ic_event_cover_photo = "assets/bg_image/event_cover_photo.png";
  static const ic_preview = "assets/bg_image/preview.png";
  static const ic_group = "assets/icons/ic_group.svg";

  static const ic_camera_chat = "assets/icons/ic_camera_chat.svg";
  static const ic_attachment = "assets/icons/ic_attachment.svg";
  static const ic_sender = "assets/icons/ic_sender.png";
  static const ic_receiver = "assets/icons/ic_receiver.png";
  static const ic_send = "assets/icons/ic_send.svg";
  static const ic_play = "assets/icons/ic_play.png";
  static const ic_clock = "assets/icons/ic_clock.png";

  static const ic_follower = 'assets/icons/ic_follow.svg';
  static const ic_unfollower = 'assets/icons/ic_unfollow.svg';
  static const ic_menu_icon = 'assets/icons/ic_menu_icon.svg';
  static const ic_report = 'assets/icons/ic_report.svg';
  static const ic_drawer_icon = 'assets/icons/ic_drawer_icon.svg';
  static const ic_verified = 'assets/icons/ic_verified.svg';
  static const ic_card = 'assets/icons/card.svg';
}

class MyColor {
  static Color hintTextColor() {
    return Color.fromRGBO(128, 134, 163, 1);
  }

  static Color normalTextColor() {
    return HexColor("#FFFFFF");
  }

//#636B8E
  static Color textFieldBorderColor() {
    return HexColor("#3C456C");
  }

  static Color backgroundColor() {
    return HexColor("#636B8E");
  }
}

class ValidationResult {
  var message = "";
  var isValid = false;

  ValidationResult(this.isValid, this.message);
}

class SignInType {
  static const CNormal = 0;
  static const CGoogle = 1;
  static const CFacebook = 2;
  static const CApple = 3;
}

class ChatType {
  static const COTO = 0;
  static const CGroup = 1;
}

class MessageType {
  static const CText = 0;
  static const CImage = 1;
  static const CVideo = 2;
}

class DeleteType {
  static const CDeleteForMe = 0;
  static const CDeleteForEveryOne = 1;
}

class NotificationType {
  static const CChat = 0;
  static const CFollow = 1;
  static const CEvent = 2;
}

class ShareType{
  static const CShareUser = "SHARE_USER";
  static const CReferUser = "REFER_USER";
  static const CSharePost = "SHARE_POST";
}

class UserPrefernces {
  static const UserInfo = 'UserInfo';
}

double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

class VaildPassword {
  static bool isValidPassword(String password) {
    bool result = RegExp(r"(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$").hasMatch(
        password);
    return result;
  }
}

const CLimit = 20;
const AppStoreURL = "https://totemapporg.page.link/r394";
const PlayStoreURL = "https://totemapporg.page.link/r394";
const ApiKey = "6LeCwZYUAAAAAJo8IVvGX9dH65Rw89vxaxErCeou";
const ApiSecret = "6LeCwZYUAAAAAKGahIjwfOARevvRETgvwhPMKCs_";
const AndroidAdId = "ca-app-pub-1756644613862683/6318821177";
const iOSAdId = "ca-app-pub-6510884247700598/5926401170";
