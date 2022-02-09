

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FilterBadWord.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/EventCommentModel.dart';
import 'package:totem_app/Models/EventUserModel.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/CustomSlider.dart';
import 'package:totem_app/Ui/Customs/ExpandableText.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/helper.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

const SCALE_FRACTION = 0.7;
const FULL_SCALE = 1.0;
const PAGER_HEIGHT = 220;

class AboutEvent extends StatefulWidget {
  int selectedSegmentOption = 0;

  @override
  _AboutEventState createState() => _AboutEventState();
}

class _AboutEventState extends State<AboutEvent> {
  List<Map<String, String>> pageItemList = [];
  List<UsersEventsComment> _list = [];
  EventCommentModel eventCommentModel = EventCommentModel();
  var onLoadMore = true;
  var dataOver = false;
  var widgetRefresher = "".obs;

  @override
  void initState() {
    super.initState();
    rq.eventDetails.value.eventImages.forEach((element) {
      pageItemList.add({'image': element.downloadlink, 'video': ''});
    });
    eventCommentModel.pageNumber = 0;
    eventCommentModel.pageSize = 50;
    eventCommentModel.totalRecords = 0;
    _callGetCommentsApi();
  }

  _addComment(String comment) {
    var params = {
      Parameters.CCommentID: 0,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CeventId: rq.eventDetails.value.eventId,
      Parameters.CCommentBody: comment,
    };
    RequestManager.postRequest(
        uri: endPoints.addEventComment,
        body: params,
        isFailedMessage: true,
        isSuccessMessage: false,
        isLoader: true,
        onSuccess: (response) {
          _commentController.text = "";
          _addCommentInList(response);
          Get.back();
        },
        onFailure: () {});
  }

  _addCommentInList(dynamic response) {
    UserInfoModel user = SessionImpl.getLoginProfileModel();
    UsersEventsComment item = UsersEventsComment(
        commentId: response['commentID'],
        commentBody: response['commentBody'],
        userId: response['id'],
        username: user.username,
        profileVerified: user.profileVerified,
        firstname: user.firstname,
        lastname: user.lastname,
        image: user.image,
        email: user.email,
        phone: user.phone,
        likeStatus: false,
        totalLike: 0,
        replyBody: []);
    _list.insert(0, item);
    widgetRefresher.value = Utilities.getRandomString();
  }

  _addReply(String reply, int index) {
    var params = {
      Parameters.CReplyID: 0,
      Parameters.CCommentID: _list[index].commentId,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CReplyBody: reply,
    };
    RequestManager.postRequest(
        uri: endPoints.addEventReplyOnComment,
        body: params,
        isFailedMessage: true,
        isSuccessMessage: false,
        isLoader: true,
        onSuccess: (response) {
          _commentController.text = "";
          _addReplyInList(response, index);
          Get.back();
        },
        onFailure: () {});
  }

  _addReplyInList(dynamic response, int index) {
    UserInfoModel user = SessionImpl.getLoginProfileModel();
    ReplyBody item = ReplyBody(
      replyID: response['replyID'],
      replyBody: response['replyBody'],
      userId: response['id'],
      firstname: user.firstname,
      lastname: user.lastname,
      username: user.username,
      profileVerified: user.profileVerified,
      image: user.image,
      email: user.email,
      phone: user.phone,
    );
    _list[index].replyBody.insert(0, item);
    widgetRefresher.value = Utilities.getRandomString();
  }

