import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FilterBadWord.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/Utils.dart';
import 'package:totem_app/Models/EventHomeModel.dart';
import 'package:totem_app/Models/EventUserModel.dart';
import 'package:totem_app/Models/FeedListDataModel.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Models/PostCommentModel.dart';
import 'package:totem_app/Ui/Customs/ButtonRegular.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/HomeItemSkeleton.dart';
import 'package:totem_app/Ui/Customs/SimpleSlider.dart';
import 'package:totem_app/Ui/Event/EventDetails.dart';
import 'package:totem_app/Ui/Home/FeedCommentView.dart';
import 'package:totem_app/Ui/Post/AddNewPost.dart';
import 'package:totem_app/Ui/Post/PostEditPrivacy.dart';
import 'package:totem_app/Ui/Profile/FollowersScreen.dart';
import 'package:totem_app/Ui/Profile/OtherUserProfile.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/helper.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeFeed extends StatefulWidget {
  final int getSelf;
  final int id;
  final int eventId;
  final bool isExplore;
  int postId = 0;

  HomeFeed(this.getSelf, this.id, this.eventId, this.isExplore, {this.postId});

  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  var onLoadMore = true;
  var dataOver = false;
  int pageNumber = 0;
  int totalRecords = 0;
  var actionActiveTab = 0.obs;
  int currentPage = 0;
  Timer _timer;
  String _searchText = "";

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    if (widget.postId == null) widget.postId = 0;
    rq.homeFeedList.clear();
    rq.otherFeedList.clear();
    initDelay();
  }

  void initDelay() {
    Future.delayed(
      Duration(milliseconds: 100),
    ).then((value) => {init()});
  }

  void init() {
    rq.widgetRefresher.value = '';
    pageNumber = 0;
    totalRecords = 0;
    _searchText = '';
    if (!widget.isExplore) {
      rq.searchText.value = "";
      _searchText = "";

      if (widget.getSelf == 0 && widget.eventId == 0 && widget.postId == 0) {
        if (rq.homeList.length > 0) {
          _saveDataInList();
        }
      }
    }
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onRefresh() async {
    rq.homeFeedList.clear();
    rq.widgetRefresher.value = '';
    await Future.delayed(Duration(seconds: 1));
    pageNumber = 0;
    totalRecords = 0;
    if (widget.postId == 0) {
      _callFeedListApi();
    } else {
      _callGetPostApi(widget.postId);
    }
  }

  void _onLoading() async {
    await Future.delayed(Duration(seconds: 1));
  }

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (rq.searchText.value != _searchText) {
          _searchText = rq.searchText.value;
          resetFeedSearch();
        }
      },
    );
  }

  resetFeedSearch() {
    if (_searchText.isEmpty) {
      rq.homeFeedList.clear();
      rq.widgetRefresher.value = Utilities.getRandomString();
    } else {
      pageNumber = 0;
      totalRecords = 0;
      if (widget.postId == 0) {
        _callFeedListApi();
      } else {
        _callGetPostApi(widget.postId);
      }
    }
  }

  void _callFeedListApi() {
    pageNumber++;
    var body = {
      Parameters.CpageNumber: pageNumber,
      Parameters.CpageSize: global.PAGE_SIZE,
      Parameters.Csearch: _searchText,
      Parameters.CtotalRecords: totalRecords,
      Parameters.CeventId: widget.eventId,
      Parameters.Cid: widget.id,
      Parameters.CGetSelf: widget.getSelf,
    };
    RequestManager.postRequest(
        uri: endPoints.GetFeedList,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          onLoadMore = false;
          pageNumber = response[Parameters.CpageNumber];
          totalRecords = response[Parameters.CtotalRecords];
          if ((response[Parameters.CData] as List<dynamic>).isNotEmpty) {
            _refreshController.loadComplete();
            _refreshController.refreshCompleted();
            if ((pageNumber * global.PAGE_SIZE) < totalRecords) {
              dataOver = false;
            } else {
              dataOver = true;
            }
            if (pageNumber == 1) {
              if (widget.getSelf == 1 ||
                  widget.eventId != 0 ||
                  widget.postId != 0) {
                rq.otherFeedList.clear();
              } else
                rq.homeList.clear();
            }
            var temp = List<FeedListDataModel>.from(
                response[Parameters.CData].map((x) => FeedListDataModel.fromJson(x)));
            if (widget.getSelf == 1 ||
                widget.eventId != 0 ||
                widget.postId != 0) {
              rq.otherFeedList.addAll(temp);
            } else {
              rq.homeList.addAll(temp);
            }

            var adModel = FeedListDataModel();
            adModel.postId = 0;
            if (widget.getSelf == 1 ||
                widget.eventId != 0 ||
                widget.postId != 0)
              rq.otherFeedList.add(adModel);
            else
              rq.homeList.add(adModel);
            _saveDataInList();
          } else {
            if (pageNumber == 1) {
              dataOver = true;
              if (widget.getSelf == 1 ||
                  widget.eventId != 0 ||
                  widget.postId != 0) {
                rq.otherFeedList.clear();
              } else
                rq.homeList.clear();
              rq.homeFeedList.clear();
              rq.widgetRefresher.value = Utilities.getRandomString();
            }
          }
          if (pageNumber == 1) {
            setState(() {});
          }
        },
        onFailure: (error) {
          onLoadMore = false;
          if (pageNumber == 1) {
            dataOver = true;
            if (widget.getSelf == 1 ||
                widget.eventId != 0 ||
                widget.postId != 0) {
              rq.otherFeedList.clear();
            } else
              rq.homeList.clear();
            rq.homeFeedList.clear();
            rq.widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  void _callGetPostApi(int postId) {
    var body = {
      Parameters.CPostId: postId,
    };
    RequestManager.postRequest(
        uri: endPoints.GetPostbyPostId,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          var model = FeedListDataModel.fromJson(response);
          dataOver = true;
          onLoadMore = false;
          rq.otherFeedList.clear();
          rq.otherFeedList.add(model);
          _saveDataInList();
        },
        onFailure: (error) {});
  }

  void _callPostLikeApi(int likeIndex, int postIndex) {
    var likeStatus = true;
    if (likeIndex == 1 && rq.homeFeedList[postIndex].selfLiked != 0) {
      likeStatus = false;
      likeIndex = 0;
    }
    var body = {
      Parameters.CPostId: rq.homeFeedList[postIndex].postId,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CLikeStatus: likeStatus,
      Parameters.CLikeType: likeIndex,
    };
    RequestManager.postRequest(
        uri: endPoints.likepost,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          rq.homeFeedList[postIndex].noOfLikes = response[Parameters.CTotalLikes];
          rq.homeFeedList[postIndex].selfLiked = response[Parameters.CSelfLiked];
          rq.homeFeedList[postIndex].actionActiveTab = -1;
          rq.widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callDeletePostApi(int index) {
    var body = {
      Parameters.CPostId: rq.homeFeedList[index].postId,
      Parameters.Cid: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.deletepost,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        isFailedMessage: false,
        onSuccess: (response) {
          rq.homeFeedList.removeAt(index);
          rq.widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callAddCommentApi(int index, String comment, bool goBack) {
    var body = {
      Parameters.CPostCommentId: 0,
      Parameters.CPostId: rq.homeFeedList[index].postId,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CComment: comment,
    };
    RequestManager.postRequest(
        uri: endPoints.addComment,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          _commentController.text = "";
          var item = PostCommentModel.fromJson(response);
          if (goBack) {
            Get.back();
            RequestManager.getSnackToast(
                title: LabelStr.lblSent,
                message: Messages.CCommentAdded,
                backgroundColor: Colors.black);
          } else {
            rq.postCommentList.insert(0, item);
            rq.postCommentWidgetRefresher.value = Utilities.getRandomString();
          }
          rq.homeFeedList[index].noOfComments++;
          rq.homeFeedList[index].postComments.insert(0, item);
          rq.widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callReportApi(int index, String reason) {
    var body = {
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CblockId: 0,
      Parameters.CPostUserId: rq.homeFeedList[index].id,
      Parameters.CPostId: rq.homeFeedList[index].postId,
      Parameters.CReason: reason,
    };
    RequestManager.postRequest(
        uri: endPoints.reportOnPost,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          _reportController.text = "";
          Get.back();
          RequestManager.getSnackToast(
              title: LabelStr.lblReport,
              message: Messages.CReporting,
              backgroundColor: Colors.black);

          rq.homeFeedList.removeAt(index);
          rq.widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _callPostUserList(int postId) {
    var body = {
      Parameters.CpageNumber: 1,
      Parameters.CpageSize: 1000,
      Parameters.Csearch: '',
      Parameters.CtotalRecords: 0,
      Parameters.CPostId: postId,
      Parameters.Cid: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.GetpostLikesUsers,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          var _userList = List<EventUserModel>.from(
              response[Parameters.CData].map((x) => EventUserModel.fromJson(x)));
          Widgets.usersBottomSheet(list: _userList);
        },
        onFailure: (error) {});
  }

  void _saveDataInList() {
    rq.homeFeedList.clear();
    if (widget.getSelf == 1 || widget.eventId != 0 || widget.postId != 0) {
      rq.homeFeedList.addAll(rq.otherFeedList);
    } else {
      rq.homeFeedList.addAll(rq.homeList);
    }
    rq.widgetRefresher.value = Utilities.getRandomString();
  }

  _callEventDetails(Map<String, dynamic> params, bool isLoader) {
    RequestManager.postRequest(
        uri: endPoints.getByEventID,
        body: params,
        isLoader: isLoader,
        isSuccessMessage: false,
        onSuccess: (response) {
          rq.eventDetails.value = EventHomeModel.fromJson(response);
          if (rq.eventDetails.value.eventImages.length != 0) {
            for (int i = 0; i < rq.eventDetails.value.eventImages.length; i++) {
              if (rq.eventDetails.value.eventImages[i].fileType == 'Cover')
                rq.coverUrl.value =
                    rq.eventDetails.value.eventImages[i].downloadlink;
              if (rq.eventDetails.value.eventImages[i].fileType == 'Map')
                rq.mapUrl.value =
                    rq.eventDetails.value.eventImages[i].downloadlink;
              if (rq.eventDetails.value.eventImages[i].fileType == 'Headliners')
                rq.lineupUrl.value =
                    rq.eventDetails.value.eventImages[i].downloadlink;
            }
          }
          Get.to(EventDetails(-1));
        },
        onFailure: () {});
  }

  var isKeyBoardAction = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor,
        body: VisibilityDetector(
          key: Key(LabelStr.lblHomeFeed),
          onVisibilityChanged: (VisibilityInfo info) {
            if (WidgetsBinding.instance.window.viewInsets.bottom > 0.0) {
              isKeyBoardAction = true;
            } else {
              if (isKeyBoardAction == false) {
                if (info.visibleFraction == 0) {
                  rq.flickMultiManager.pause();
                } else {
                  rq.flickMultiManager.play();
                  if (widget.postId == 0) {
                    rq.homeFeedList.clear();
                    rq.widgetRefresher.value = '';
                    if (widget.getSelf == 1 ||
                        widget.eventId != 0 ||
                        widget.postId != 0) {
                      //call api for new data
                      if (widget.postId == 0) {
                        _callFeedListApi();
                      } else {
                        _callGetPostApi(widget.postId);
                      }
                    } else {
                      rq.homeFeedList.addAll(rq.homeList);
                      if (rq.homeFeedList.length > 0) {
                        rq.widgetRefresher.value = Utilities.getRandomString();
                      } else {
                        pageNumber = 0;
                        _callFeedListApi();
                      }
                    }
                  } else {
                    if (rq.homeFeedList.length != 1) {
                      _callGetPostApi(widget.postId);
                    } else {
                      if (rq.homeFeedList[0].postId != widget.postId) {
                        _callGetPostApi(widget.postId);
                      }
                    }
                  }
                }
              }
              isKeyBoardAction = false;
            }
          },
          child: Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(20),
                      bottom: ScreenUtil().setHeight(10)),
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0)),
                      color: containerColor),
                  child: Center(
                    child: SvgPicture.asset(MyImage.ic_line),
                  )),
              // _FeedList(),
              Expanded(
                  flex: 1,
                  child: Obx(() => rq.widgetRefresher.value == ''
                      ? (widget.isExplore
                          ? Container(
                              color: containerColor,
                              height: double.infinity,
                              width: double.infinity,
                            )
                          : _homeSkeletonList())
                      : rq.homeFeedList.length == 0
                          ? Container(
                              color: containerColor,
                              child: dataNotFoundPost())
                          : _feedList()))
            ],
          ),
        ));
  }

  static dataNotFoundPost() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              Messages.CFollowPost,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: MyFont.Poppins_medium,
                  color: buttonPrimary),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.to(() => FollowersScreen(2));
              },
              child: Container(
                width: 75,
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    shape: BoxShape.rectangle,
                    color: darkBlue,
                    border: Border.all(color: HexColor.borderColor)),
                child: Text(
                  LabelStr.lblFollow,
                  style: TextStyle(
                      fontFamily: MyFont.Poppins_medium,
                      fontSize: 12,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              Messages.CPostCreate,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: MyFont.Poppins_medium,
                  color: buttonPrimary),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Get.to(AddNewPost(LabelStr.lblAddPost));
              },
              child: Container(
                width: 100,
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    shape: BoxShape.rectangle,
                    color: darkBlue,
                    border: Border.all(color: HexColor.borderColor)),
                child: Text(
                  LabelStr.lblCreatePost_,
                  style: TextStyle(
                      fontFamily: MyFont.Poppins_medium,
                      fontSize: 12,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _homeSkeletonList() {
    return Container(
      padding: EdgeInsets.only(top: dimen.paddingMedium),
      color: containerColor,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return HomeItemSkeleton();
          }),
    );
  }

  _adView() {
    return NativeAd(
      height: 300,
      unitId: Helper.getAdId(),
      builder: (context, child) {
        return Material(
          elevation: 8,
          child: child,
        );
      },
      buildLayout: fullBuilder,
      loading: Text(LabelStr.lblLoading),
      error: Text(LabelStr.lblError),
      icon: AdImageView(size: 40),
      headline: AdTextView(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        maxLines: 1,
      ),
      media: AdMediaView(
        height: 180,
        width: MATCH_PARENT,
        elevation: 6,
        elevationColor: Colors.deepPurpleAccent,
      ),
      attribution: AdTextView(
        width: WRAP_CONTENT,
        height: WRAP_CONTENT,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        margin: EdgeInsets.only(right: 4),
        maxLines: 1,
        decoration: AdDecoration(
          borderRadius: AdBorderRadius.all(10),
          border: BorderSide(color: Colors.green, width: 1),
        ),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      button: AdButtonView(
        elevation: 18,
        elevationColor: Colors.amber,
        height: MATCH_PARENT,
      ),
      ratingBar: AdRatingBarView(starsColor: Colors.white),
    );
  }

  AdLayoutBuilder get fullBuilder => (ratingBar, media, icon, headline,
          advertiser, body, price, store, attribuition, button) {
        return AdLinearLayout(
          padding: EdgeInsets.all(10),
          width: MATCH_PARENT,
          decoration: AdDecoration(
              gradient: AdLinearGradient(
            colors: [Colors.indigo[300], Colors.indigo[700]],
            orientation: AdGradientOrientation.tl_br,
          )),
          children: [
            media,
            AdLinearLayout(
              children: [
                icon,
                AdLinearLayout(children: [
                  headline,
                  AdLinearLayout(
                    children: [attribuition, advertiser, ratingBar],
                    orientation: HORIZONTAL,
                    width: MATCH_PARENT,
                  ),
                ], margin: EdgeInsets.only(left: 4)),
              ],
              gravity: LayoutGravity.center_horizontal,
              width: WRAP_CONTENT,
              orientation: HORIZONTAL,
              margin: EdgeInsets.only(top: 6),
            ),
            AdLinearLayout(
              children: [button],
              orientation: HORIZONTAL,
            ),
          ],
        );
      };

  _feedList() {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (!onLoadMore) {
              onLoadMore = true;
              if (!dataOver) {
                if (widget.postId == 0) {
                  _callFeedListApi();
                } else {
                  _callGetPostApi(widget.postId);
                }
              }
            }
          } else {
            if (scrollInfo.metrics.pixels == 0) {
              onLoadMore = false;
            }
          }
          return true;
        },
        child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            header: WaterDropHeader(),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: dimen.paddingNavigationBar),
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: dataOver
                  ? rq.homeFeedList.length
                  : rq.homeFeedList.length + 1,
              restorationId: rq.widgetRefresher.value,
              itemBuilder: (context, index) {
                return index == rq.homeFeedList.length
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                          ),
                        ),
                      )
                    : (rq.homeFeedList[index].postId == 0)
                        ? _adView()
                        : Wrap(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: containerColor,
                                ),
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setHeight(20),
                                    right: ScreenUtil().setHeight(20),
                                    top: ScreenUtil().setHeight(13),
                                    bottom: ScreenUtil().setHeight(13)),
                                margin: EdgeInsets.only(
                                    bottom: ScreenUtil().setHeight(20)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        CommonNetworkImage(
                                          imageUrl:
                                              rq.homeFeedList[index].image,
                                          height: 40,
                                          width: 40,
                                          radius: 20,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Widgets.userNameWithIndicator(
                                                    OpenProfileNeedDataModel(
                                                        rq.homeFeedList[index]
                                                            .id,
                                                        rq.homeFeedList[index]
                                                                .firstname +
                                                            " " +
                                                            rq
                                                                .homeFeedList[
                                                                    index]
                                                                .lastname,
                                                        rq.homeFeedList[index]
                                                            .username,
                                                        rq.homeFeedList[index]
                                                            .profileVerified,
                                                        rq.homeFeedList[index]
                                                            .image),
                                                    textSize: 14.0),
                                                Text(
                                                  "${daysBetween(rq.homeFeedList[index].createdDate)}",
                                                  style: TextStyle(
                                                      fontFamily: MyFont
                                                          .poppins_regular,
                                                      fontSize: 12,
                                                      color:
                                                          HexColor.textColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        PopupMenuButton(
                                            icon: SvgPicture.asset(
                                              MyImage.ic_addedit,
                                              color: whiteTextColor,
                                              height: 16,
                                            ),
                                            color: popupMenuBcgColor,
                                            elevation: 30,
                                            shape: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: popupMenuBorderColor,
                                                    width: 1)),
                                            itemBuilder: (context) => rq
                                                        .homeFeedList[index]
                                                        .id !=
                                                    SessionImpl.getId()
                                                ? [
                                                    PopupMenuItem(
                                                      height: 35,
                                                      child: InkWell(
                                                        onTap: () {
                                                          Get.back();
                                                          _reportBottomSheet(
                                                              index);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              MyImage.ic_report,
                                                              color:
                                                                  dimWhiteTextColor,
                                                              height: 20,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .only(
                                                                  left: dimen
                                                                      .paddingSmall),
                                                              child: Text(
                                                                LabelStr.lblReport,
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      whiteTextColor,
                                                                  fontSize: dimen
                                                                      .textSmall,
                                                                  fontFamily: MyFont
                                                                      .poppins_regular,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      value: 1,
                                                    )
                                                  ]
                                                : [
                                                    PopupMenuItem(
                                                      height: 35,
                                                      child: InkWell(
                                                        onTap: () {
                                                          Get.back();
                                                          Get.to(
                                                                  AddNewPost(
                                                                      LabelStr
                                                                          .lblEditPost),
                                                                  arguments:
                                                                      rq.homeFeedList[
                                                                          index])
                                                              .then((value) => rq
                                                                      .widgetRefresher
                                                                      .value =
                                                                  Utilities
                                                                      .getRandomString());
                                                        },
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              MyImage.ic_edit,
                                                              color:
                                                                  dimWhiteTextColor,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .only(
                                                                  left: dimen
                                                                      .paddingSmall),
                                                              child: Text(
                                                                LabelStr.lblEdit,
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      whiteTextColor,
                                                                  fontSize: dimen
                                                                      .textSmall,
                                                                  fontFamily: MyFont
                                                                      .poppins_regular,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      value: 1,
                                                    ),
                                                    PopupMenuItem(
                                                      height: 35,
                                                      child: InkWell(
                                                        onTap: () {
                                                          showAlertDialog(
                                                              context, index);
                                                        },
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SvgPicture.asset(
                                                              MyImage.ic_delete,
                                                              color:
                                                                  dimWhiteTextColor,
                                                              height: 16,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .only(
                                                                  left: dimen
                                                                      .paddingSmall),
                                                              child: Text(
                                                                LabelStr.lbldelete,
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      whiteTextColor,
                                                                  fontSize: dimen
                                                                      .textSmall,
                                                                  fontFamily: MyFont
                                                                      .poppins_regular,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      value: 2,
                                                    ),
                                                    PopupMenuItem(
                                                      height: 35,
                                                      child: InkWell(
                                                        onTap: () {
                                                          Get.back();
                                                          Get.to(PostEditPrivacy(
                                                                  rq
                                                                      .homeFeedList[
                                                                          index]
                                                                      .postId,
                                                                  rq
                                                                      .homeFeedList[
                                                                          index]
                                                                      .isPrivate))
                                                              .then((value) => rq
                                                                  .homeFeedList[
                                                                      index]
                                                                  .isPrivate = value);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              MyImage
                                                                  .ic_popup_lock,
                                                              color:
                                                                  dimWhiteTextColor,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .only(
                                                                  left: dimen
                                                                      .paddingSmall),
                                                              child: Text(
                                                                LabelStr.lblEditPrivacy,
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      whiteTextColor,
                                                                  fontSize: dimen
                                                                      .textSmall,
                                                                  fontFamily: MyFont
                                                                      .poppins_regular,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      value: 3,
                                                    ),
                                                  ])
                                      ],
                                    ),
                                    rq.homeFeedList[index].postMediaLinks
                                                .length >
                                            0
                                        ? SimpleSlider(
                                            _getSliderArray(rq
                                                .homeFeedList[index]
                                                .postMediaLinks),
                                            rq.widgetRefresher.value,
                                            new OpenProfileNeedDataModel(
                                                rq.homeFeedList[index].id,
                                                rq.homeFeedList[index]
                                                        .firstname +
                                                    rq.homeFeedList[index]
                                                        .lastname,
                                                rq.homeFeedList[index].username,
                                                rq.homeFeedList[index]
                                                    .profileVerified,
                                                rq.homeFeedList[index].image))
                                        : Container(),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          bottom: dimen.marginSmall * 0.75),
                                      child: RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        textAlign: TextAlign.start,
                                        text: new TextSpan(
                                          children: <TextSpan>[
                                            new TextSpan(
                                              text: rq
                                                  .homeFeedList[index].caption,
                                              style: TextStyle(
                                                  height: 1.5,
                                                  fontSize: 14,
                                                  color: whiteTextColor
                                                      .withOpacity(0.8)),
                                            ),
                                            new TextSpan(
                                              text: " " +
                                                  rq.homeFeedList[index]
                                                      .eventName,
                                              style: TextStyle(
                                                  height: 1.5,
                                                  fontSize: 14,
                                                  color: Colors.cyan
                                                      .withOpacity(0.8)),
                                              recognizer:
                                                  new TapGestureRecognizer()
                                                    ..onTap = () {
                                                      if (rq.homeFeedList[index]
                                                              .eventisActive !=
                                                          3) {
                                                        _callEventDetails({
                                                          Parameters.CUserId:
                                                              SessionImpl
                                                                  .getId(),
                                                          Parameters.CeventId:
                                                              rq
                                                                  .homeFeedList[
                                                                      index]
                                                                  .eventId
                                                        }, false);
                                                      }
                                                    },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    rq.homeFeedList[index].tagUsers.length == 0
                                        ? Container()
                                        : tagPeopleView(index),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        rq.homeFeedList[index].noOfLikes > 0
                                            ? (rq.homeFeedList[index]
                                                                .noOfLikes -
                                                            1 ==
                                                        0 &&
                                                    rq.homeFeedList[index]
                                                            .selfLiked >
                                                        1
                                                ? Container()
                                                : Container(
                                                    height: 20,
                                                    width: 20,
                                                    margin: EdgeInsets.only(
                                                      top: dimen
                                                          .paddingVerySmall,
                                                    ),
                                                    child: InkWell(
                                                      onTap: (() => {}),
                                                      child: CircleAvatar(
                                                        backgroundColor: whiteColor,
                                                        child: Image.asset(
                                                          MyImage.ic_like,
                                                          height: 13,
                                                          width: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                            : Container(),
                                        rq.homeFeedList[index].selfLiked > 1
                                            ? Container(
                                                height: 20,
                                                width: 20,
                                                margin: EdgeInsets.only(
                                                  left: dimen.paddingVerySmall,
                                                  top: dimen.paddingVerySmall,
                                                ),
                                                child: InkWell(
                                                  onTap: () {},
                                                  child: CircleAvatar(
                                                    backgroundColor: whiteColor,
                                                    child: Image.asset(
                                                      Widgets.getLikeUrl(rq
                                                          .homeFeedList[index]
                                                          .selfLiked),
                                                      height: 13,
                                                      width: 13,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: dimen.paddingVerySmall,
                                              top: dimen.paddingVerySmall,
                                            ),
                                            child: InkWell(
                                              onTap: (() => {
                                                    if (rq.homeFeedList[index]
                                                            .noOfLikes >
                                                        0)
                                                      _callPostUserList(rq
                                                          .homeFeedList[index]
                                                          .postId)
                                                  }),
                                              child: Text(
                                                rq.homeFeedList[index]
                                                            .selfLiked !=
                                                        0
                                                    ? (rq.homeFeedList[index]
                                                                    .noOfLikes -
                                                                1 ==
                                                            0
                                                        ? ""
                                                        : LabelStr.lblYouAnd+" ${rq.homeFeedList[index].noOfLikes - 1} more")
                                                    : (rq.homeFeedList[index]
                                                                .noOfLikes ==
                                                            0
                                                        ? LabelStr.lblNoLikes
                                                        : (rq.homeFeedList[index]
                                                                    .noOfLikes)
                                                                .toString() +
                                                            " "+LabelStr.lblMore),
                                                style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: dividerLineColordark,
                                    ),
                                    SizedBox(
                                      height: dimen.marginVerySmall,
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 36,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            shape: BoxShape.rectangle,
                                            color:
                                                Color.fromRGBO(64, 59, 89, 1),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: (() => {}),
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    left: dimen.paddingMedium,
                                                    right: dimen.paddingMedium),
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                  color: rq.homeFeedList[index]
                                                              .actionActiveTab ==
                                                          0
                                                      ? feedListActionTabColor
                                                      : Colors.transparent,
                                                ),
                                                child: Center(
                                                    child: _likeButton(index)),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: (() => {
                                                    rq.homeFeedList[index]
                                                        .actionActiveTab = 1,
                                                    rq.widgetRefresher.value =
                                                        Utilities
                                                            .getRandomString(),
                                                    _doCommentBottomSheet(index)
                                                  }),
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    left: dimen.paddingMedium,
                                                    right: dimen.paddingMedium),
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                  color: rq.homeFeedList[index]
                                                              .actionActiveTab ==
                                                          1
                                                      ? feedListActionTabColor
                                                      : Colors.transparent,
                                                ),
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        MyImage
                                                            .ic_comment_outline,
                                                        color: Colors.white,
                                                        height: 12,
                                                        width: 12,
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets.only(
                                                              left: dimen
                                                                  .paddingVerySmall)),
                                                      Text(LabelStr.lblComment,
                                                          style: TextStyle(
                                                              fontSize: dimen
                                                                  .textSmall,
                                                              fontFamily: MyFont
                                                                  .Poppins_medium,
                                                              color:
                                                                  whiteTextColor))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                rq.homeFeedList[index]
                                                    .actionActiveTab = 2;
                                                rq.widgetRefresher.value =
                                                    Utilities.getRandomString();
                                                String shareUrl = await Utils
                                                    .createFirstPostLink(
                                                        rq.homeFeedList[index]
                                                            .postId,
                                                        rq
                                                                    .homeFeedList[
                                                                        index]
                                                                    .postMediaLinks
                                                                    .length >
                                                                0
                                                            ? rq
                                                                .homeFeedList[
                                                                    index]
                                                                .postMediaLinks[
                                                                    0]
                                                                .downloadlink
                                                            : '',
                                                        Messages.CPostCheck,
                                                        ShareType.CSharePost);
                                                share(shareUrl);
                                                Future.delayed(
                                                        Duration(seconds: 2))
                                                    .then((value) => {
                                                          rq.homeFeedList[index]
                                                              .actionActiveTab = -1,
                                                          rq.widgetRefresher
                                                                  .value =
                                                              Utilities
                                                                  .getRandomString()
                                                        });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    left: dimen.paddingMedium,
                                                    right: dimen.paddingMedium),
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  shape: BoxShape.rectangle,
                                                  color: rq.homeFeedList[index]
                                                              .actionActiveTab ==
                                                          2
                                                      ? feedListActionTabColor
                                                      : Colors.transparent,
                                                ),
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        MyImage
                                                            .ic_share_outline,
                                                        color: Colors.white,
                                                        height: 12,
                                                        width: 12,
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets.only(
                                                              left: dimen
                                                                  .paddingVerySmall)),
                                                      Text(LabelStr.lblShare,
                                                          style: TextStyle(
                                                              fontSize: dimen
                                                                  .textSmall,
                                                              fontFamily: MyFont
                                                                  .Poppins_medium,
                                                              color:
                                                                  whiteTextColor))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: dimen.dividerHeightSmall,
                                    ),
                                    rq.homeFeedList[index].postComments
                                                .length ==
                                            0
                                        ? Container()
                                        : lastUserComments(index)
                                  ],
                                ),
                              )
                            ],
                          );
              },
            )));
  }

  Widget lastUserComments(index) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(
                top: dimen.paddingVerySmall, bottom: dimen.paddingVerySmall),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              text: new TextSpan(
                style: new TextStyle(
                    height: 1.5,
                    fontSize: dimen.textSmall,
                    color: whiteTextColor.withOpacity(0.5)),
                children: <TextSpan>[
                  new TextSpan(
                      text: rq.homeFeedList[index].postComments[0].username,
                      style: new TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: dimen.textNormal,
                          color: whiteTextColor.withOpacity(0.9))),
                  new TextSpan(
                    text: " " + rq.homeFeedList[index].postComments[0].comment,
                  ),
                ],
              ),
            ),
          ),
        ),
        rq.homeFeedList[index].noOfComments < 2
            ? Container()
            : Container(
                padding: EdgeInsets.only(left: dimen.paddingSmall),
                child: InkWell(
                  onTap: (() => {
                        if (rq.homeFeedList[index].noOfComments > 0)
                          viewCommentBottomSheet(index)
                      }),
                  child: Text(
                    " View All ${rq.homeFeedList[index].noOfComments} Comments",
                    style: TextStyle(
                      fontFamily: MyFont.Poppins_medium,
                      fontSize: 12,
                      color: Color.fromRGBO(255, 255, 255, 0.4),
                    ),
                  ),
                )),
      ],
    );
  }

  Widget tagUserImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 24,
        width: 24,
        color: screenBgLightColor,
        padding: EdgeInsets.all(3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.fill,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Image.asset(MyImage.ic_dummy_profile,
                      fit: BoxFit.fill),
              errorWidget: (context, url, error) => Image.asset(
                  MyImage.ic_dummy_profile,
                  fit: BoxFit.fill)),
        ),
      ),
    );
  }

  Widget tagPeopleView(index) {
    return Row(
      children: [
        RichText(
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.justify,
          text: new TextSpan(
            children: [
              new TextSpan(
                text: rq.homeFeedList[index].username,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: MyFont.Poppins_semibold,
                    color: whiteTextColor.withOpacity(0.9)),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () {
                    Get.to(OtherUserProfile(
                        rq.homeFeedList[index].id,
                        rq.homeFeedList[index].firstname,
                        rq.homeFeedList[index].username,
                        rq.homeFeedList[index].profileVerified,
                        rq.homeFeedList[index].image));
                  },
              ),
              new TextSpan(
                text: " with ",
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: MyFont.poppins_regular,
                    color: whiteTextColor.withOpacity(0.8)),
              ),
            ],
          ),
        ),
        Container(
            width: 100,
            height: 24,
            child: InkWell(
              onTap: () => _openTaggedPeople(index),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child:
                        tagUserImage(rq.homeFeedList[index].tagUsers[0].image),
                  ),
                  rq.homeFeedList[index].tagUsers.length > 1
                      ? Positioned(
                          left: 16,
                          top: 0,
                          child: tagUserImage(
                              rq.homeFeedList[index].tagUsers[1].image),
                        )
                      : Container(),
                  rq.homeFeedList[index].tagUsers.length > 2
                      ? Positioned(
                          left: 32,
                          top: 0,
                          child: tagUserImage(
                              rq.homeFeedList[index].tagUsers[2].image),
                        )
                      : Container(),
                  rq.homeFeedList[index].tagUsers.length > 3
                      ? Positioned(
                          left: 48,
                          top: 0,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: whiteTextColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 4, color: screenBgLightColor)),
                              child: Icon(
                                Icons.add,
                                size: 20,
                                color: Colors.cyan,
                              )),
                        )
                      : Container()
                ],
              ),
            ))
      ],
    );
  }

  void _openTaggedPeople(int index) {
    List<EventUserModel> _userList = [];
    rq.homeFeedList[index].tagUsers.forEach((element) {
      _userList.add(EventUserModel(
          id: element.id,
          firstname: element.firstname,
          lastname: element.lastname,
          username: element.username,
          image: element.image,
          profileVerified: element.profileVerified,
          selfLiked: 0));
    });
    Widgets.usersBottomSheet(list: _userList);
  }

  List<Map<String, String>> _getSliderArray(
      List<PostMediaLink> postMediaLinks) {
    List<Map<String, String>> sliderList = [];
    postMediaLinks.forEach((element) {
      sliderList
          .add({Parameters.Cimage: element.downloadlink, LabelStr.CVideo: element.videolink});
    });
    return sliderList;
  }

  Future<void> share(String shareUrl) async {
    await FlutterShare.share(
        title: LabelStr.lblTotemShare,
        text: LabelStr.lblTotem,
        linkUrl: shareUrl.toString(),
        chooserTitle: LabelStr.lblChoose);
  }

  _likeButton(int postIndex) {
    return FlutterReactionButtonCheck(
      onReactionChanged: (reaction, index, isChecked) {
        if (index != -1) {
          _callPostLikeApi(index + 1, postIndex);
        } else {
          _callPostLikeApi(index + 2, postIndex);
          rq.homeFeedList[postIndex].actionActiveTab = 0;
          rq.widgetRefresher.value = Utilities.getRandomString();
        }
      },
      reactions: reactions,
      initialReaction: Reaction(
        previewIcon: Widgets.selectedIcon(
            Widgets.getLikeUrl(rq.homeFeedList[postIndex].selfLiked),
            Widgets.getLikeStatus(rq.homeFeedList[postIndex].selfLiked)),
        icon: Widgets.selectedIcon(
            Widgets.getLikeUrl(rq.homeFeedList[postIndex].selfLiked),
            Widgets.getLikeStatus(rq.homeFeedList[postIndex].selfLiked)),
      ),
      selectedReaction: Reaction(
        previewIcon: Widgets.selectedIcon(
            Widgets.getLikeUrl(rq.homeFeedList[postIndex].selfLiked),
            Widgets.getLikeStatus(rq.homeFeedList[postIndex].selfLiked)),
        icon: Widgets.selectedIcon(
            Widgets.getLikeUrl(rq.homeFeedList[postIndex].selfLiked),
            Widgets.getLikeStatus(rq.homeFeedList[postIndex].selfLiked)),
      ),
    );
  }

  showAlertDialog(BuildContext context, int index) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(LabelStr.lblCancel),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: Text(LabelStr.lbldelete),
      onPressed: () {
        Get.back();
        Get.back();
        _callDeletePostApi(index);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(LabelStr.lblDelete_),
      content: Text(Messages.CDeletePost),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  var _commentController = TextEditingController();
  var _reportController = TextEditingController();

  _doCommentBottomSheet(int postIndex) {
    _commentController.text = "";
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
                bottom: dimen.paddingBigLarge,
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
                      child: textFieldFor(LabelStr.lblAddComment, _commentController,
                          autocorrect: false,
                          maxLine: 5,
                          maxLength: 500,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.text)),
                  Container(
                      margin: EdgeInsets.only(top: dimen.marginSmall),
                      child: ButtonRegular(
                          buttonText: LabelStr.lblSend,
                          onPressed: () async {
                            if (FilterBadWord()
                                .isProfane(_commentController.text.trim())) {
                              _commentController.text = await Helper()
                                  .badWordAlert(_commentController.text.trim());
                            } else
                              Helper().hideKeyBoard();
                            _callAddCommentApi(postIndex,
                                _commentController.text.trim(), true);
                            Get.back();
                          })),
                ],
              ),
            ),
            isScrollControlled: true)
        .then((value) => {
              rq.homeFeedList[postIndex].actionActiveTab = -1,
              rq.widgetRefresher.value = Utilities.getRandomString()
            });
  }

  _reportBottomSheet(int postIndex) {
    _reportController.text = '';
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
            bottom: dimen.paddingBigLarge,
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
              // SizedBox(
              //   height: 26.0,
              // ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: dimen.marginLarge),
                  width: MediaQuery.of(context).size.width,
                  child: textFieldFor(
                      Messages.CReport, _reportController,
                      autocorrect: false,
                      maxLine: 5,
                      maxLength: 500,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.text)),
              Container(
                  child: ButtonRegular(
                      buttonText: LabelStr.lblReport,
                      onPressed: () {
                        _callReportApi(
                            postIndex, _commentController.text.trim());
                      })),
            ],
          ),
        ),
        isScrollControlled: true);
  }

  final reactions = [
    Reaction(
      previewIcon: Widgets.buildReactionsPreviewIcon(Widgets.getLikeUrl(1)),
      icon:
          Widgets.selectedIcon(Widgets.getLikeUrl(1), Widgets.getLikeStatus(1)),
    ),
    Reaction(
      previewIcon: Widgets.buildReactionsPreviewIcon(Widgets.getLikeUrl(2)),
      icon:
          Widgets.selectedIcon(Widgets.getLikeUrl(2), Widgets.getLikeStatus(2)),
    ),
    Reaction(
      previewIcon: Widgets.buildReactionsPreviewIcon(Widgets.getLikeUrl(3)),
      icon:
          Widgets.selectedIcon(Widgets.getLikeUrl(3), Widgets.getLikeStatus(3)),
    ),
    Reaction(
      previewIcon: Widgets.buildReactionsPreviewIcon(Widgets.getLikeUrl(4)),
      icon:
          Widgets.selectedIcon(Widgets.getLikeUrl(4), Widgets.getLikeStatus(4)),
    ),
  ];

  viewCommentBottomSheet(int postIndex) {
    return Get.bottomSheet(
        Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
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
              Expanded(flex: 1, child: FeedCommentView(postIndex)),
              Column(
                children: [
                  Container(
                    height: 1,
                    color: Color.fromRGBO(81, 80, 106, 1),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: dimen.paddingVerySmall,
                        right: dimen.paddingVerySmall,
                        top: ScreenUtil().setHeight(15.0)),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            textAlignVertical: TextAlignVertical.center,
                            maxLines: 5,
                            minLines: 1,
                            maxLength: 250,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(14),
                                fontFamily: MyFont.poppins_regular,
                                color: colorChatText),
                            decoration: InputDecoration(
                              isDense: true,
                              counterText: '',
                              hintText: LabelStr.lblAdComment,
                              hintStyle: TextStyle(
                                  fontSize: ScreenUtil().setSp(14),
                                  fontFamily: MyFont.poppins_regular,
                                  color: colorChatText),
                              fillColor: Color.fromRGBO(60, 58, 92, 1),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            if (FilterBadWord()
                                .isProfane(_commentController.text.trim())) {
                              _commentController.text = await Helper()
                                  .badWordAlert(_commentController.text.trim());
                            } else
                              Helper().hideKeyBoard();
                            _callAddCommentApi(postIndex,
                                _commentController.text.trim(), false);

                            // _callAddCommentApi(postIndex,
                            //     _commentController.text.trim(), false);
                          },
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: SvgPicture.asset(MyImage.ic_send)),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        isScrollControlled: true);
  }

  Future<String> getThumbNailFromUrl(String url) async {
    return await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      quality: 75,
    );
  }

  String daysBetween(String crDate) {
    var stringList = crDate.split(new RegExp(r"[T\.]"));
    var formatedDate = "${stringList[0]} ${stringList[1]}";
    DateTime fromUtc =
        DateFormat("yyyy-MM-dd HH:mm:ss").parse(formatedDate, true);
    DateTime to = DateTime.now();
    DateTime from = fromUtc.toLocal();
    var diff = (to.difference(from).inMinutes);
    var timeAgo = diff.toString() + " minutes ago";
    if (diff > (24 * 60) * 2) {
      timeAgo = to.difference(from).inDays.toString() + " days ago";
    } else if (diff > 24 * 60) {
      timeAgo = to.difference(from).inDays.toString() + " day ago";
    } else if (diff > 120) {
      timeAgo = to.difference(from).inHours.toString() + " hours ago";
    } else if (diff > 60) {
      timeAgo = to.difference(from).inHours.toString() + " hour ago";
    } else if (diff == 0) {
      timeAgo = "now";
    }
    return timeAgo;
  }
}
