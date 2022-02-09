import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/UploadFile.dart';
import 'package:totem_app/Models/AddMemories.dart';
import 'package:totem_app/Models/FeedListDataModel.dart';
import 'package:totem_app/Models/MemoriesModel.dart';
import 'package:totem_app/Models/SelectMediaModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/SimpleSlider.dart';
import 'package:totem_app/Ui/Customs/VideoPlayerScreen.dart';
import 'package:totem_app/Ui/Post/TagPeople.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/helper.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/PhotoFilter/filters/preset_filters.dart';
import 'package:totem_app/Utility/PhotoFilter/widgets/photo_filter.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../Customs/ButtonRegular.dart';
import '../Customs/ImageUploadButton.dart';
import 'TagEvent.dart';
import 'VideoEditor.dart';

class AddNewPost extends StatefulWidget {
  String postType;
  int memoryId;
  String caption;
  int eventId;

  AddNewPost(this.postType, {this.memoryId, this.caption, this.eventId});

  @override
  _AddNewPostState createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
  var isButtonLoaderEnabled = false.obs;
  var cropImagePath = ''.obs;

  final ImagePicker _picker = ImagePicker();
  int currentPage = 0;
  PageController _controller;
  var imagePageRefrasher = ''.obs;
  var isSearch = false.obs;
  var focusNode = FocusNode();

  Timer _timer;
  var widgetRefresher = "".obs;
  var _captionController = TextEditingController();

  var totalSize = 0;

  FeedListDataModel editModel;
  bool isEdit = false;

  List<Map<String, String>> pageItemList = [];

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  Intro intro;

