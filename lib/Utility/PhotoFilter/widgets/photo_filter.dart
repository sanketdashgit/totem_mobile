import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_cropper/image_cropper.dart';
// import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/helper.dart';
import 'package:totem_app/Utility/PhotoFilter/filters/filters.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';

class PhotoFilter extends StatelessWidget {
  final imageLib.Image image;
  final String filename;
  final Filter filter;
  final BoxFit fit;
  final Widget loader;

  PhotoFilter({
    this.image,
    this.filename,
    this.filter,
    this.fit = BoxFit.fill,
    this.loader = const Center(child: CircularProgressIndicator()),
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: compute(applyFilter, <String, dynamic>{
        "filter": filter,
        "image": image,
        "filename": filename,
      }),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return loader;
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loader;
          case ConnectionState.done:
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            return Image.memory(
              snapshot.data as dynamic,
              fit: fit,
            );
        }
      },
    );
  }
}

///The PhotoFilterSelector Widget for apply filter from a selected set of filters
class PhotoFilterSelector extends StatefulWidget {
  final Widget title;
  final Color appBarColor;
  final List<Filter> filters;
  final imageLib.Image image;
  final Widget loader;
  final BoxFit fit;
  final String filename;
  final String imgPath;
  final bool circleShape;
  final int index;

