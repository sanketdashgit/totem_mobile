import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:totem_app/Utility/Impl/global.dart';

import 'SimpleSlider.dart';

class SpotifyPreviewPlayer extends StatefulWidget {
  SpotifyPreviewPlayer(this.index);
  int index = 0;

  @override
  _SpotifyPreviewPlayerState createState() => _SpotifyPreviewPlayerState();
}

class _SpotifyPreviewPlayerState extends State<SpotifyPreviewPlayer> {

  int currentPage = 0;
  PageController _controller;
  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;
  int reqWidth = 0;
  int reqHeight = 0;

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw '${LabelStr.lblCouldNotLaunch} $_url';

  @override
  void initState() {
    super.initState();
    reqWidth = Platform.isAndroid ? 300 : (window.physicalSize.width*0.83).toInt();
    reqHeight = Platform.isAndroid ? 180 : (window.physicalSize.height*0.30).toInt();
    _controller = PageController(initialPage: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: Container(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 240,
                  width: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    itemCount: rq.selectedTracks.length,
                    controller: _controller,
                    itemBuilder: (context,index){
                      return Container(
                          height: 240,
                          width: MediaQuery.of(context).size.width,
                          child: WebView(
                            initialUrl: Uri.dataFromString('<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head><body style="margin:0;padding:0;"><p><iframe src="https://open.spotify.com/embed/album/${rq.selectedTracks[index].albumId}" width="${MediaQuery.of(context).size.width}" height="240" frameborder="0" allowtransparency="true" allow="encrypted-media" ></iframe></p></body></html>', mimeType: 'text/html').toString(),
                            javascriptMode: JavascriptMode.unrestricted,
                          ));
                    },
                  ),
                ),
                rq.selectedTracks.length > 1 ? Container(
                  padding: const EdgeInsets.all(dimen.paddingSmall),
                  child: new Center(
                    child:  DotsIndicator(
                      controller: _controller,
                      itemCount: 3,
                      onPageSelected: (int page) {
                        _controller.animateToPage(
                          page,
                          duration: _kDuration,
                          curve: _kCurve,
                        );
                      },
                    ),
                  ),
                ) : Container(),
                SizedBox(height: dimen.paddingSmall,),
                Text(
                  LabelStr.lblToListenFullTrack,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: MyFont.poppins_regular
                  ),
                  textScaleFactor: 1,
                ),
                InkWell(
                  onTap: (){
                    _launchURL(rq.selectedTracks[_controller.page.toInt()].songlink);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: dimen.paddingLarge,vertical: dimen.paddingSmall),
                    child: Text(
                      LabelStr.lblOpenSpotify,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: MyFont.Poppins_semibold,
                          letterSpacing: 1.5
                      ),
                      textScaleFactor: 0.8,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.green
                    ),
                  ),
                ),
                SizedBox(height: dimen.paddingSmall,),
                InkWell(
                  onTap: (){
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: dimen.paddingLarge,vertical: dimen.paddingSmall),
                    child: Text(
                      LabelStr.lblClose,
                      style: TextStyle(
                          color: textColorBlack,
                          fontFamily: MyFont.Poppins_semibold,
                          letterSpacing: 1.5
                      ),
                      textScaleFactor: 0.8,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: textColorGreyLight
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
