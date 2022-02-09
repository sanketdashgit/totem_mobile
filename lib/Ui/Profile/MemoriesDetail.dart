import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/MemoriesModel.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Ui/Customs/FullImageViewScreen.dart';
import 'package:totem_app/Ui/Customs/VideoPlayerScreen.dart';
import 'package:totem_app/Ui/Post/AddNewPost.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class MemoriesDetail extends StatefulWidget {
  MemoriesModel item;

  MemoriesDetail(this.item);

  @override
  _MemoriesDetailState createState() => _MemoriesDetailState();
}

class _MemoriesDetailState extends State<MemoriesDetail> {
  var restorationId = ''.obs;
  final List<String> _sizeSample = ["1,1", "2,1", "1,2", "1,2", "1,1", "1,1"];
  List<String> _sizes = [];

  @override
  void initState() {
    super.initState();
    generateSizeArray();
    if (widget.item.id != SessionImpl.getId() as int) {
      var temp = widget.item.memorieMediaLinks
          .where((element) => element.isPrivate == false)
          .toList();
      widget.item.memorieMediaLinks = temp;
    }
    restorationId.value = Utilities.getRandomString();
  }

  int length = 0;

  void generateSizeArray() {
    length = widget.item.memorieMediaLinks.length;
    if (widget.item.id == SessionImpl.getId() as int) {
      length++;
    }
    int counter = (length / 6).ceil();
    _sizes.clear();
    for (var i = 0; i < counter; i++) {
      _sizes.addAll(_sizeSample);
    }
  }

  _deleteMedia(int index) {
    RequestManager.postRequest(
        uri: endPoints.DeleteMemoriesFiles,
        body: {
          Parameters.Cid: widget.item.memorieMediaLinks[index - 1].memorieFileId
        },
        isLoader: true,
        isSuccessMessage: false,
        onSuccess: (response) {
          widget.item.memorieMediaLinks.removeAt(index - 1);
          generateSizeArray();
          restorationId.value = Utilities.getRandomString();
        },
        onFailure: () {});
  }

