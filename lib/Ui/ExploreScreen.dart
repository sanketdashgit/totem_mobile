import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FilterBadWord.dart';
import 'package:totem_app/GeneralUtils/HelperWidgets.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/ExploreMedia.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/helper.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import 'Customs/ButtonRegular.dart';
import 'Home/HomeEvent.dart';
import 'PeopleExplore.dart';
import 'Post/AddNewPost.dart';
import 'Post/PostDetail.dart';
import 'Profile/FollowersScreen.dart';

class ExploreScreen extends StatefulWidget {
  int selectedSegmentOption = 0;

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  var onLoadMore = true;
  var dataOver = false;
  List<Widget> pageList = [
    PeopleExplore(),
    HomeEvent(false, true),
  ];

  var isSearch = false.obs;

  var focusNode = FocusNode();
  var _searchController = TextEditingController();

  int pageNumber = 0;
  int totalRecords = 0;
  var widgetRefresher = "".obs;

  List<ExploreMedia> tempFeedList;

  Intro intro;

  void setupIntro() {
    intro = Intro(
      noAnimation: false,
      maskColor: Colors.black.withAlpha(170),
      stepCount: 1,
      maskClosable: false,
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          IntroMessage.lblIntro1,
        ],
        buttonTextBuilder: (currPage, totalPage) {
          if (currPage < totalPage - 1) {
            return LabelStr.lblNext;
          } else {
            SessionImpl.setIntro4(true);
            return LabelStr.lblNext;
          }
          //return currPage < totalPage - 1 ? 'Next' : 'Next';
        },
      ),
    );
    intro.setStepConfig(0, padding: EdgeInsets.only(left: 0));
  }

  var isIntroDone = false;

  void startIntro4() {
    if (!SessionImpl.getIntro4()) {
      if (!isIntroDone) {
        isIntroDone = true;
        intro.start(context);
      }
    }
  }

  @override
  void initState() {
    setupIntro();
    super.initState();
    if (rq.postMediaLinks.length > 0) {
      widgetRefresher.value = Utilities.getRandomString();
    }
    _callFeedApi();
  }

  void _callFeedApi() {
    pageNumber++;
    var body = {
      Parameters.CpageNumber: pageNumber,
      Parameters.CpageSize: 20,
      Parameters.Csearch: '',
      Parameters.CtotalRecords: totalRecords,
      Parameters.CeventId: 0,
      Parameters.Cid: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.GetExplorePost,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          onLoadMore = false;
          pageNumber = response[Parameters.CpageNumber];
          totalRecords = response[Parameters.CtotalRecords];
          if ((pageNumber * global.PAGE_SIZE) < totalRecords) {
            dataOver = false;
          } else {
            dataOver = true;
          }
          if (pageNumber == 1) {
            rq.postMediaLinks.clear();
            rq.postExtraInfo.clear();
          }
          if ((response[Parameters.CData] as List<dynamic>).isNotEmpty) {
            tempFeedList = List<ExploreMedia>.from(response[Parameters.CData]
                .map((x) => ExploreMedia.fromJson(x)));
            tempFeedList.forEach((element) {
              rq.postMediaLinks.add(element);
              rq.postExtraInfo.add(new OpenProfileNeedDataModel(
                  element.id,
                  element.firstname + element.lastname,
                  element.username,
                  false,
                  ""));
            });
            widgetRefresher.value = Utilities.getRandomString();
          } else {
            if (pageNumber == 1) {
              dataOver = true;
              rq.postMediaLinks.clear();
              rq.postExtraInfo.clear();
              widgetRefresher.value = Utilities.getRandomString();
            }
          }
          startIntro4();
        },
        onFailure: (error) {
          onLoadMore = false;
          if (pageNumber == 1) {
            dataOver = true;
            rq.postMediaLinks.clear();
            rq.postExtraInfo.clear();
            widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  void callRefresh() {
    pageNumber = 0;
    widgetRefresher.value = "";
    _callFeedApi();
  }

  var _commentController = TextEditingController();

  _doCommentBottomSheet(int postId) {
    _commentController.text = "";
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
                  child: textFieldFor("Add Comment...", _commentController,
                      autocorrect: false,
                      maxLine: 5,
                      maxLength: 500,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.text)),
              Container(
                  margin: EdgeInsets.only(top: dimen.marginSmall),
                  child: ButtonRegular(
                      buttonText: "Send",
                      onPressed: () async {
                        if (FilterBadWord()
                            .isProfane(_commentController.text.trim())) {
                          _commentController.text = await Helper()
                              .badWordAlert(_commentController.text.trim());
                        } else
                          Helper().hideKeyBoard();
                        _callAddCommentApi(
                            postId, _commentController.text.trim());
                        Get.back();
                      })),
            ],
          ),
        ),
        isScrollControlled: true);
  }

  void _callAddCommentApi(int postId, String comment) {
    var body = {
      Parameters.CPostCommentId: 0,
      Parameters.CPostId: postId,
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
          Get.back();
          RequestManager.getSnackToast(
              title: LabelStr.lblSent,
              message: Messages.CCommentAdded,
              backgroundColor: Colors.black);
        },
        onFailure: (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
                left: dimen.marginExtraMedium, right: dimen.marginExtraMedium),
            height: 45,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isSearch.value
                    ? InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          isSearch.value = false;
                          _searchController.text = '';
                          rq.isShowFloatBtn.value = true;
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.all(dimen.paddingForBackArrow),
                          child: SvgPicture.asset(MyImage.ic_arrow),
                        ))
                    : SizedBox(
                        width: 1.0,
                      ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(
                        left: isSearch.value
                            ? dimen.marginNormal
                            : dimen.marginVerySmall),
                    decoration: BoxDecoration(
                        color: iconPrimerColor,
                        borderRadius: BorderRadius.circular(23)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 30, left: 10),
                        child: TextField(
                          onTap: () {
                            isSearch.value = true;
                            rq.isShowFloatBtn.value = false;
                          },
                          onChanged: onItemChanged,
                          controller: _searchController,
                          enabled: true,
                          style: TextStyle(color: Colors.white),
                          focusNode: focusNode,
                          cursorColor: Colors.blue,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: LabelStr.lblSearch,
                              hintStyle: TextStyle(
                                  color: colorHintText),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: Get.width * .25),
            child: Container(key: intro.keys[0], width: 0),
          ),
          Expanded(
            flex: 1,
            child: Obx(() => Container(
                margin: EdgeInsets.only(top: dimen.marginMedium),
                child: isSearch.value
                    ? searchResultView()
                    : (widgetRefresher.value == ''
                        ? _exploreSkeletonGrid()
                        : (rq.postMediaLinks.length == 0
                            ? Container(child: dataNotFoundPost())
                            : gridView())))),
          ),
        ],
      ),
    );
  }

  dataNotFoundPost() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              Messages.CFollow,
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
                Get.to(() => FollowersScreen(2)).then((value) => callRefresh());
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
                Get.to(AddNewPost(LabelStr.lblAddPost))
                    .then((value) => callRefresh());
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

  onItemChanged(String value) {
    rq.searchText.value = _searchController.text;
  }

  Widget gridView() {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (!onLoadMore) {
              onLoadMore = true;
              if (!dataOver) {
                _callFeedApi();
              }
            }
          } else {
            if (scrollInfo.metrics.pixels == 0) {
              onLoadMore = false;
            }
          }
          return true;
        },
        child: StaggeredGridView.countBuilder(
          padding: EdgeInsets.only(bottom: dimen.paddingNavigationBar),
          crossAxisCount: 3,
          itemCount: rq.postMediaLinks.length,
          itemBuilder: (BuildContext context, int index) => new Container(
              child: Stack(
            children: [
              Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      Get.to(PostDetail(rq.postMediaLinks[index].postId));
                    },
                    child: CachedNetworkImage(
                        imageUrl: rq.postMediaLinks[index].downloadlink,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url,
                                downloadProgress) =>
                            Image.asset(MyImage.ic_preview, fit: BoxFit.cover),
                        errorWidget: (context, url, error) =>
                            Image.asset(MyImage.ic_preview, fit: BoxFit.cover)),
                  )),
              rq.postMediaLinks[index].videolink == ''
                  ? SizedBox()
                  : Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: (() async {}),
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          radius: 10,
                          child: SvgPicture.asset(
                            MyImage.ic_music,
                            color: Colors.black45,
                            height: 10,
                            width: 10,
                          ),
                        ),
                      ),
                    ),
            ],
          )),
          staggeredTileBuilder: (int index) => StaggeredTile.count(
              index % 10 == 0 ? 2 : 1, index % 10 == 0 ? 2 : 1),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ));
  }

  Widget _exploreSkeletonGrid() {
    return StaggeredGridView.countBuilder(
      padding: EdgeInsets.all(0.0),
      crossAxisCount: 3,
      itemCount: 20,
      itemBuilder: (BuildContext context, int index) => new Container(
          color: Colors.green,
          child: Container(
            color: Colors.grey,
            child: new Center(),
          )),
      staggeredTileBuilder: (int index) =>
          StaggeredTile.count(index % 10 == 0 ? 2 : 1, index % 10 == 0 ? 2 : 1),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  Widget searchResultView() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      sliderSegementView(),
      SizedBox(
        height: dimen.marginMedium,
      ),
      Expanded(
        child: Container(
          child: pageList[widget.selectedSegmentOption],
        ),
      )
    ]);
  }

  Widget sliderSegementView() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border.all(color: HexColor.hintColor, width: 1),
            borderRadius: BorderRadius.circular(8)),
        child: CupertinoSlidingSegmentedControl(
          //backgroundColor: Colors.white,
          thumbColor: tabActiveColor,
          groupValue: widget.selectedSegmentOption,
          children: <int, Widget>{
            0: Text(LabelStr.lblAccounts,
                style: TextStyle(
                  fontFamily: MyFont.Poppins_medium,
                  fontSize: 14,
                  color: (widget.selectedSegmentOption == 0)
                      ? Colors.white
                      : greyLightColor,
                )),
            1: Text(LabelStr.lblEvent,
                style: TextStyle(
                  fontFamily: MyFont.Poppins_medium,
                  fontSize: 14,
                  color: (widget.selectedSegmentOption == 1)
                      ? Colors.white
                      : greyLightColor,
                )),
          },
          onValueChanged: (selectedValue) {
            setState(() {
              widget.selectedSegmentOption = selectedValue as int;
              //pullToRefresh();
            });
          },
        ),
      ),
    );
  }
}
