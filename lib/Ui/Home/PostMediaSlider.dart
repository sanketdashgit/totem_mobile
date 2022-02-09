import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:totem_app/GeneralUtils/FlickMultiPlayer.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/SimpleSlider.dart';
import 'package:totem_app/Ui/Profile/OtherUserProfile.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';

class PostMediaSlider extends StatefulWidget {
  List<Map<String, String>> pageItemList = [];
  String widgetRestoreId;
  OpenProfileNeedDataModel model;

  PostMediaSlider(this.pageItemList, this.widgetRestoreId, this.model);

  @override
  _PostMediaSliderState createState() => _PostMediaSliderState();
}

class _PostMediaSliderState extends State<PostMediaSlider>
    with TickerProviderStateMixin {
  int currentPage = 0;

  var cardAspectRatio = 12.0 / 9.0;
  PageController _controller;

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;
  int _currentPage = 0;
  double _currentHeight = Get.size.height * 0.7;
  double _prevHeight = Get.size.height * 0.7;

  @override
  void initState() {
    super.initState();
    changeHeight();
    _controller = PageController(initialPage: currentPage)
      ..addListener(() {
        final _newPage = _controller.page.round();
        if (_currentPage != _newPage) {
          _currentPage = _newPage;
          changeHeight();
        }
      });
  }

  changeHeight() {
    setState(() {
      if (widget.pageItemList[_currentPage][Parameters.CVideo_].isNotEmpty) {
        _prevHeight = _currentHeight;
        _currentHeight = Get.size.height * 0.3;
      } else {
        _prevHeight = _currentHeight;
        _currentHeight = Get.size.height * 0.7;
      }
    });
  }

  openProfile() {
    if (widget.model != null)
      Get.to(OtherUserProfile(
          widget.model.id,
          widget.model.name,
          widget.model.username,
          widget.model.profileVerified,
          widget.model.image));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            margin: EdgeInsets.only(left: dimen.marginMedium),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(Icons.arrow_back_ios, size: 30, color: Colors.white),
            ),
          ),
          widget.model == null
              ? Container()
              : InkWell(
                  onTap: () => openProfile(),
                  child: Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: CommonNetworkImage(
                      imageUrl: widget.model.image,
                    ),
                  ),
                ),
          SizedBox(
            width: dimen.marginSmall,
          ),
          widget.model == null
              ? Container()
              : InkWell(
                  onTap: () => openProfile(),
                  child: Widgets.userNameWithIndicator(widget.model,
                      textSize: 14.0),
                ),
          Expanded(child: Container()),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: dimen.paddingSmall),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: TweenAnimationBuilder(
                curve: Curves.easeInOutCubic,
                duration: const Duration(milliseconds: 200),
                tween: Tween<double>(begin: _prevHeight, end: _currentHeight),
                builder: (context, value, child) => SizedBox(
                  height: value,
                  child: PageView.builder(
                    itemCount: widget.pageItemList.length,
                    controller: _controller,
                    restorationId: widget.widgetRestoreId,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            if (widget
                                .pageItemList[index][Parameters.CVideo_].isNotEmpty) {
                              rq.flickMultiManager.toggleMute();
                            }
                          },
                          child: widget.pageItemList[index][Parameters.CVideo_].isEmpty
                              ? Container(
                                  child: Stack(
                                  fit: StackFit.loose,
                                  children: <Widget>[
                                    Align(
                                        alignment: Alignment.center,
                                        child: PhotoView(
                                          imageProvider:
                                              CachedNetworkImageProvider(
                                            widget.pageItemList[index][Parameters.Cimage],
                                          ),
                                          heroAttributes:
                                              const PhotoViewHeroAttributes(
                                                  tag: LabelStr.lblSomeTag),
                                        ))
                                    // child: Image(image: NetworkImage(widget.imageUrl)))
                                  ],
                                ))
                              : FlickMultiPlayer(
                                  url: widget.pageItemList[index][Parameters.CVideo_],
                                  flickMultiManager: rq.flickMultiManager,
                                  image: widget.pageItemList[index][Parameters.Cimage],
                                ));
                    },
                  ),
                ),
              ),
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
