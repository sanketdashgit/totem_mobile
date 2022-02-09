import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'FeedPlayerPortraitControls.dart';
import 'FlickMultiManager.dart';

class FlickManagerNew extends StatelessWidget {
   FlickManagerNew({Key key,
     this.url,
     this.image,
     this.flickMultiManager}) : super(key: key);

  final String url;
  final String image;
  final FlickMultiManager flickMultiManager;



  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}
