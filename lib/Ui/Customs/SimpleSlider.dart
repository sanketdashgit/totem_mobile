import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/FlickMultiPlayer.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Ui/Home/PostMediaSlider.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';


class SimpleSlider extends StatefulWidget {
  List<Map<String, String>> pageItemList = [];
  String widgetRestoreId;
  OpenProfileNeedDataModel model;

  SimpleSlider(this.pageItemList, this.widgetRestoreId, this.model);

  @override
  _SimpleSliderState createState() => _SimpleSliderState();
}

class _SimpleSliderState extends State<SimpleSlider> {
  int currentPage = 0;
  PageController _controller;
  var cardAspectRatio = 12.0 / 9.0;
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: cardAspectRatio,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: dimen.paddingSmall),
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.pageItemList.length,
              controller: _controller,
              restorationId: widget.widgetRestoreId,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      if (widget.pageItemList[index]['video'].isNotEmpty) {
                        rq.flickMultiManager.toggleMute();
                      } else {
                        Get.to(PostMediaSlider(
                          widget.pageItemList,widget.widgetRestoreId,widget.model
                        ));
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        child: widget.pageItemList[index]['video']==null || widget.pageItemList[index]['video'].isEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.pageItemList[index]['image'],
                                progressIndicatorBuilder: (context, url,
                                        downloadProgress) =>
                                    Image.asset("assets/bg_image/preview.png",
                                        fit: BoxFit.fill),
                                fit: BoxFit.cover,
                              )
                            : Stack(
                              children: [
                                FlickMultiPlayer(
                                    url: widget.pageItemList[index]['video'],
                                    flickMultiManager: rq.flickMultiManager,
                                    image: widget.pageItemList[index]['image'],
                                  ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 50,bottom: 17),
                                    child: InkWell(
                                      onTap:(){
                                        Get.to(PostMediaSlider(
                                            widget.pageItemList,widget.widgetRestoreId,widget.model
                                        ));
                                      },
                                      child: CircleAvatar(
                                        radius: 13,
                                        backgroundColor: Colors.black38.withOpacity(.5),
                                        child: Icon(
                                          Icons.open_in_full,
                                          color: whiteTextColor,
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ));
              },
            ),
            widget.pageItemList.length > 1
                ? Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: new Container(
                      padding: const EdgeInsets.all(dimen.paddingSmall),
                      child: new Center(
                        child: new DotsIndicator(
                          controller: _controller,
                          itemCount: widget.pageItemList.length,
                          onPageSelected: (int page) {
                            _controller.animateToPage(
                              page,
                              duration: _kDuration,
                              curve: _kCurve,
                            );
                          },
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }


}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 1.5;

  // The distance between the center of each dot
  static const double _kDotSpacing = 16;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return new Container(
      width: _kDotSpacing,
      child: new Center(
        child: new Material(
          color: color,
          type: MaterialType.circle,
          child: new Container(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }

}
