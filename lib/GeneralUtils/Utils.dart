import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';

class Utils {
  static presentScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen, fullscreenDialog: true),
    );
  }

  static navigateReplaceToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => screen));
  }

  static String convertDate(String date, DateFormat outputFormat) {
    DateTime tempDate = new DateFormat("yyyy-MM-dd'T'hh:mm:ss").parse(date);
    return outputFormat.format(tempDate);
  }

  static Future<dynamic> navigateToScreen(
      BuildContext context, Widget screen) async {
    var value = await Navigator.push(
        context, CupertinoPageRoute(builder: (context) => screen));
    return value;
  }

 static Future<String> createFirstPostLink(int id,String image,String name, String shareType) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://totemapporg.page.link',
      link: Uri.parse('https://totemapp.org/post?id=$id&type=$shareType'),
      androidParameters: AndroidParameters(
        packageName: 'com.totemapp',
        minimumVersion: 1,
      ),
      // NOT ALL ARE REQUIRED ===== HERE AS AN EXAMPLE =====
      iosParameters: IosParameters(
        bundleId: 'com.app.totemapp',
        minimumVersion: '1.0.1',
        appStoreId: '1575753160',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'totem-share',
        medium: 'social',
        source: 'totem',
      ),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'totem-share',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Totem : Concert Sharing',
          description: name,
          imageUrl:Uri.parse(image)
      ),
    );
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl.toString();
  }
}
typedef ResponseCallback(bool success, dynamic response);