  void setupIntro() {
    List<String> texts = [
      IntroMessage.lblIntro13,
    ];
    intro = Intro(
      noAnimation: false,
      padding: EdgeInsets.zero,
      maskColor: Colors.black.withAlpha(170),
      stepCount: 1,
      maskClosable: false,
      /*widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          IntroMessage.lblIntro13,
          //'Now Click on memories and let\'s make your first memory.',
          //'Memories is where you can organize all of your photos and videos by concert name and year attended. Organize all of your most memorable events here, so you can easily reminisce later.(Memories do not appear on the feed, only your profile page. Privacy settings are available for each individual photo/video within the memory)',
        ],
        buttonTextBuilder: (currPage, totalPage) {
          if(currPage < totalPage - 1){
            return 'Next';
          }else{
            SessionImpl.setIntro9(true);
            return 'Next';
          }
          //return currPage < totalPage - 1 ? 'Next' : 'Next';
        },
      ),*/
      widgetBuilder: StepWidgetBuilder.useAdvancedTheme(
        widgetBuilder: (params) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  child: Text(
                    texts[params.currentStepIndex],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: Colors.white,
                    ),
                  ),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    overlayColor: MaterialStateProperty.all<Color>(
                      Colors.white.withOpacity(0.1),
                    ),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 8,
                      ),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      StadiumBorder(),
                    ),
                  ),
                  onPressed: () {
                    if (params.currentStepIndex < params.stepCount - 1) {
                      params.onNext();
                    } else {
                      params.onFinish();
                      SessionImpl.setIntro9(true);
                      //_profileKey.currentState.startIntro();
                    }
                  },
                  child: Text(
                    params.currentStepIndex < params.stepCount - 1
                        ? LabelStr.lblNext
                        : LabelStr.lblNext,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
    intro.setStepConfig(0, padding: EdgeInsets.only(right: -40, left: -80));
  }

  var isIntroDone = false;

  void startIntro9(BuildContext context) {
    if (!SessionImpl.getIntro9()) {
      if (!isIntroDone) {
        isIntroDone = true;
        Future.delayed(Duration(seconds: 1))
            .then((value) => intro.start(context));
      }
    }
  }

  @override
  void initState() {
    setupIntro();
    super.initState();
    editModel = Get.arguments;
    isEdit = editModel != null;

    rq.pickedMediaList = [];
    _controller = PageController(initialPage: currentPage);
    focusNode.addListener(() {
      isSearch.value = focusNode.hasFocus;
    });
    rq.tagPeopleList.clear();
    rq.tagPeopleSelectedIds.clear();
    rq.tagPeopleCount.value = '';
    if (isEdit) {
      _setEditData();
      _callGetAllTagUsersApi();
    }
  }

  _setEditData() {
    _captionController.text = editModel.caption;
    if (editModel.eventId != 0) {
      rq.selectedEventId.value = editModel.eventId;
      rq.selectedEventName.value = editModel.eventName;
      rq.selectedEventAdd.value = editModel.address;
      rq.selectedEventImg.value = editModel.eventImages[0].downloadlink;
    }
    if (editModel.postMediaLinks.length > 0) {
      editModel.postMediaLinks.forEach((element) {
        SelectMediaModel data = new SelectMediaModel(
            element.videolink, element.downloadlink, 0, element.postFileId, "");
        rq.pickedMediaList.add(data);
      });
      imagePageRefrasher.value = Utilities.getRandomString();
    }
  }

  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    super.dispose();
  }

  void _pressedOnNext() {
    if (widget.postType == LabelStr.lblAddMediaInMemory) {
      if (rq.pickedMediaList.length == 0) {
        RequestManager.getSnackToast(message: Messages.CPostMedia);
      } else {
        Widgets.showLoading();
        _checkAllVideosUploaded();
      }
    } else if (widget.postType == LabelStr.lblAddMemories) {
      if (_captionController.text.isEmpty) {
        RequestManager.getSnackToast(message: Messages.CPostCaption);
      } else if (rq.pickedMediaList.length == 0) {
        RequestManager.getSnackToast(message: Messages.CPostMedia);
      } else if (rq.selectedEventId.value == 0) {
        RequestManager.getSnackToast(message: Messages.CTagEvent);
      } else {
        Widgets.showLoading();
        _checkAllVideosUploaded();
      }
    } else {
      if (_captionController.text.isEmpty) {
        RequestManager.getSnackToast(message: Messages.CPostCaption);
      } else if (rq.pickedMediaList.length == 0) {
        RequestManager.getSnackToast(message: Messages.CPostMedia);
      } else {
        double totalSize = 0;
        rq.pickedMediaList.forEach((element) {
          totalSize = totalSize + element.size;
        });
        Widgets.showLoading();
        _checkAllVideosUploaded();
      }
    }
  }

  void _callAddPostApi() {
    var body = {
      Parameters.CPostId: isEdit ? editModel.postId : 0,
      Parameters.CCaption: _captionController.text.toString(),
      Parameters.CeventId:
          rq.selectedEventId.value == 0 ? 0 : rq.selectedEventId.value,
      Parameters.CtagUserID: rq.tagPeopleSelectedIds,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CpostFiles: mediaFiles,
    };
    RequestManager.postRequest(
        uri: endPoints.UpdatedAddEditpost,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          if (response[Parameters.CPostId] != 0) {
            if (rq.removedList.length > 0) {
              _callDeleteMediaApi(response[Parameters.CPostId], rq.removedList);
            }
          }
          closeView();
          rq.selectedEventId.value = 0;
          rq.selectedEventName.value = "";
          rq.selectedEventAdd.value = "";
          rq.selectedEventImg.value = "";
        },
        onFailure: (error) {
          Widgets.loadingDismiss();
          Get.back(result: false);
        });
  }

  void _callAddMemoriesApi() {
    var body = {
      Parameters.CMemoriesId:
          widget.postType == LabelStr.lblAddMediaInMemory ? widget.memoryId : 0,
      Parameters.CCaption: widget.postType == LabelStr.lblAddMediaInMemory
          ? widget.caption
          : _captionController.text.toString(),
      Parameters.CeventId: widget.postType == LabelStr.lblAddMediaInMemory
          ? widget.eventId
          : rq.selectedEventId.value,
      Parameters.CtagUserID: [],
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CmemorieFiles: mediaFiles,
    };
    RequestManager.postRequest(
        uri: endPoints.CreateMemorieWithFiles,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          Widgets.loadingDismiss();
          if (widget.postType == LabelStr.lblAddMediaInMemory) {
            AddMemories model = AddMemories.fromJson(response);
            model.memorieFiles.forEach((element) {
              mediaList.add(MemorieMediaLink(
                  memorieFileId: element.memorieFileId,
                  downloadlink: element.fileName,
                  mediaType: element.mediaType,
                  videolink: element.video,
                  isPrivate: false));
            });
            Get.back(result: mediaList);
          } else {
            Get.back(result: false);
          }
          rq.selectedEventId.value = 0;
          rq.selectedEventName.value = "";
          rq.selectedEventAdd.value = "";
          rq.selectedEventImg.value = "";
        },
        onFailure: (error) {
          Widgets.loadingDismiss();
          Get.back(result: false);
        });
  }

  void _callDeleteMediaApi(int postId, List<int> fileIds) {
    var body = {
      Parameters.CPostId: postId,
      Parameters.CPostFileId: fileIds,
    };
    RequestManager.postRequest(
        uri: endPoints.removepostmedia,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {},
        onFailure: (error) {});
  }

  callUploadApi(int postId, int index) {
    if (rq.pickedMediaList[index].fileId == 0) {
      var imageFile = File(rq.pickedMediaList[index].path);
      var videoFile = null;
      String mediaType = global.MEDIA_IMAGE_TYPE;
      if (rq.pickedMediaList[index].type.isNotEmpty) {
        videoFile = File(rq.pickedMediaList[index].type);
        mediaType = global.MEDIA_VIDEO_TYPE;
      }
      RequestManager.uploadPostMedia(
          uri: endPoints.uploadPostImage,
          file: imageFile,
          whichId: Parameters.CPostId_,
          moduleId: postId,
          videoFile: videoFile,
          mediaType: mediaType,
          onSuccess: (response) {
            _checkNextFileToUpload(index, postId);
            rq.selectedEventId.value = 0;
            rq.selectedEventName.value = "";
            rq.selectedEventAdd.value = "";
            rq.selectedEventImg.value = "";
          },
          onFailure: (error) {
            _checkNextFileToUpload(index, postId);
          });
    } else {
      _checkNextFileToUpload(index, postId);
    }
  }

  callUploadImagesOnAws(int index) {
    if (rq.pickedMediaList[index].fileId == 0) {
      var imageFile = File(rq.pickedMediaList[index].path);
      uploadVideoAws(imageFile, index, 0);
    } else {
      _checkNextFileToUploadAws(index);
    }
  }

  List<MemorieMediaLink> mediaList = [];

  /*void checkNextMemories(index, memoryId) {
    if (index == rq.pickedMediaList.length - 1) {
      rq.selectedEventId.value = 0;
      rq.selectedEventName.value = "";
      rq.selectedEventAdd.value = "";
      rq.selectedEventImg.value = "";
      Widgets.loadingDismiss();
      Get.back(result: mediaList);
    } else {
      print('api done $index');
      index++;
      callMemoriesMediaApi(memoryId, index);
    }
  }*/