  const PhotoFilterSelector({
    Key key,
    this.title,
    this.filters,
    this.image,
    this.appBarColor = Colors.blue,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.fit = BoxFit.cover,
    this.filename,
    this.imgPath,
    this.circleShape = false,
    this.index = 1,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PhotoFilterSelectorState();
}

class _PhotoFilterSelectorState extends State<PhotoFilterSelector> {
  String imgPath;
  String filename;
  Map<String, List<int>> cachedFilters = {};
  Filter _filter;
  imageLib.Image image;
  bool loading;
  String testImg;

  var isCropped = false.obs;

  @override
  void initState() {
    super.initState();
    loading = false;
    _filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
    imgPath = widget.imgPath;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0A0525),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: dimen.paddingBigLarge,right: dimen.paddingBigLarge, top: dimen.paddingExtra),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(MyImage.ic_cross)),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Center(
                    child: Text(
                      LabelStr.lblEditPhoto,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: MyFont.Poppins_semibold,
                          color: Colors.white),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: (() async {
                      var imageFile = await saveFilteredImage();
                      double size = await Helper().getFileSize(imageFile.path);
                      rq.pickedMediaList[widget.index].path = imageFile.path;
                      rq.pickedMediaList[widget.index].size = size;
                      Get.back();
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(dimen.radiusLarge),
                        color: textColorGrey,
                      ),
                      padding: EdgeInsets.only(
                          left: dimen.paddingLarge,
                          right: dimen.paddingLarge,
                          top: dimen.paddingVerySmall,
                          bottom: dimen.paddingVerySmall),
                      child: Text(
                        LabelStr.lblDone,
                        style: TextStyle(
                            fontSize: dimen.textNormal,
                            fontFamily: MyFont.Poppins_semibold,
                            color: whiteTextColor),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: loading
                  ? widget.loader
                  : Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: EdgeInsets.all(12.0),
                            child: _buildFilteredImage(
                              _filter,
                              image,
                              filename,
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: (() async {

                                        var imageFile = await saveFilteredImage();

                                        final cropImageFile = await ImageCropper.cropImage(
                                            sourcePath: imageFile.path,
                                            maxWidth: 512,
                                            maxHeight: 512,
                                            compressFormat: ImageCompressFormat.jpg);

                                        if( cropImageFile != null){
                                          isCropped.value = true;
                                          var img = imageLib.decodeImage(await cropImageFile.readAsBytes());
                                          setState(()  {
                                            image = img;
                                            imgPath = cropImageFile.path;
                                            testImg = cropImageFile.path;
                                            cachedFilters = {};

                                            print("inside set state  $testImg");
                                          });
                                          print("inside image cropping  ${cropImageFile.path}");
                                        }
                                      }),
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: SvgPicture.asset(
                                          MyImage.ic_crop_icon,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    // InkWell(
                                    //   onTap: ((){
                                    //
                                    //   }),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.all(18.0),
                                    //     child: SvgPicture.asset(
                                    //       MyImage.ic_filter_tab_icon,
                                    //       color: Colors.deepPurple,
                                    //     ),
                                    //   ),
                                    // ),
                                    // isCropped.value ?
                                    // Image.file(File(testImg), height: 70,width: 70,fit: BoxFit.fill,)
                                    //     :SizedBox(width: 70,)
                                  ],
                                ),
                              ),
                            )),
                        Expanded(
                          flex: 2,
                          child: Container(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.filters.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        _buildFilterThumbnail(
                                            widget.filters[index], image, filename),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(
                                          widget.filters[index].name,
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () => setState(() {
                                    _filter = widget.filters[index];
                                  }),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  _buildFilterThumbnail(Filter filter, imageLib.Image image, String filename) {
    if (cachedFilters[filter.name] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Container(
                // radius: 50.0,
                height: 100,
                width: 100,
                child: Center(
                  child: widget.loader,
                ),
                // backgroundColor: Colors.transparent,
              );
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter.name] = snapshot.data;
              return Container(
                height: 100,
                width: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: MemoryImage(
                        snapshot.data as dynamic,
                      ),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10),
                ),
                // radius: 50.0,
                // backgroundImage:
                // backgroundColor: Colors.white,
              );
          }
          // unreachable
        },
      );
    } else {
      return Container(
        height: 100,
        width: 80,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: MemoryImage(
                cachedFilters[filter.name] as dynamic,
              ),
              fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${_filter?.name ?? "_"}_$filename');
  }

  Future<File> saveFilteredImage() async {
    var imageFile = await _localFile;
    await imageFile.writeAsBytes(cachedFilters[_filter?.name ?? "_"]);
    return imageFile;
  }

  Widget _buildFilteredImage(
      Filter filter, imageLib.Image image, String filename) {
    print("inside builder if condition    "+cachedFilters[filter?.name ?? "_"].toString());
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return
        FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return widget.loader;
            case ConnectionState.active:
            case ConnectionState.waiting:
              return widget.loader;
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return widget.circleShape
                  ? SizedBox(
                      height: MediaQuery.of(context).size.width / 3,
                      width: MediaQuery.of(context).size.width / 3,
                      child: Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: MediaQuery.of(context).size.width / 3,
                          backgroundImage: MemoryImage(
                            snapshot.data as dynamic,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                      color: screenBgColor,
                      image: DecorationImage(
                          image: MemoryImage(
                            snapshot.data as dynamic,
                          ),
                          fit: BoxFit.contain),
                      borderRadius: BorderRadius.circular(10),
                    ));
            // : Image.memory(
            //     snapshot.data as dynamic,
            //     fit: BoxFit.contain,
            //   );
          }
          // unreachable
        },
      );
    } else {
      return widget.circleShape
          ? SizedBox(
              height: MediaQuery.of(context).size.width / 3,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: MediaQuery.of(context).size.width / 3,
                  backgroundImage: MemoryImage(
                    cachedFilters[filter?.name ?? "_"] as dynamic,
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
              color: Colors.yellow,
              image: DecorationImage(
                  image: MemoryImage(
                    cachedFilters[filter?.name ?? "_"] as dynamic,
                  ),
                  fit: BoxFit.cover
                  // fit: widget.fit
                  ),
              borderRadius: BorderRadius.circular(10),
            ));
      // Image.memory(
      //     cachedFilters[filter?.name ?? "_"] as dynamic,
      //     fit: widget.fit,
      //   );
    }
  }
}

///The global applyfilter function
FutureOr<List<int>> applyFilter(Map<String, dynamic> params) {
  Filter filter = params["filter"];
  imageLib.Image image = params["image"];
  String filename = params["filename"];
  List<int> _bytes = image.getBytes();
  if (filter != null) {
    filter.apply(_bytes as dynamic, image.width, image.height);
  }
  imageLib.Image _image =
      imageLib.Image.fromBytes(image.width, image.height, _bytes);
  _bytes = imageLib.encodeNamedImage(_image, filename);

  return _bytes;
}

///The global buildThumbnail function
FutureOr<List<int>> buildThumbnail(Map<String, dynamic> params) {
  int width = params["width"];
  params["image"] = imageLib.copyResize(params["image"], width: width);
  return applyFilter(params);
}
