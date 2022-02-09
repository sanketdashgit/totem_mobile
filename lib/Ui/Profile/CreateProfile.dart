import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Profile/CreateProfileBasicInfo.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import '../Customs/ButtonRegular.dart';
import '../Customs/CommonNetworkImage.dart';
import '../SelectLocation.dart';

class CreateProfile extends StatefulWidget {
  bool isEdit = false;

  CreateProfile({this.isEdit});

  @override
  _CreateProfileState createState() => _CreateProfileState();
}
//comment in sanket branch

class _CreateProfileState extends State<CreateProfile> {
  var _fullNameController = TextEditingController();
  var _lastNameController = TextEditingController();
  var _emailController = TextEditingController();
  var _bioController = TextEditingController();
  var isButtonLoaderEnabled = false.obs;
  String _userImage = "";
  String countryValue;
  String stateValue;
  String cityValue;

  var addressStr = ''.obs;
  var latitude = 0.0;
  var longitude = 0.0;

  File _image;
  final ImagePicker _picker = ImagePicker();

  Intro intro;

  void setupIntro() {
    intro = Intro(
      noAnimation: false,
      maskColor: Colors.black.withAlpha(170),
      stepCount: 1,
      maskClosable: false,
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          IntroMessage.lblIntro8,
        ],
        buttonTextBuilder: (currPage, totalPage) {
          if (currPage < totalPage - 1) {
            return LabelStr.lblNext;
          } else {
            SessionImpl.setIntro6(true);
            return LabelStr.lblNext;
          }
        },
      ),
    );
  }

  void startIntro6() {
    if (!SessionImpl.getIntro6()) {
      intro.start(context);
    }
  }

  @override
  void initState() {
    setupIntro();
    super.initState();
    UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
    _fullNameController.text = user.firstname;
    _lastNameController.text = user.lastname;
    _emailController.text = user.email;
    if (user.bio != null && user.bio.toString().isNotEmpty)
      _bioController.text = user.bio;
    if (user.image != null && user.image.toString().isNotEmpty)
      _userImage = user.image;
    if (user.address.isNotEmpty) {
      addressStr.value = user.address;
      latitude = double.parse(user.latitude);
      longitude = double.parse(user.longitude);
    }
    if (!widget.isEdit) {
      rq.selectedArtist.clear();
      rq.selectedTracks.clear();
      rq.selectedGener.clear();
      rq.selectedEvents.clear();
      rq.nextEvents.clear();
    }
    Future.delayed(Duration(seconds: 1)).then((value) => startIntro6());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Padding(
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(54), left: 30.0, right: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.all(dimen.paddingForBackArrow),
                          child: SvgPicture.asset(MyImage.ic_arrow),
                        )),
                    Text(
                      widget.isEdit
                          ? LabelStr.lblEditProfile
                          : LabelStr.lblcreateprofile,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: MyFont.Poppins_semibold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      width: 15,
                    )
                  ],
                ),
                SizedBox(
                  height: 27.0,
                ),
                _tabController(),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 22.0,
                    ),
                    Center(
                      child: Stack(
                        children: <Widget>[
                          _image == null && _userImage.isNotEmpty
                              ? CommonNetworkImage(
                                  height: 70,
                                  width: 70,
                                  radius: 35,
                                  imageUrl: _userImage,
                                )
                              : CircleAvatar(
                                  radius: 40.0,
                                  backgroundImage: _image == null
                                      ? AssetImage(MyImage.ic_dummy_profile)
                                      : FileImage(_image),
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: ((builder) => bottomSheet()));
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: buttonPrimary,
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(MyImage.ic_camera)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 27.0,
                    ),
                    Container(
                        child: textFieldFor(
                            LabelStr.lblFullName, _fullNameController,
                            autocorrect: false,
                            maxLength: 50,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.none,
                            prefixIcon: Container(
                              padding: EdgeInsets.all(13),
                              child: SvgPicture.asset(MyImage.ic_person),
                            ),
                            keyboardType: TextInputType.text)),
                    SizedBox(
                      height: 26.0,
                    ),
                    Container(
                      key: intro.keys[0],
                      width: 0,
                      height: 0,
                    ),
                    Container(
                        child: textFieldFor(
                            LabelStr.lblLastName, _lastNameController,
                            autocorrect: false,
                            maxLength: 50,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.none,
                            prefixIcon: Container(
                              padding: EdgeInsets.all(13),
                              child: SvgPicture.asset(MyImage.ic_person),
                            ),
                            keyboardType: TextInputType.text)),
                    SizedBox(
                      height: 26.0,
                    ),
                    Container(
                        child:
                            textFieldFor(LabelStr.lblEmailId, _emailController,
                                autocorrect: false,
                                maxLength: 50,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.none,
                                prefixIcon: Container(
                                  padding: EdgeInsets.all(13),
                                  child: SvgPicture.asset(MyImage.ic_email),
                                ),
                                keyboardType: TextInputType.emailAddress)),
                    SizedBox(
                      height: 26.0,
                    ),
                    InkWell(
                        onTap: () async {
                          var result = await Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => SelectLocation()));
                          if (result != null) {
                            addressStr.value = result[1]['placeName'];
                            latitude = result[1]['lat'];
                            longitude = result[1]['lng'];
                          }
                        },
                        child: Obx(
                          () => Container(
                              padding: EdgeInsets.all(10),
                              height: 70,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                  border:
                                      Border.all(color: HexColor.borderColor)),
                              child: Text(
                                addressStr.value == ''
                                    ? LabelStr.lbllocation
                                    : addressStr.value,
                                style: TextStyle(
                                  fontFamily: MyFont.Poppins_medium,
                                  fontSize: 14,
                                  color: (addressStr.value == '')
                                      ? MyColor.hintTextColor()
                                      : Colors.white,
                                ),
                              )),
                        )),
                    SizedBox(
                      height: 26.0,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextField(
                        controller: _bioController,
                        autocorrect: false,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        maxLength: 500,
                        enabled: true,
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.none,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.1,
                                color: MyColor.textFieldBorderColor()),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: MyColor.textFieldBorderColor()),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                color: MyColor.textFieldBorderColor()),
                          ),
                          hintText: LabelStr.lblTellus,
                          counterStyle: TextStyle(
                            color: colorHintText,
                            fontFamily: MyFont.poppins_regular,
                          ),
                          hintStyle: TextStyle(
                            color: colorHintText,
                            fontFamily: MyFont.poppins_regular,
                          ),
                          prefixIcon: Container(
                            padding: EdgeInsets.only(
                                bottom: 35.0, left: 13.0, right: 13.0),
                            child: SvgPicture.asset(MyImage.ic_bio),
                          ),
                        ),
                        style: TextStyle(
                            color: whiteTextColor,
                            fontFamily: MyFont.poppins_regular,
                            fontSize: dimen.textNormal),
                      ),
                    ),
                    SizedBox(
                      height: 26.0,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 26, top: 8),
              child: Obx(
                () => Container(
                    child: ButtonRegular(
                        buttonText: isButtonLoaderEnabled.value
                            ? null
                            : LabelStr.lblNext,
                        onPressed: () {
                          _pressedOnCreateProfile();
                        })),
              ),
            ),
          ],
        ),
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
              _circleContainer(true),
              _lineContainer(false),
              _circleContainer(false),
              _lineContainer(false),
              _circleContainer(false),
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
                    fontSize: 12,
                    color: Colors.white),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  LabelStr.lblinterests,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: 12,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text(
                  LabelStr.lblmusic,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: 12,
                      color: Colors.grey),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _circleContainer(bool isActive) {
    return Container(
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setHeight(30),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: isActive
                  ? purpleTextColor
                  : greyTextColor,
              width: 2)),
    );
  }

  Widget _lineContainer(bool isActive) {
    return Expanded(
      child: Divider(
        color: isActive
            ? purpleTextColor
            : greyTextColor,
        height: 8.0,
      ),
    );
  }

  Widget bottomSheet() {
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
          top: dimen.paddingLarge),
      width: double.infinity,
      height: 150,
      child: Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: dimen.paddingLarge),
              child: Container(
                height: 3,
                width: 100,
                color: textColorGreyLight,
              ),
            ),
          ),
          Text(
            LabelStr.lblChooseProfilePicture,
            style: TextStyle(fontSize: dimen.textLarge, color: Colors.white),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera, color: Colors.white),
              onPressed: () {
                Get.back();
                takePhoto(ImageSource.camera);
              },
              label: Text(LabelStr.lblCamera,
                  style: TextStyle(
                      fontSize: dimen.textMedium, color: Colors.white)),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.white),
              onPressed: () {
                Get.back();
                takePhoto(ImageSource.gallery);
              },
              label: Text(LabelStr.lblGallery,
                  style: TextStyle(
                      fontSize: dimen.textMedium, color: Colors.white)),
            ),
          ])
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source, imageQuality: 50);

    // Crop
    final cropImageFile = await ImageCropper.cropImage(
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        sourcePath: pickedFile.path,
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.jpg);

    setState(() {
      _image = File(cropImageFile.path);
      uploadImage(_image);
    });
  }

  uploadImage(image) async {
    UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
    RequestManager.uploadImage(
        uri: endPoints.profileImageUpload,
        file: image,
        moduleId: user.id,
        isLoader: true,
        onSuccess: (response) {
          RequestManager.getSnackToast(
              title: LabelStr.lblSuccess,
              message: Messages.CProfileupload,
              colorText: Colors.white,
              backgroundColor: Colors.black);
        },
        onFailure: (error) {});
  }

  _pressedOnCreateProfile() {
    if (_fullNameController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankFirstName,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_lastNameController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankLastName,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_emailController.text.trim().isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.CBlankEmail,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_emailController.text.trim().isValidEmail() == false) {
      RequestManager.getSnackToast(
          message: Messages.CInvalidEmail,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (addressStr.value.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.enteraddress,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    } else if (_bioController.text.isEmpty) {
      RequestManager.getSnackToast(
          message: Messages.enterbio,
          title: Messages.CErrorMessage,
          backgroundColor: Colors.black);
      return;
    }
    isButtonLoaderEnabled.value = true;
    UserInfoModel user = (SessionImpl.getLoginProfileModel() as UserInfoModel);
    _UpdateUser({
      Parameters.CFirstName: _fullNameController.text,
      Parameters.CLastName: _lastNameController.text,
      Parameters.CEmail: _emailController.text.trim(),
      Parameters.CPhone: user.phone,
      Parameters.CBirthDate: user.birthDate,
      Parameters.CUserName: user.username,
      Parameters.CPassword: "",
      Parameters.CRole: "0",
      Parameters.Cid: user.id,
      Parameters.Caddress: addressStr.value,
      Parameters.Clatitude: latitude.toString(),
      Parameters.Clongitude: longitude.toString(),
      Parameters.Cbio: _bioController.text,
    }, false);
  }

  _UpdateUser(Map<String, dynamic> params, bool isLoader) {
    RequestManager.postRequest(
        uri: endPoints.updateUser,
        body: params,
        isLoader: isLoader,
        onSuccess: (response) {
          isButtonLoaderEnabled.value = false;
          Get.to(CreateProfileBasicInfo(
            isEdit: widget.isEdit,
          ));
        },
        onFailure: () {
          isButtonLoaderEnabled.value = false;
        });
  }
}