/*  callMemoriesMediaApi(int memoryId, int index) {
    print("memoryId     $memoryId");
    print('api start $index');
    if (rq.pickedMediaList[index].fileId == 0) {
      var imageFile = File(rq.pickedMediaList[index].path);
      var videoFile = null;
      String mediaType = global.MEDIA_IMAGE_TYPE;
      if (rq.pickedMediaList[index].type.isNotEmpty) {
        videoFile = File(rq.pickedMediaList[index].type);
        mediaType = global.MEDIA_VIDEO_TYPE;
      }
      RequestManager.uploadPostMedia(
          uri: endPoints.uploadMemoriesFiles,
          file: imageFile,
          whichId: "MemorieId",
          moduleId: memoryId,
          videoFile: videoFile,
          mediaType: mediaType,
          onSuccess: (response) {
            var media = MemorieMediaLink.fromJson(response['result']);
            mediaList.add(media);
            checkNextMemories(index, memoryId);
          },
          onFailure: (error) {
            checkNextMemories(index, memoryId);
          });
    } else {
      checkNextMemories(index, memoryId);
    }
  }*/

  void closeView() {
    Widgets.loadingDismiss();
    Get.back(result: true);
    RequestManager.getSnackToast(
        title: LabelStr.lblSuccess,
        message: Messages.CPostUpdate,
        backgroundColor: Colors.black);
  }

  _checkNextFileToUpload(int index, int postId) {
    if (index == rq.pickedMediaList.length - 1) {
      closeView();
    } else {
      index++;
      callUploadApi(postId, index);
    }
  }

  _checkNextFileToUploadAws(int index) {
    if (index == rq.pickedMediaList.length - 1) {
      if (widget.postType == LabelStr.lblAddMemories ||
          widget.postType == LabelStr.lblAddMediaInMemory) {
        _callAddMemoriesApi();
      } else {
        _callAddPostApi();
      }
    } else {
      index++;
      callUploadImagesOnAws(index);
    }
  }

  int checkCounter = 0;

  _checkAllVideosUploaded() {
    checkCounter++;
    var isDone = true;
    rq.pickedMediaList.forEach((element) {
      if (element.type.isNotEmpty && element.videoAws.isEmpty) {
        isDone = false;
      }
    });
    if (!isDone && checkCounter < 30) {
      Future.delayed(Duration(seconds: 1))
          .then((value) => {_checkAllVideosUploaded()});
    } else {
      callUploadImagesOnAws(0);
    }
  }

  void _callGetAllTagUsersApi() {
    var body = {
      Parameters.CPostId: editModel.postId,
    };
    RequestManager.postRequest(
        uri: endPoints.GetTagUserofPost,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          rq.tagPeopleList = List<SuggestedUser>.from(
              response.map((x) => SuggestedUser.fromJson(x)));
          rq.tagPeopleSelectedIds.clear();
          rq.tagPeopleList.forEach((element) {
            rq.tagPeopleSelectedIds.add(element.id);
          });
          rq.tagPeopleCount.value = rq.tagPeopleList.length == 0
              ? ""
              : rq.tagPeopleList.length == 1
                  ? rq.tagPeopleList[0].username
                  : rq.tagPeopleList.length.toString() + " peoples";
        },
        onFailure: (error) {
        });
  }

  void uploadVideoAws(File file, int index, int listIndex) {
    String fileExtension = path.extension(file.path);
    String name = Utilities.getRandomString();
    _callGetAwsLink(name + fileExtension, file, index, listIndex);
  }

  List<Map<String, dynamic>> mediaFiles = [];

  void _callGetAwsLink(String fileName, File file, int index, int listIndex) {
    var body = {Parameters.CFileName: fileName};
    RequestManager.postRequest(
        uri: endPoints.testingPathReturn,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: true,
        onSuccess: (response) async {
          UploadFile uploadFile = UploadFile();
          await uploadFile.call(response['uploadURL'], file);
          if (uploadFile.isUploaded != null && uploadFile.isUploaded) {
            if (index == -1) {
              rq.pickedMediaList[listIndex].videoAws = response['downloadURL'];
            }
          }
          if (index != -1) {
            var video = "";
            var mediaType = global.MEDIA_IMAGE_TYPE;
            if (rq.pickedMediaList[index].type.isNotEmpty) {
              mediaType = global.MEDIA_VIDEO_TYPE;
              video = rq.pickedMediaList[index].videoAws;
            }
            mediaFiles.add({
              widget.postType == LabelStr.lblAddMemories
                  ? Parameters.CMemoriesId
                  : Parameters.CPostFileId: 0,
              widget.postType == LabelStr.lblAddMemories
                  ? Parameters.CMemoriesId
                  : Parameters.CPostId: 0,
              Parameters.CFileName: response[Parameters.CDownloadURL],
              Parameters.CMediaType: mediaType,
              Parameters.CVideo_: video
            });
            _checkNextFileToUploadAws(index);
          }
        },
        onFailure: (error) {
          if (index != -1) {
            _checkNextFileToUploadAws(index);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.postType == LabelStr.lblAddMemories) {
      startIntro9(context);
    }
    return Scaffold(
      body: Container(
        color: screenBgColor,
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(54),
            left: dimen.paddingExtraLarge,
            right: dimen.paddingExtraLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      rq.selectedEventId.value = 0;
                      rq.selectedEventName.value = "";
                      rq.selectedEventAdd.value = "";
                      rq.selectedEventImg.value = "";
                      Get.back();
                    },
                    child: SvgPicture.asset(MyImage.ic_cross)),
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        widget.postType,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: MyFont.Poppins_semibold,
                            color: Colors.white),
                      ),
                    ))
              ],
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: dimen.paddingLarge,
                        bottom: dimen.paddingVerySmall),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Obx(
                          () => imagePageRefrasher.value.isEmpty
                              ? Container()
                              : Container(
                                  height: dimen.newPostImageHeight,
                                  margin:
                                      EdgeInsets.only(top: dimen.paddingMedium),
                                  child: _imageListPager(),
                                  // child: _imageList(),
                                ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: dimen.paddingMedium),
                          child: ImageUploadButton(
                            width: 150,
                            color: addPostBgColor,
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: ((builder) =>
                                      mediaChooserBottomSheet(context)));
                            },
                            buttonText: LabelStr.lbladdmedia,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: dimen.paddingMedium),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(dimen.radiusNormal)),
                            color: addPostBgColor,
                          ),
                          child: Column(
                            children: [
                              if (widget.postType == LabelStr.lblAddPost ||
                                  widget.postType == LabelStr.lblEditPost ||
                                  widget.postType == LabelStr.lblAddMemories)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.all(dimen.paddingMedium),
                                      child: CommonNetworkImage(
                                        height: 40,
                                        width: 40,
                                        radius: 20,
                                        imageUrl:
                                            (SessionImpl.getLoginProfileModel()
                                                    as UserInfoModel)
                                                .image
                                                .toString(),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin:
                                            EdgeInsets.all(dimen.marginSmall),
                                        child: TextField(
                                          controller: _captionController,
                                          maxLengthEnforcement:
                                              MaxLengthEnforcement.enforced,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: LabelStr.lblWriteACaption,
                                            counterStyle: TextStyle(
                                              color: colorHintText,
                                              fontFamily:
                                                  MyFont.poppins_regular,
                                            ),
                                            hintStyle: TextStyle(
                                              color: colorHintText,
                                              fontFamily:
                                                  MyFont.poppins_regular,
                                            ),
                                          ),
                                          maxLength: 250,
                                          minLines: 2,
                                          maxLines: 4,
                                          style: TextStyle(
                                              color: whiteTextColor,
                                              fontFamily:
                                                  MyFont.poppins_regular,
                                              fontSize: dimen.textNormal),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (widget.postType == LabelStr.lblAddPost ||
                                  widget.postType == LabelStr.lblEditPost ||
                                  widget.postType == LabelStr.lblAddMemories)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: dividerLineColor,
                                ),
                              if (widget.postType == LabelStr.lblAddPost ||
                                  widget.postType == LabelStr.lblEditPost)
                                Container(
                                  padding: EdgeInsets.all(dimen.paddingMedium),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(TagePeople());
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          LabelStr.lblTagPeople,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily:
                                                  MyFont.poppins_regular,
                                              color: whiteTextColor
                                                  .withOpacity(0.8)),
                                        ),
                                        Obx(() => Expanded(
                                            flex: 1,
                                            child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.end,
                                              text: new TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        rq.tagPeopleCount.value,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: MyFont
                                                            .poppins_regular,
                                                        color: whiteTextColor
                                                            .withOpacity(0.6)),
                                                  ),
                                                  WidgetSpan(
                                                    child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 16,
                                                      color: whiteTextColor
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))),
                                      ],
                                    ),
                                  ),
                                ),
                              if (widget.postType == LabelStr.lblAddPost ||
                                  widget.postType == LabelStr.lblEditPost)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: dividerLineColor,
                                ),
                              if (widget.postType == LabelStr.lblAddPost ||
                                  widget.postType == LabelStr.lblEditPost ||
                                  widget.postType == LabelStr.lblAddMemories)
                                Container(
                                  padding: EdgeInsets.all(dimen.paddingMedium),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(TagEvent());
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          LabelStr.lblTagPeople,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily:
                                                  MyFont.poppins_regular,
                                              color: whiteTextColor
                                                  .withOpacity(0.8)),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.end,
                                              text: new TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: MyFont
                                                            .poppins_regular,
                                                        color: whiteTextColor
                                                            .withOpacity(0.6)),
                                                  ),
                                                  WidgetSpan(
                                                    child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 16,
                                                      color: whiteTextColor
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              Obx(() => rq.selectedEventName.value.isEmpty
                                  ? Container()
                                  : Container(
                                      padding: EdgeInsets.only(
                                          left: dimen.paddingMedium,
                                          right: dimen.paddingMedium,
                                          bottom: dimen.paddingMedium),
                                      decoration: BoxDecoration(
                                          color: addPostBgColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          CommonNetworkImage(
                                            height: 50,
                                            width: 50,
                                            radius: 25,
                                            imageUrl: rq.selectedEventImg.value
                                                    .isNotEmpty
                                                ? rq.selectedEventImg.value
                                                : "",
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    rq.selectedEventName.value,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: MyFont
                                                            .poppins_regular,
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    rq.selectedEventAdd.value,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontFamily: MyFont
                                                            .poppins_regular,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    key: intro.keys[0],
                    width: double.infinity,
                    height: 0,
                  )
                ],
              )),
            ),
            Obx(
              () => Container(
                margin: EdgeInsets.only(
                    bottom: dimen.marginLarge, top: dimen.marginNormal),
                // width: MediaQuery.of(context).size.width,
                // height: 55,
                decoration: BoxDecoration(
                    color: buttonPrimary,
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                child: ButtonRegular(
                  buttonText: isButtonLoaderEnabled.value
                      ? null
                      : isEdit
                          ? LabelStr.lblSave
                          : LabelStr.lblCreatePost,
                  onPressed: () {
                    _pressedOnNext();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomSheetForSource(String selectionType) {
    return Container(
      width: double.infinity,
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
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            LabelStr.lblSelect+" $selectionType",
            style: TextStyle(fontSize: dimen.textLarge, color: Colors.white),
          ),
          SizedBox(
            height: dimen.dividerHeightLarge,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(
                Icons.camera,
                color: Colors.white,
              ),
              onPressed: () {
                Get.back();
                //Navigator.pop(context);
                takePhoto(selectionType);
              },
              label: Text(LabelStr.lblCamera,
                  style: TextStyle(
                      fontSize: dimen.textMedium, color: Colors.white)),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.white),
              onPressed: () {
                Get.back();
                takePhoto(selectionType);
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

  Widget mediaChooserBottomSheet(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            LabelStr.lblSelectMediaType,
            style: TextStyle(fontSize: dimen.textLarge, color: Colors.white),
          ),
          SizedBox(
            height: dimen.dividerHeightLarge,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () {
                Get.back();
                takePhoto(Parameters.CVideo_);
              },
              label: Text(LabelStr.CVideo,
                  style: TextStyle(
                      fontSize: dimen.textMedium, color: Colors.white)),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.white),
              onPressed: () {
                Get.back();
                takePhoto(Parameters.Cimage);
              },
              label: Text(LabelStr.CImage,
                  style: TextStyle(
                      fontSize: dimen.textMedium, color: Colors.white)),
            ),
          ])
        ],
      ),
    );
  }

  void takePhoto(String selectionType) async {
    if (selectionType == Parameters.CVideo_) {
      var videoFile = (await _picker.pickVideo(source: ImageSource.gallery));

      double size = await Helper().getFileSize(videoFile.path);

      Get.to(VideoEditor(File(videoFile.path))).then((value) async {
        var fileName = await VideoThumbnail.thumbnailFile(
          video: value.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.WEBP,
          quality: 75,
        );

        SelectMediaModel data =
            new SelectMediaModel(value.path.toString(), fileName, size, 0, "");
        rq.pickedMediaList.add(data);
        uploadVideoAws(value as File, -1, (rq.pickedMediaList.length - 1));
        imagePageRefrasher.value = Utilities.getRandomString();
      });
    } else {
      List<XFile> images = await _picker.pickMultiImage();
      for (int i = 0; i < images.length; i++) {
        double size = await Helper().getFileSize(images[i].path);
        SelectMediaModel data =
            SelectMediaModel('', images[i].path, size, 0, "");
        rq.pickedMediaList.add(data);
      }
    }
    imagePageRefrasher.value = Utilities.getRandomString();
  }

  _imageListPager() {
    return Container(
        height: dimen.newPostImageHeight,
        width: double.infinity,
        child: Obx(
          () => Stack(
            children: [
              PageView.builder(
                onPageChanged: (pos) {
                  setState(() {
                    currentPage = pos;
                  });
                },
                restorationId: imagePageRefrasher.value,
                controller: _controller,
                itemCount: rq.pickedMediaList.length,
                itemBuilder: (context, index) {
                  return _ViewPageItem(context, index);
                },
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: new Container(
                  padding: const EdgeInsets.all(dimen.paddingSmall),
                  child: new Center(
                    child: DotsIndicator(
                      controller: _controller,
                      itemCount: rq.pickedMediaList.length,
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
            ],
          ),
        ));
  }

  _ViewPageItem(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(
          left: dimen.paddingVerySmall, right: dimen.paddingVerySmall),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: rq.pickedMediaList[index].path.contains("http")
              ? CommonImage(rq.pickedMediaList[index].path, double.infinity,
                  double.infinity)
              : Image.file(
                  File(rq.pickedMediaList[index].path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.all(dimen.paddingLarge),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                rq.pickedMediaList[index].type != ''
                    ? SizedBox()
                    : InkWell(
                        onTap: (() async {
                          var imageFile =
                              new File(rq.pickedMediaList[index].path);
                          var fileName = basename(imageFile.path);
                          var image = imageLib
                              .decodeImage(await imageFile.readAsBytes());
                          image = imageLib.copyResize(image, width: 600);

                          Get.to(PhotoFilterSelector(
                            index: index,
                            image: image,
                            filters: presetFiltersList,
                            filename: fileName,
                            imgPath: rq.pickedMediaList[index].path,
                            loader: Center(child: CircularProgressIndicator()),
                            fit: BoxFit.contain,
                          )).then((value) => imagePageRefrasher.value =
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
                      rq.removedList.add(rq.pickedMediaList[index].fileId);
                    }
                    rq.pickedMediaList.removeAt(index);
                    imagePageRefrasher.value = Utilities.getRandomString();
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
        rq.pickedMediaList[index].type == ''
            ? SizedBox()
            : Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(dimen.paddingLarge),
                  child: InkWell(
                    onTap: (() async {
                      _pressedOnVideoPlayBtn(
                          context,
                          rq.pickedMediaList[index].type,
                          rq.pickedMediaList[index].path);
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
              )
      ]),
    );
  }

  _pressedOnVideoPlayBtn(
      BuildContext context, String videoURL, String imageUrl) {
    print(videoURL);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                VideoPlayerScreen(videoURL, imageUrl: imageUrl),
            fullscreenDialog: true));
  }
}