  _editMediaPrivacy(int index) {
    var body = {
      Parameters.CMemoriesFileId:
          widget.item.memorieMediaLinks[index].memorieFileId,
      Parameters.CisPrivate: widget.item.memorieMediaLinks[index].isPrivate
    };
    RequestManager.postRequest(
        uri: endPoints.editMemoryFilePrivacy,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        onSuccess: (response) {
          restorationId.value = Utilities.getRandomString();
        },
        onFailure: () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      appBar: AppBar(
        centerTitle: true,
        brightness: Brightness.dark,
        backgroundColor: screenBgColor,
        leading: Padding(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Get.back();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
        title: Text(
          widget.item.eventName,
          style: TextStyle(
              color: Colors.white,
              fontFamily: MyFont.Poppins_semibold,
              fontSize: 16),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.item.caption,
              style: TextStyle(
                  fontSize: 14, color: whiteTextColor.withOpacity(0.8)),
            ),
          ),
          Expanded(
              child: widget.item.id == (SessionImpl.getId() as int)
                  ? _gridView()
                  : _gridViewOther()),
        ],
      ),
    );
  }

  _updateList(List<MemorieMediaLink> value) {
    if (value != null) {
      value.forEach((element) {
        try {
          var find = widget.item.memorieMediaLinks
              .where((e) => e.memorieFileId == element.memorieFileId)
              .first;
          if (find != null) {
            element.isPrivate = find.isPrivate;
          }
        } catch (e) {}
      });
      widget.item.memorieMediaLinks.clear();
      widget.item.memorieMediaLinks.addAll(value);
      restorationId.value = Utilities.getRandomString();
    }
  }

  bool checkItemExist(MemorieMediaLink item) {
    var isExist = false;
    widget.item.memorieMediaLinks.map((e) => {
          if (e.memorieFileId == item.memorieFileId) {isExist = true}
        });
    return isExist;
  }

  Widget _gridView() {
    return Obx(() => StaggeredGridView.countBuilder(
          padding: EdgeInsets.only(bottom: dimen.paddingNavigationBar),
          crossAxisCount: 3,
          itemCount: widget.item.memorieMediaLinks.length + 1,
          restorationId: restorationId.value,
          itemBuilder: (BuildContext context, int index) => index == 0 &&
                  widget.item.id == (SessionImpl.getId() as int)
              ? InkWell(
                  onTap: () {
                    Get.to(AddNewPost(
                      LabelStr.lblAddMediaInMemory,
                      memoryId: widget.item.memorieId,
                      caption: widget.item.caption,
                      eventId: widget.item.eventId,
                    )).then((value) {
                      _updateList(value);
                    });
                  },
                  child: Container(
                    color: iconPrimerColor,
                    child: Center(
                        child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: dimen.iconButtonSize,
                    )),
                  ),
                )
              : Container(
                  child: Stack(
                  children: [
                    Container(
                        height: double.infinity,
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            if (widget.item.memorieMediaLinks[index - 1]
                                .videolink.isNotEmpty) {
                              _pressedOnVideoPlayBtn(
                                  context,
                                  widget.item.memorieMediaLinks[index - 1]
                                      .videolink,
                                  widget.item.memorieMediaLinks[index - 1]
                                      .downloadlink,
                                  new OpenProfileNeedDataModel(
                                      widget.item.id,
                                      widget.item.firstname +
                                          ' ' +
                                          widget.item.lastname,
                                      widget.item.username,
                                      false,
                                      widget.item.image));
                            } else {
                              Get.to(HeroPhotoViewRouteWrapper(
                                imageProvider: CachedNetworkImageProvider(
                                  widget.item.memorieMediaLinks.length != 0
                                      ? widget.item.memorieMediaLinks[index - 1]
                                          .downloadlink
                                      : '',
                                ),
                                model: new OpenProfileNeedDataModel(
                                    widget.item.id,
                                    widget.item.firstname +
                                        ' ' +
                                        widget.item.lastname,
                                    widget.item.username,
                                    false,
                                    widget.item.image),
                              ));
                            }
                          },
                          child: CachedNetworkImage(
                              imageUrl: widget.item.memorieMediaLinks[index - 1]
                                  .downloadlink,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      Image.asset("assets/bg_image/preview.png",
                                          fit: BoxFit.cover),
                              errorWidget: (context, url, error) => Image.asset(
                                  "assets/bg_image/preview.png",
                                  fit: BoxFit.cover)),
                        )),
                    widget.item.memorieMediaLinks[index - 1].videolink == ''
                        ? SizedBox()
                        : Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.all(dimen.paddingLarge),
                              child: InkWell(
                                onTap: (() async {
                                  if (widget.item.memorieMediaLinks[index - 1]
                                      .videolink.isNotEmpty)
                                    _pressedOnVideoPlayBtn(
                                        context,
                                        widget.item.memorieMediaLinks[index - 1]
                                            .videolink,
                                        widget.item.memorieMediaLinks[index - 1]
                                            .downloadlink,
                                        new OpenProfileNeedDataModel(
                                            widget.item.id,
                                            widget.item.firstname +
                                                ' ' +
                                                widget.item.lastname,
                                            widget.item.username,
                                            false,
                                            widget.item.image));
                                }),
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
                            ),
                          ),
                    widget.item.id == SessionImpl.getId() as int
                        ? Positioned(
                            top: dimen.marginVerySmall,
                            right: dimen.marginVerySmall,
                            child: InkWell(
                                onTap: () {
                                  _deleteMedia(index);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        // 10% of the width, so there are ten blinds.
                                        colors: <Color>[
                                          Colors.black38,
                                          Color(0x1F000000)
                                        ], // red to yellow
                                      )),
                                      padding: const EdgeInsets.all(
                                          dimen.paddingSmall * .50),
                                      child: Icon(
                                        Icons.delete_sweep,
                                        color: whiteTextColor,
                                        size: 20,
                                      )),
                                )),
                          )
                        : SizedBox(),
                    widget.item.id == SessionImpl.getId() as int
                        ? Positioned(
                            top: dimen.marginExtraHues,
                            right: dimen.marginVerySmall,
                            child: InkWell(
                                onTap: () {
                                  widget.item.memorieMediaLinks[index - 1]
                                      .isPrivate = widget
                                          .item
                                          .memorieMediaLinks[index - 1]
                                          .isPrivate
                                      ? false
                                      : true;
                                  restorationId.value =
                                      Utilities.getRandomString();
                                  _editMediaPrivacy(index - 1);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        // 10% of the width, so there are ten blinds.
                                        colors: <Color>[
                                          Colors.black38,
                                          Color(0x1F000000)
                                        ], // red to yellow
                                      )),
                                      padding: const EdgeInsets.all(
                                          dimen.paddingSmall * .50),
                                      child: Icon(
                                        widget.item.memorieMediaLinks[index - 1]
                                                .isPrivate
                                            ? Icons.lock_outline
                                            : Icons.lock_open,
                                        color: Colors.white,
                                        size: 20,
                                      )),
                                )),
                          )
                        : SizedBox()
                  ],
                )),
          staggeredTileBuilder: (int index) => StaggeredTile.count(
              int.parse(_sizes[index].split(",")[0]),
              double.parse(_sizes[index].split(",")[1])),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ));
  }

  Widget _gridViewOther() {
    return Obx(() => StaggeredGridView.countBuilder(
          padding: EdgeInsets.only(bottom: dimen.paddingNavigationBar),
          crossAxisCount: 3,
          itemCount: widget.item.memorieMediaLinks.length,
          restorationId: restorationId.value,
          itemBuilder: (BuildContext context, int index) => Container(
              child: Stack(
            children: [
              Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      if (widget
                          .item.memorieMediaLinks[index].videolink.isNotEmpty) {
                        _pressedOnVideoPlayBtn(
                            context,
                            widget.item.memorieMediaLinks[index].videolink,
                            widget.item.memorieMediaLinks[index].downloadlink,
                            new OpenProfileNeedDataModel(
                                widget.item.id,
                                widget.item.firstname +
                                    ' ' +
                                    widget.item.lastname,
                                widget.item.username,
                                false,
                                widget.item.image));
                      } else {
                        Get.to(HeroPhotoViewRouteWrapper(
                          imageProvider: CachedNetworkImageProvider(
                            widget.item.memorieMediaLinks.length != 0
                                ? widget
                                    .item.memorieMediaLinks[index].downloadlink
                                : '',
                          ),
                          model: new OpenProfileNeedDataModel(
                              widget.item.id,
                              widget.item.firstname +
                                  ' ' +
                                  widget.item.lastname,
                              widget.item.username,
                              false,
                              widget.item.image),
                        ));
                      }
                    },
                    child: CachedNetworkImage(
                        imageUrl:
                            widget.item.memorieMediaLinks[index].downloadlink,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Image.asset(
                                "assets/bg_image/preview.png",
                                fit: BoxFit.cover),
                        errorWidget: (context, url, error) => Image.asset(
                            "assets/bg_image/preview.png",
                            fit: BoxFit.cover)),
                  )),
              widget.item.memorieMediaLinks[index].videolink == ''
                  ? SizedBox()
                  : Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(dimen.paddingLarge),
                        child: InkWell(
                          onTap: (() async {
                            if (widget.item.memorieMediaLinks[index].videolink
                                .isNotEmpty)
                              _pressedOnVideoPlayBtn(
                                  context,
                                  widget
                                      .item.memorieMediaLinks[index].videolink,
                                  widget.item.memorieMediaLinks[index]
                                      .downloadlink,
                                  new OpenProfileNeedDataModel(
                                      widget.item.id,
                                      widget.item.firstname +
                                          ' ' +
                                          widget.item.lastname,
                                      widget.item.username,
                                      false,
                                      widget.item.image));
                          }),
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
                      ),
                    ),
            ],
          )),
          staggeredTileBuilder: (int index) => StaggeredTile.count(
              int.parse(_sizes[index].split(",")[0]),
              double.parse(_sizes[index].split(",")[1])),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ));
  }

  _pressedOnVideoPlayBtn(BuildContext context, String videoURL, String imageUrl,
      OpenProfileNeedDataModel model) {
    Get.to(VideoPlayerScreen(
      videoURL,
      imageUrl: imageUrl,
      model: model,
    ));
  }
}
