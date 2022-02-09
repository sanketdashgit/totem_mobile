import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/VideoPlayerScreen.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:image/image.dart' as imageLib;
import 'package:totem_app/Utility/PhotoFilter/filters/preset_filters.dart';
import 'package:totem_app/Utility/PhotoFilter/widgets/photo_filter.dart';

class AddPostCustomSlider extends StatefulWidget {
  List<Map<String, String>> pageItemList = [];
  final String widgetRestoreId;

  AddPostCustomSlider(this.pageItemList, this.widgetRestoreId);

  @override
  _AddPostCustomSliderState createState() => _AddPostCustomSliderState();
}

class _AddPostCustomSliderState extends State<AddPostCustomSlider> {
  var currentPage = 0.0;
  PageController controller;
  var cardAspectRatio = 12.0 / 9.0;

  @override
  void initState() {
    super.initState();
    _setController();
  }

  void _setController() {
    currentPage = rq.pickedMediaList.length.toDouble() - 1;
    controller = PageController(initialPage: rq.pickedMediaList.length - 1);
    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return rq.pickedMediaList.length == 0
        ? ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: AspectRatio(
              aspectRatio: cardAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(
                    File(rq.pickedMediaList[0].path),
                    fit: BoxFit.cover,
                  )
                ],
              ),
            ),
          )
        : Stack(
            children: <Widget>[
              CardScrollWidget(currentPage),
              Positioned.fill(
                child: PageView.builder(
                  itemCount: rq.pickedMediaList.length,
                  controller: controller,
                  reverse: true,
                  restorationId: rq.imagePageRefrasher.value,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onTap: () {
                        },
                        child: Container(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(dimen.paddingLarge),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: (() async {
                                      var imageFile = new File(
                                          rq.pickedMediaList[index].path);
                                      var fileName = basename(imageFile.path);
                                      var image = imageLib.decodeImage(
                                          await imageFile.readAsBytes());
                                      image = imageLib.copyResize(image,
                                          width: 600);

                                      Get.to(PhotoFilterSelector(
                                        index: index,
                                        image: image,
                                        filters: presetFiltersList,
                                        filename: fileName,
                                        imgPath: rq.pickedMediaList[index].path,
                                        loader: Center(
                                            child:
                                            CircularProgressIndicator()),
                                        fit: BoxFit.contain,
                                      )).then((value) =>
                                      rq.imagePageRefrasher.value =
                                          Utilities.getRandomString());
                                    }),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 15,
                                      child: SvgPicture.asset(
                                        MyImage.ic_photo_filter,
                                        color: Colors.black,
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: dimen.paddingLarge,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (rq.pickedMediaList[index].fileId != 0) {
                                        rq.removedList.add(
                                            rq.pickedMediaList[index].fileId);
                                      }
                                      rq.pickedMediaList.removeAt(index);
                                      rq.imagePageRefrasher.value =
                                          Utilities.getRandomString();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 15,
                                      child: SvgPicture.asset(
                                        MyImage.ic_delete,
                                        color: Colors.red,
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ));
                  },
                ),
              )
            ],
          );
  }


}

class CardScrollWidget extends StatelessWidget {
  var currentPage;
  var padding = 5.0;
  var verticalInset = 10.0;
  var cardAspectRatio = 12.0 / 9.0;
  var widgetAspectRatio = (12.0 / 9.0) * 1.1;
  List<Map<String, String>> pageItemList = [];

  CardScrollWidget(this.currentPage, {this.pageItemList});

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
        var horizontalInset = primaryCardLeft;

        List<Widget> cardList = new List();

        for (var i = 0; i < rq.pickedMediaList.length; i++) {
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(3.0, 6.0),
                      blurRadius: 10.0)
                ]),
                child: AspectRatio(
                  aspectRatio: cardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      rq.pickedMediaList[i].path.contains("http")
                          ? CommonImage(rq.pickedMediaList[i].path,
                              double.infinity, double.infinity)
                          : Image.file(
                              File(rq.pickedMediaList[i].path),
                              fit: BoxFit.cover,
                            ),
                      rq.pickedMediaList[i].type.isEmpty
                          ? SizedBox()
                          : Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(dimen.paddingLarge),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white54,
                                  radius: 20,
                                  child: SvgPicture.asset(
                                    MyImage.ic_music,
                                    color: Colors.black45,
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ),
                            )
                    ],
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
