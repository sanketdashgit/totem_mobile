import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/FlickMultiManager.dart';
import 'package:totem_app/GeneralUtils/FlickMultiPlayer.dart';
import 'package:totem_app/Ui/Customs/FullImageViewScreen.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class CustomSlider extends StatefulWidget {
  List<Map<String,String>> pageItemList = [];
  String widgetRestoreId;
  CustomSlider(this.pageItemList,this.widgetRestoreId);
  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {

  var currentPage = 0.0;
  PageController controller;
  var cardAspectRatio = 12.0 / 9.0;

  @override
  void initState() {
    super.initState();
    _setController();
  }

  void _setController(){
    currentPage = widget.pageItemList.length.toDouble()-1;
    controller = PageController(initialPage: widget.pageItemList.length-1);
    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return widget.pageItemList.length == 0 ? ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: AspectRatio(
        aspectRatio: cardAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image(
              image: CachedNetworkImageProvider(
                  widget.pageItemList[0]['image']),
              fit: BoxFit.cover,
            )
          ],
        ),
      ),
    ): Stack(
      children: <Widget>[
        cardItem(currentPage,widget.pageItemList),
        Positioned.fill(
          child: PageView.builder(
            itemCount: widget.pageItemList.length,
            controller: controller,
            reverse: true,
            restorationId: widget.widgetRestoreId,
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: (){
                    if(widget.pageItemList[index]['video'].isNotEmpty){
                      rq.flickMultiManager.toggleMute();
                    }else{
                      Get.to(HeroPhotoViewRouteWrapper(imageProvider: CachedNetworkImageProvider(widget.pageItemList[index]['image']),));
                    }
                  },
                  child: Container()
              );
            },
          ),
        )
      ],
    );
  }
  var padding = 5.0;
  var verticalInset = 10.0;
  var widgetAspectRatio = (12.0 / 9.0) * 1.1;
  Widget cardItem(currentPage,pageItemList){
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width - 3 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft ;

        List<Widget> cardList = new List();

        for (var i = 0; i < pageItemList.length; i++) {
          var delta = i - currentPage;
          bool isOnRight = delta > 0;
          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 15 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: Container(
              padding: EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: screenBgLightColor
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  child: AspectRatio(
                    aspectRatio: cardAspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        // Image.asset(pageItemList[i], fit: BoxFit.cover),
                        pageItemList[i]['video'].isEmpty ? Image(
                          image: CachedNetworkImageProvider(
                              pageItemList[i]['image']),
                          fit: BoxFit.cover,
                        ) : FlickMultiPlayer(
                          url: pageItemList[i]['video'],
                          flickMultiManager: rq.flickMultiManager,
                          image: pageItemList[i]['image'],
                        ),
                        pageItemList[i]['video'].isEmpty ? SizedBox() : Align(
                          alignment: Alignment.center,

                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );
  }
}

class CardScrollWidget extends StatelessWidget {
  var currentPage;
  var padding = 5.0;
  var verticalInset = 10.0;
  var cardAspectRatio = 12.0 / 9.0;
  var widgetAspectRatio = (12.0 / 9.0) * 1.1;
  List<Map<String,String>> pageItemList = [];
  FlickMultiManager flickMultiManager;

  CardScrollWidget(this.currentPage,this.pageItemList,this.flickMultiManager);



  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: widgetAspectRatio,
      child: LayoutBuilder(builder: (context, contraints) {
        var width = contraints.maxWidth;
        var height = contraints.maxHeight;

        var safeWidth = width - 3 * padding;
        var safeHeight = height - 2 * padding;

        var heightOfPrimaryCard = safeHeight;
        var widthOfPrimaryCard = heightOfPrimaryCard * cardAspectRatio;

        var primaryCardLeft = safeWidth - widthOfPrimaryCard;
        var horizontalInset = primaryCardLeft ;

        List<Widget> cardList = new List();

        for (var i = 0; i < this.pageItemList.length; i++) {
          var delta = i - currentPage;
          bool isOnRight = delta > 0;
          var start = padding +
              max(
                  primaryCardLeft -
                      horizontalInset * -delta * (isOnRight ? 15 : 1),
                  0.0);

          var cardItem = Positioned.directional(
            top: padding + verticalInset * max(-delta, 0.0),
            bottom: padding + verticalInset * max(-delta, 0.0),
            start: start,
            textDirection: TextDirection.rtl,
            child: Container(
              padding: EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: screenBgLightColor
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  child: AspectRatio(
                    aspectRatio: cardAspectRatio,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        pageItemList[i]['video'].isEmpty ? Image(
                          image: CachedNetworkImageProvider(
                              pageItemList[i]['image']),
                          fit: BoxFit.cover,
                        ) : FlickMultiPlayer(
                          url: pageItemList[i]['video'],
                          flickMultiManager: flickMultiManager,
                          image: pageItemList[i]['image'],
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          cardList.add(cardItem);
        }
        return Stack(
          children: cardList,
        );
      }),
    );
  }


}
