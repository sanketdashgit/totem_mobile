import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Ui/Event/CreateEventReview.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import '../Customs/ImageUploadButton.dart';

class CreateEventUploadImage extends StatefulWidget {
  @override
  _CreateEventUploadImage createState() => _CreateEventUploadImage();
}
//comment in sanket branch

class _CreateEventUploadImage extends State<CreateEventUploadImage> {
  var isButtonLoaderEnabled = false.obs;

  // Crop code
  var cropImagePath = ''.obs;
  var cropImagePath1 = ''.obs;
  var cropImagePath2 = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Padding(
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(54),
            left: dimen.paddingBigLarge,
            right: dimen.paddingBigLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                          child: SvgPicture.asset(MyImage.ic_arrow),
                        )),
                    Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            LabelStr.lbleventdetails,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: MyFont.Poppins_semibold,
                                color: Colors.white),
                          ),
                        ))
                  ],
                ),
                SizedBox(
                  height: 27.0,
                ),
                _tabController(),
                SizedBox(
                  height: dimen.marginLarge,
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: dimen.paddingExtraLarge),
                  child: Column(
                    children: [
                      Obx(() => imagePicker(
                          rq.isEditEvent.value && cropImagePath.value.isEmpty
                              ? rq.coverUrl.value
                              : cropImagePath.value,
                          1,
                          LabelStr.lbladdcoverphoto)),
                      SizedBox(
                        height: dimen.marginLarge,
                      ),
                      Obx(() => imagePicker(
                          rq.isEditEvent.value && cropImagePath1.value.isEmpty
                              ? rq.mapUrl.value
                              : cropImagePath1.value,
                          2,
                          LabelStr.lbladdevntmap)),
                      SizedBox(
                        height: dimen.marginLarge,
                      ),
                      Obx(() => imagePicker(
                          rq.isEditEvent.value && cropImagePath2.value.isEmpty
                              ? rq.lineupUrl.value
                              : cropImagePath2.value,
                          3,
                          LabelStr.lbladdartistlinup)),
                    ],
                  ),
                ),
              ),
            ),
            Obx(
              () => Container(
                margin: EdgeInsets.only(
                    bottom: dimen.marginNormal, top: dimen.marginNormal),
                decoration: BoxDecoration(
                    color: buttonPrimary,
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                child: ButtonRegular(
                  buttonText:
                      isButtonLoaderEnabled.value ? null : LabelStr.lblNext,
                  onPressed: () {
                    _pressedToSaveData();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imagePicker(String cropImagePath, int index, String buttonLabel) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 0.56,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: cropImagePath == ''
                ? Image.asset(
                    MyImage.ic_preview,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.56,
                    fit: BoxFit.cover,
                  )
                : cropImagePath.contains("http")
                    ? Image(
                        image: CachedNetworkImageProvider(cropImagePath),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.56,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(cropImagePath),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.56,
                      ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(dimen.paddingLarge),
              child: ImageUploadButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: ((builder) => bottomSheet(index)));
                },
                buttonText: buttonLabel,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _tabController() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(10),
              right: ScreenUtil().setWidth(10)),
          child: Row(
            children: [
              _circleContainerTic(),
              _lineContainer(true),
              _circleContainer(true, false),
              _lineContainer(false),
              _circleContainer(false, false),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LabelStr.lblbsasicInfo,
                style: TextStyle(
                    fontFamily: MyFont.poppins_regular,
                    fontSize: dimen.textSmall,
                    color: purpleTextColor),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  LabelStr.lbladdphoto,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: dimen.textSmall,
                      color: whiteTextColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text(
                  LabelStr.lblreview,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: dimen.textSmall,
                      color: greyTextColor),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _circleContainer(bool isActive, bool isCheck) {
    return Container(
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setHeight(30),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: isActive ? purpleTextColor : greyTextColor, width: 2)),
    );
  }

  Widget _circleContainerTic() {
    return Container(
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setHeight(30),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: purpleTextColor, width: 2)),
      child: Padding(
          padding: const EdgeInsets.all(dimen.paddingVerySmall),
          child: SvgPicture.asset(MyImage.ic_done)),
    );
  }

  Widget _lineContainer(bool isActive) {
    return Expanded(
      child: Divider(
        color: isActive ? purpleTextColor : greyTextColor,
        height: 8.0,
      ),
    );
  }

  _pressedToSaveData() {
    if (rq.isEditEvent.value) {
      if (cropImagePath.value.isNotEmpty)
        rq.createEventImage.value = cropImagePath.value;
      if (cropImagePath1.value.isNotEmpty)
        rq.createEventImage1.value = cropImagePath1.value;
      if (cropImagePath2.value.isNotEmpty)
        rq.createEventImage2.value = cropImagePath2.value;
      Get.to(CreateEventReview());
    } else {
      if (cropImagePath.value.isEmpty)
        RequestManager.getSnackToast(message: Messages.CChooseCoverPhoto);
      else if (cropImagePath1.value.isEmpty)
        RequestManager.getSnackToast(message: Messages.CChooseMapPhoto);
      else if (cropImagePath2.value.isEmpty)
        RequestManager.getSnackToast(message: Messages.CChooseLineupPhoto);
      else {
        rq.createEventImage.value = cropImagePath.value;
        rq.createEventImage1.value = cropImagePath1.value;
        rq.createEventImage2.value = cropImagePath2.value;
        Get.to(CreateEventReview());
      }
    }
  }

  Widget bottomSheet(int index1) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(38),
          topRight: Radius.circular(38),
        ),
        color: roundedcontainer,
      ),
      padding: EdgeInsets.only(
          left: dimen.paddingLarge,
          right: dimen.paddingLarge,
          bottom: dimen.paddingLarge,
          top: dimen.paddingLarge
      ),
      width: double.infinity,
     height:150,
      child: Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: dimen.paddingLarge),
              child: Container(
                height: 3,
                width: 100,
                color: textColorGreyLight,
              ),
            ),
          ),
          Text(
            LabelStr.lblChoosePicture,
            style: TextStyle(
                fontSize: dimen.textLarge,
                color: Colors.white
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera, color: Colors.white),
              onPressed: () {
                Get.back();
                //Navigator.pop(context);
                takePhoto(ImageSource.camera, index1);
              },
              label: Text(LabelStr.lblCamera,style: TextStyle(
    fontSize: dimen.textMedium, color: Colors.white)),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.white),
              onPressed: () {
                Get.back();
                //Navigator.pop(context);
                takePhoto(ImageSource.gallery, index1);
              },
              label: Text(LabelStr.lblGallery,style: TextStyle(
                  fontSize: dimen.textMedium, color: Colors.white)),
            ),
          ])
        ],
      ),
    );
  }

  void takePhoto(ImageSource source, int index) async {
    final pickedFile = await _picker.getImage(source: source);

    // Crop
    final cropImageFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg);
    switch (index) {
      case 1:
        cropImagePath.value = cropImageFile.path;
        break;
      case 2:
        cropImagePath1.value = cropImageFile.path;
        break;
      case 3:
        cropImagePath2.value = cropImageFile.path;
        break;
    }
  }
}