  _likeOnComment(int index) {
    var params = {
      Parameters.CFeedId: 0,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CCommentId: _list[index].commentId,
      Parameters.CLike: true,
    };
    RequestManager.postRequest(
        uri: endPoints.LikeOnEventComments,
        body: params,
        isFailedMessage: true,
        isSuccessMessage: false,
        isLoader: false,
        onSuccess: (response) {
          _list[index].totalLike++;
          _list[index].likeStatus = true;
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: () {});
  }

  void _callGetCommentsApi() {
    eventCommentModel.pageNumber++;
    var body = {
      Parameters.CpageNumber: eventCommentModel.pageNumber,
      Parameters.CpageSize: eventCommentModel.pageSize,
      Parameters.Csearch: "",
      Parameters.CtotalRecords: eventCommentModel.totalRecords,
      Parameters.CeventId: rq.eventDetails.value.eventId
    };
    RequestManager.postRequest(
        uri: endPoints.getEventComments,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          onLoadMore = false;
          eventCommentModel = EventCommentModel.fromJson(response);
          //check data is over
          if ((eventCommentModel.pageNumber * eventCommentModel.pageSize) <
              eventCommentModel.totalRecords) {
            dataOver = false;
          } else {
            dataOver = true;
          }
          if (eventCommentModel.pageNumber == 1) {
            _list.clear();
          }
          if (eventCommentModel.data[0].usersEventsComments != null &&
              eventCommentModel.data[0].usersEventsComments.isNotEmpty) {
            _list.addAll(eventCommentModel.data[0].usersEventsComments);
            widgetRefresher.value = Utilities.getRandomString();
          }
        },
        onFailure: (error) {
          onLoadMore = false;
          if (eventCommentModel.pageNumber == 1) {
            dataOver = true;
            _list.clear();
            widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  _deleteComment(int index) {

    var params = {
      Parameters.CCommentId: _list[index].commentId,
      Parameters.Cid: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.RemoveEventComments,
        body: params,
        isFailedMessage: true,
        isSuccessMessage: false,
        isLoader: true,
        onSuccess: (response) {
          _list.removeAt(index);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: () {});
  }

  _deleteReplyComment(int index, commentListIndex) {
    var params = {
      Parameters.CPostReplyCommentId:
          _list[commentListIndex].replyBody[index].replyID,
      Parameters.Cid: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.RemoveEventCommentReply,
        body: params,
        isFailedMessage: true,
        isSuccessMessage: false,
        isLoader: true,
        onSuccess: (response) {
          _list[commentListIndex].replyBody.removeAt(index);
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setHeight(20),
                        right: ScreenUtil().setHeight(20),
                        top: dimen.paddingMedium),
                    margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: dimen.paddingVerySmall,
                              top: dimen.paddingSmall),
                          child: Text(
                            LabelStr.lbldetails,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                letterSpacing: 0.44,
                                fontFamily: MyFont.Poppins_medium,
                                fontSize: dimen.textNormal,
                                color: purpleWhiteColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: dimen.marginSmall),
                          child: ExpandableText(
                            rq.eventDetails.value.details,
                            trimLines: 2,
                          ),
                        ),
                        pageItemList.length > 0
                            ? CustomSlider(pageItemList, '')
                            : Container(),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.only(
                    left: dimen.paddingExtraLarge,
                    right: dimen.paddingExtraLarge,
                    top: dimen.paddingLarge),
                child: Text(
                  LabelStr.lblComment,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      letterSpacing: 0.44,
                      fontFamily: MyFont.Poppins_medium,
                      fontSize: dimen.textNormal,
                      color: purpleWhiteColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: dimen.paddingExtraLarge,
                    right: dimen.paddingExtraLarge,
                    top: dimen.paddingSmall),
                child: InkWell(
                  onTap: () {
                    _commentBottomSheet(LabelStr.lblAddComment, -1);
                  },
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: dimen.profileIconHeightSmall,
                          width: dimen.profileIconWidthSmall,
                          child: CommonNetworkImage(
                            imageUrl: (SessionImpl.getLoginProfileModel()
                                    as UserInfoModel)
                                .image,
                            height: 30,
                            width: 30,
                            radius: 15,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: dimen.marginSmall),
                          child: Text(
                            LabelStr.lblAddComment,
                            style: TextStyle(
                                color: dimWhiteTextColor,
                                fontFamily: MyFont.Poppins_medium,
                                fontSize: 12),
                          ),
                        ),
                      ]),
                ),
              ),
              Obx(() =>
                  widgetRefresher.value == '' ? Container() : _CommentView())
            ],
          ),
        ));
  }

  _CommentView() {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          restorationId: widgetRefresher.value,
          physics: NeverScrollableScrollPhysics(),
          itemCount: dataOver ? _list.length : _list.length + 1,
          itemBuilder: (context, index) {
            return index == _list.length
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.only(
                        left: dimen.paddingExtraLarge,
                        right: dimen.paddingExtraLarge,
                        bottom: dimen.paddingSmall,
                        top: dimen.paddingSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(bottom: 1.0),
                              child: CommonNetworkImage(
                                imageUrl: _list[index].image,
                                height: 30,
                                width: 30,
                                radius: 15,
                              ),
                            ),
                            SizedBox(
                              width: dimen.marginSmall,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: dimen.paddingLarge,
                                        vertical: dimen.paddingMedium),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16.0),
                                        ),
                                        color: commentBgColor),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: Widgets
                                                    .userNameWithIndicator(
                                                        OpenProfileNeedDataModel(
                                                            _list[index].userId,
                                                            _list[index]
                                                                    .firstname +
                                                                " " +
                                                                _list[index]
                                                                    .lastname,
                                                            _list[index]
                                                                .username,
                                                            _list[index]
                                                                .profileVerified,
                                                            _list[index].image),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textSize:
                                                            dimen.textSmall,
                                                        fontFamily: MyFont
                                                            .Poppins_semibold,
                                                        color: Colors.white)),
                                            SizedBox(
                                              width: dimen.paddingSmall,
                                            ),
                                            Text(
                                              _list[index].totalLike > 0
                                                  ? _list[index]
                                                          .totalLike
                                                          .toString() +
                                                      (_list[index].totalLike <
                                                              2
                                                          ? " ${LabelStr.lblLike}"
                                                          : " ${LabelStr.lblLikes}")
                                                  : "",
                                              style: TextStyle(
                                                  fontFamily:
                                                      MyFont.poppins_regular,
                                                  fontSize: dimen.textNormal,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          _list[index].commentBody,
                                          style: TextStyle(
                                              fontFamily:
                                                  MyFont.poppins_regular,
                                              fontSize: dimen.textNormal,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _list[index].likeStatus
                                          ? Container()
                                          : InkWell(
                                              onTap: () {
                                                _likeOnComment(index);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: dimen.paddingMedium,
                                                    right: dimen.paddingMedium,
                                                    bottom: dimen.paddingSmall,
                                                    top: dimen.paddingSmall),
                                                child: Text(
                                                  LabelStr.lblLike,
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: dimen.paddingMedium,
                                            right: dimen.paddingMedium,
                                            bottom: dimen.paddingSmall,
                                            top: dimen.paddingSmall),
                                        child: InkWell(
                                          onTap: (() {
                                            _commentBottomSheet(
                                                LabelStr.lblAddReply, index);
                                          }),
                                          child: Text(
                                            LabelStr.lblReply,
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                      rq.eventDetails.value.id ==
                                                  SessionImpl.getId() ||
                                              _list[index].userId ==
                                                  SessionImpl.getId()
                                          ? InkWell(
                                              onTap: () {
                                                _deleteComment(index);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: dimen.paddingMedium,
                                                    right: dimen.paddingMedium,
                                                    bottom: dimen.paddingSmall,
                                                    top: dimen.paddingSmall),
                                                child: Text(
                                                  LabelStr.lbldelete,
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                  _list[index].replyBody.length > 0
                                      ? _ChildCommentView(
                                          _list[index].replyBody, index)
                                      : Container()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
          },
        ));
  }

  _ChildCommentView(List<ReplyBody> replyBody, commentListIndex) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      itemCount: replyBody.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(top: 0.0),
          padding: EdgeInsets.only(
              left: dimen.paddingExtraLarge,
              bottom: dimen.paddingSmall,
              top: dimen.paddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 1.0),
                    child: CommonNetworkImage(
                      imageUrl: replyBody[index].image,
                      height: 30,
                      width: 30,
                      radius: 15,
                    ),
                  ),
                  SizedBox(
                    width: dimen.marginSmall,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: dimen.paddingLarge,
                              vertical: dimen.paddingMedium),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16.0),
                              ),
                              color: commentBgColor),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Widgets.userNameWithIndicator(
                                  OpenProfileNeedDataModel(
                                      replyBody[index].userId,
                                      replyBody[index].firstname +
                                          " " +
                                          replyBody[index].lastname,
                                      replyBody[index].username,
                                      replyBody[index].profileVerified,
                                      replyBody[index].image),
                                  overflow: TextOverflow.ellipsis,
                                  textSize: dimen.textSmall,
                                  fontFamily: MyFont.Poppins_semibold,
                                  color: Colors.white),
                              Text(
                                replyBody[index].replyBody,
                                style: TextStyle(
                                    fontFamily: MyFont.poppins_regular,
                                    fontSize: dimen.textNormal,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(flex: 1, child: Container()),
                            rq.eventDetails.value.id == SessionImpl.getId() ||
                                    replyBody[index].userId ==
                                        SessionImpl.getId()
                                ? InkWell(
                                    onTap: () {
                                      _deleteReplyComment(
                                          index, commentListIndex);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: dimen.paddingMedium,
                                          right: dimen.paddingMedium,
                                          top: dimen.paddingSmall),
                                      child: Text(
                                        LabelStr.lbldelete,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              // _commentList()
            ],
          ),
        );
      },
    );
  }

  var _commentController = TextEditingController();

  //if reply then pass comment index, otherwise -1 for comment
  _commentBottomSheet(String title, int index) {
    return Get.bottomSheet(
        Container(
          constraints: BoxConstraints(maxHeight: Get.height / 1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(38),
              topRight: Radius.circular(38),
            ),
            color: Color.fromRGBO(31, 28, 50, 1),
          ),
          padding: EdgeInsets.only(
            left: dimen.paddingLarge,
            right: dimen.paddingLarge,
            bottom: dimen.paddingLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: dimen.paddingLarge, bottom: dimen.paddingLarge),
                  child: Container(
                    height: 3,
                    width: 100,
                    color: textColorGreyLight,
                  ),
                ),
              ),
              SizedBox(
                height: 26.0,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: textFieldFor(title, _commentController,
                      autocorrect: false,
                      maxLine: 3,
                      maxLength: 255,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.text)),
              SizedBox(
                height: 26.0,
              ),
              Container(
                  child: ButtonRegular(
                      buttonText: LabelStr.lblSend,
                      onPressed: () async {
                        if (FilterBadWord()
                            .isProfane(_commentController.text.trim())) {
                          _commentController.text = await Helper()
                              .badWordAlert(_commentController.text.trim());
                        } else {
                          if (index != -1) {
                            _addReply(_commentController.text, index);
                          } else
                            _addComment(_commentController.text);
                        }
                      })),
              SizedBox(
                height: 26.0,
              ),
            ],
          ),
        ),
        isScrollControlled: true);
  }
}
