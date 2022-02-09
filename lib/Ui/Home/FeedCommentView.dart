import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FilterBadWord.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/EventCommentModel.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Models/PostCommentModel.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Ui/Customs/CommentSkeleton.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Utility/Impl/helper.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:totem_app/Utility/Impl/global.dart';

class FeedCommentView extends StatefulWidget {
  final int postIndex;

  const FeedCommentView(this.postIndex);

  @override
  _FeedCommentViewState createState() => _FeedCommentViewState();
}

class _FeedCommentViewState extends State<FeedCommentView> {

  void _callGetCommentsApi() {
    var body = {
      Parameters.CpageNumber: 1,
      Parameters.CpageSize: 100,
      Parameters.Csearch: "",
      Parameters.CtotalRecords: 0,
      Parameters.CPostId: rq.homeFeedList[widget.postIndex].postId,
      Parameters.Cid: SessionImpl.getId()
    };
    RequestManager.postRequest(
        uri: endPoints.GetComments,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          rq.postCommentList = List<PostCommentModel>.from(
              response.map((x) => PostCommentModel.fromJson(x)));
          rq.postCommentWidgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {
          rq.postCommentList.clear();
          rq.postCommentWidgetRefresher.value = Utilities.getRandomString();
        });
  }

  _addReply(String reply, int index) {
    var params = {
      Parameters.CReplyID: 0,
      Parameters.CPostCommentId: rq.postCommentList[index].postCommentId,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CReplyBody: reply,
    };
    RequestManager.postRequest(
        uri: endPoints.InsertPostCommentsReply,
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
      replyID: response[Parameters.CReplyID],
      replyBody: response[Parameters.CReplyBody],
      userId: response[Parameters.Cid],
      firstname: user.firstname,
      lastname: user.lastname,
      username: user.username,
      profileVerified: user.profileVerified,
      image: user.image,
      email: user.email,
      phone: user.phone,
    );
    rq.postCommentList[index].replyBody.insert(0, item);
    rq.postCommentWidgetRefresher.value = Utilities.getRandomString();
  }

  _likeOnComment(int index) {
    // var params = {
    //   Parameters.CFeedId: 0,
    //   Parameters.Cid: SessionImpl.getId(),
    //   Parameters.CCommentId: _list[index].commentId,
    //   Parameters.CLike: true,
    // };
    // RequestManager.postRequest(
    //     uri: endPoints.LikeOnEventComments,
    //     body: params,
    //     isFailedMessage: true,
    //     isSuccessMessage: false,
    //     isLoader: false,
    //     onSuccess: (response) {
    //       _list[index].totalLike++;
    //       _list[index].likeStatus = true;
    //       widgetRefresher.value = Utilities.getRandomString();
    //     },
    //     onFailure: () {});
  }

  _deleteComment(int index) {
    var params = {
      Parameters.CPostCommentId: rq.postCommentList[index].postCommentId,
      Parameters.Cid: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.RemoveComments,
        body: params,
        isFailedMessage: true,
        isSuccessMessage: false,
        isLoader: true,
        onSuccess: (response) {

            rq.postCommentList.removeAt(index);
            if (index == 0) {
              if (rq.homeFeedList[widget.postIndex].noOfComments != 0)
                rq.homeFeedList[index].noOfComments--;
              if (rq.postCommentList.length != 0) {
                rq.homeFeedList[widget.postIndex].postComments
                    .insert(0, rq.postCommentList[index]);
              }
              rq.widgetRefresher.value = Utilities.getRandomString();
          }
          rq.postCommentWidgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: () {});
  }

  _deleteReplyComment(int index, commentListIndex) {
    var params = {
      Parameters.CPostReplyCommentId: rq.postCommentList[commentListIndex].replyBody[index].replyID,
      Parameters.Cid: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.RemoveReplyComments,
        body: params,
        isFailedMessage: true,
        isSuccessMessage: false,
        isLoader: true,
        onSuccess: (response) {
          rq.postCommentList[commentListIndex].replyBody.removeAt(index);

          rq.postCommentWidgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: () {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _callGetCommentsApi();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() => rq.postCommentWidgetRefresher.value == ''
          ? _skeletonList()
          : _commentView()),
    );
  }

  _commentView() {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          restorationId: rq.postCommentWidgetRefresher.value,
          itemCount: rq.postCommentList.length,
          itemBuilder: (context, index) {
            return Container(
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
                          imageUrl: rq.postCommentList[index].image,
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
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Widgets.userNameWithIndicator(
                                              OpenProfileNeedDataModel(
                                                  rq.postCommentList[index].id,
                                                  rq.postCommentList[index]
                                                      .firstname +
                                                      " " +
                                                      rq.postCommentList[index]
                                                          .lastname,
                                                  rq.postCommentList[index]
                                                      .username,
                                                  rq.postCommentList[index]
                                                      .profileVerified,
                                                  rq.postCommentList[index].image),
                                              overflow: TextOverflow.ellipsis,
                                              textSize: dimen.textSmall,
                                              fontFamily:
                                                  MyFont.Poppins_semibold,
                                              color: Colors.white)),
                                      SizedBox(
                                        width: dimen.paddingSmall,
                                      ),
                                      Text(
                                        rq.postCommentList[index].totalLike > 0
                                            ? rq.postCommentList[index]
                                                    .totalLike
                                                    .toString() +
                                                " " + LabelStr.lblLikes
                                            : "",
                                        style: TextStyle(
                                            fontFamily: MyFont.poppins_regular,
                                            fontSize: dimen.textNormal,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    rq.postCommentList[index].comment,
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
                                !rq.postCommentList[index].likeStatus
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
                                            style:
                                                TextStyle(color: Colors.grey),
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
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: Container()),
                                rq.homeFeedList[widget.postIndex].id ==
                                            SessionImpl.getId() ||
                                        rq.postCommentList[index].id ==
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
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                            rq.postCommentList[index].replyBody.length > 0
                                ? _childCommentView(rq.postCommentList[index].replyBody, index)
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

  _skeletonList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return CommentSkeleton();
        });
  }

  _childCommentView(List<ReplyBody> replyBody, commentListIndex) {
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
                            rq.homeFeedList[widget.postIndex].id ==
                                        SessionImpl.getId() ||
                                    replyBody[index].userId ==
                                        SessionImpl.getId()
                                ? InkWell(
                                    onTap: () => _deleteReplyComment(index, commentListIndex),
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
            color: roundedcontainer,
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
                      maxLine: 5,
                      maxLength: 500,
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
                        } else
                          _addReply(_commentController.text, index);
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
