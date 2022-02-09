import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FirestoreService.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';
import 'package:totem_app/Models/EventHomeModel.dart';
import 'package:totem_app/Models/FeedListDataModel.dart';
import 'package:totem_app/Models/GetfollowerCountModel.dart';
import 'package:totem_app/Models/IntrestSaveModel.dart';
import 'package:totem_app/Models/MemoriesModel.dart';
import 'package:totem_app/Models/SongTotemModel.dart';
import 'package:totem_app/Ui/Chat/ChatDetailScreen.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/ExpandableText.dart';
import 'package:totem_app/Ui/Customs/SpotifyPreviewPlayer.dart';
import 'package:totem_app/Ui/Post/AddNewPost.dart';
import 'package:totem_app/Ui/Post/PostDetail.dart';
import 'package:totem_app/Ui/Profile/CreateProfile.dart';
import 'package:totem_app/Ui/Profile/FollowersScreen.dart';
import 'package:totem_app/Ui/Profile/IntersetScreen.dart';
import 'package:totem_app/Ui/Profile/MemoriesDetail.dart';
import 'package:totem_app/Ui/Profile/OtherUserFollowers.dart';
import 'package:totem_app/Ui/Profile/OtherUserFollowing.dart';
import 'package:totem_app/Ui/Profile/PostListing.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProfileScreen extends StatefulWidget {
  int selectedSegmentOption = 0;
  int id;

  ProfileScreen(this.id, {Key key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  int activeTabIndex = 0;
  Rx<GetfollowerCountModel> countModel = GetfollowerCountModel().obs;
  var widgetRefresherTracks = "".obs;

  TabController _tabController;
  var isFollow = 0.obs;
  var conversationID = '';
  RxInt pageSelectOption = 0.obs;

  List<FeedListDataModel> _list = [];
  var widgetRefresher = ''.obs;

  List<MemoriesModel> _listMemories = [];
  var widgetRefresherMemories = ''.obs;
  var rotationTitle = ''.obs;

  int currentPage = 0;
  PageController _controller;
  int doubleTimeCounter = 2; //default 2 for track and 1 for others

  List<Map<String, dynamic>> rotationList = [];

  Intro intro;

  void setupIntro() {
    List<String> texts = [];
    if(rq.selectedTracks.isNotEmpty) {
      texts.add(IntroMessage.lblIntro11);
    }
    texts.add(IntroMessage.lblIntro12);
    intro = Intro(
      noAnimation: false,
      maskColor: Colors.black.withAlpha(170),
      stepCount: rq.selectedTracks.isNotEmpty ? 2 : 1,
      maskClosable: false,
      onHighlightWidgetTap: (introStatus){
        if(introStatus.currentStepIndex == texts.length - 1){
          changeTab(1);
          intro.dispose();
        }
      },
      widgetBuilder: StepWidgetBuilder.useAdvancedTheme(
        widgetBuilder: (params) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.6),
            ),
            child: Column(
              children: [
                Text(
                  texts[params.currentStepIndex],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
                params.currentStepIndex == params.stepCount - 1 ? Container() : OutlinedButton(
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
                    if(params.currentStepIndex < params.stepCount - 1){
                      params.onNext();
                    }else{
                      params.onFinish();
                      SessionImpl.setIntro2(true);
                      //changeTab(1);
                    }
                  },
                  child: Text(
                   LabelStr.lblNext,
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
  }

  Intro intro2;

  void setupIntro2() {
    List<String> texts = [
      '',
    ];
    intro2 = Intro(
      noAnimation: false,
      maskColor: Colors.black.withAlpha(170),
      stepCount: 1,
      maskClosable: false,
      onHighlightWidgetTap: (IntroStatus introStatus){
        SessionImpl.setIntro3(true);
        Get.to(AddNewPost(LabelStr.lblAddMemories));
        intro2.dispose();
      },
      widgetBuilder: StepWidgetBuilder.useAdvancedTheme(
        widgetBuilder: (params) {
          return Text(
            texts[params.currentStepIndex],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.4,
              color: Colors.white,
            ),
          );
        },
      ),
    );
    intro2.setStepConfig(0, padding: EdgeInsets.only(bottom: 200));
  }

  @override
  void initState() {
    setupIntro();
    setupIntro2();
    super.initState();
    _tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
    );
    rotationList.clear();
    rotationTitle.value = LabelStr.lblTopSongs;
    _tabController.addListener(() {
      setState(() {
        activeTabIndex = _tabController.index;
      });
    });
    //check if login user profile
    if (SessionImpl.getId() == widget.id){
      countModel.value.profileDetails = SessionImpl.getLoginProfileModel();
      countModel.value.isfollow = 1;
      countModel.value.postCount = 0;
      countModel.value.following = 0;
      countModel.value.followers = 0;
      _getFollowerCount(
          {Parameters.CUserId: SessionImpl.getId(), Parameters.Cid: widget.id},
          false);
    }else {
      _getFollowerCount(
          {Parameters.CUserId: SessionImpl.getId(), Parameters.Cid: widget.id},
          true);
    }

    _sizes.addAll(_sizeSample);
    if (SessionImpl.getId() != widget.id) {
      FirestoreService().checkConversationIDExistOrNot(widget.id,
          (snapshot, error) {
        conversationID = snapshot;
      });
    }
    _controller =
        PageController(initialPage: currentPage, viewportFraction: 0.88);
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (currentPage < rotationList.length) {
        if (doubleTimeCounter - 1 == 0) {
          //change page and assign new value to counter
          currentPage++;
          if (rotationList[currentPage]['type'] == 'track') {
            doubleTimeCounter = 2;
          } else
            doubleTimeCounter = 1;
        } else {
          doubleTimeCounter--;
        }
      } else {
        currentPage = 0;
        if (rotationList[currentPage]['type'] == 'track') {
          doubleTimeCounter = 2;
        } else
          doubleTimeCounter = 1;
      }

      _updateRotationTitle(currentPage);

      _controller.animateToPage(
        currentPage,
        duration: Duration(
            milliseconds:
                rotationList[currentPage]['type'] == 'track' ? 1000 : 350),
        curve: Curves.easeIn,
      );
    });
  }

  _getFollowerCount(Map<String, dynamic> params, bool isLoader) {
    RequestManager.postRequest(
        uri: endPoints.GetfollowerCount,
        body: params,
        isLoader: isLoader,
        isSuccessMessage: false,
        onSuccess: (response) {
          countModel.value = GetfollowerCountModel.fromJson(response);
          isFollow.value = countModel.value.isfollow;
          _updateCurrentUserData();
          if (SessionImpl.getId() == widget.id ||
              !countModel.value.profileDetails.isPrivate ||
              (countModel.value.profileDetails.isPrivate &&
                  countModel.value.isfollow == 1)) {
            //for own songs
            _getTrackApiCall();
            _loadPostData();
            if (pageSelectOption.value == 1) _loadMemoriesData(false);
          }
        },
        onFailure: () {});
  }

  void _getSpotifyApiCall() {
    var body = {Parameters.Cid: widget.id};
    RequestManager.postRequest(
        uri: endPoints.getSpotify,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        onSuccess: (response) {
          InterestGetModel model = InterestGetModel.fromJson(response);
          List<String> genres = [];
          model.genres.forEach((element) {
            genres.add(element.name);
          });
          rq.selectedGener = genres;
          rq.selectedArtist = model.artists;
          rq.selectedEvents = model.favouriteEvents;
          _callNextEventsApi();
        },
        onFailure: (error) {
          _callNextEventsApi();
        });
  }

  void _callNextEventsApi() {
    var body = {
      Parameters.CpageNumber: 1,
      Parameters.CpageSize: 50,
      Parameters.Csearch: '',
      Parameters.CtotalRecords: 0,
      Parameters.CeventId: 0,
      Parameters.CUserId: widget.id,
    };
    RequestManager.postRequest(
        uri: endPoints.getNextEvent,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          rq.nextEvents = List<EventHomeModel>.from(
              response['data'].map((x) => EventHomeModel.fromJson(x)));
          generateRotation();
        },
        onFailure: (error) {
          generateRotation();
        });
  }

  void generateRotation() {
    int counter = 0;
    rotationList.clear();
    rq.selectedTracks.forEach((element) {
      rotationList.add({
        "index": counter,
        "dataIndex": rq.selectedTracks.indexOf(element),
        "type": 'track'
      });
      counter++;
    });
    //if track list is empty then no need to assign 2 to counter.
    if (rq.selectedTracks.length == 0)
      doubleTimeCounter = 1;
    else
      doubleTimeCounter = 2;

    rq.selectedGener.forEach((element) {
      rotationList.add({
        "index": counter,
        "dataIndex": rq.selectedGener.indexOf(element),
        "type": 'geners'
      });
      counter++;
    });

    rq.selectedArtist.forEach((element) {
      rotationList.add({
        "index": counter,
        "dataIndex": rq.selectedArtist.indexOf(element),
        "type": 'artist'
      });
      counter++;
    });

    rq.selectedEvents.forEach((element) {
      rotationList.add({
        "index": counter,
        "dataIndex": rq.selectedEvents.indexOf(element),
        "type": 'event'
      });
      counter++;
    });

    rq.nextEvents.forEach((element) {
      rotationList.add({
        "index": counter,
        "dataIndex": rq.nextEvents.indexOf(element),
        "type": 'nextEvent'
      });
      counter++;
    });
    widgetRefresherTracks.value = Utilities.getRandomString();
    //startIntro();
  }

  var isIntroDone = false;

  void startIntro() {
    if (!SessionImpl.getIntro2()) {
      if (!isIntroDone) {
        isIntroDone = true;
        intro.start(context);
      }
    }
  }

  void _getTrackApiCall() {
    var body = {Parameters.Cid: widget.id};
    RequestManager.postRequest(
        uri: endPoints.getFavSongs,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          rq.selectedTracks = List<SongTotemModel>.from(
              response.map((x) => SongTotemModel.fromJson(x)));
          _getSpotifyApiCall();
        },
        onFailure: (error) {
          _getSpotifyApiCall();
        });
  }

  _updateCurrentUserData() {
    if (SessionImpl.getId() == widget.id) {
      SessionImpl.setLoginProfileModel(countModel.value.profileDetails);
    }
  }

  void _callFollowApi() {
    var body = {
      Parameters.CuserIdSmall: SessionImpl.getId(),
      Parameters.CFollowerId: widget.id
    };
    RequestManager.postRequest(
        uri: endPoints.follow,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          if (isFollow.value == 0) {
            if (countModel.value.profileDetails.isPrivate)
              isFollow.value = 2;
            else
              isFollow.value = 1;
          } else if (isFollow.value == 2) isFollow.value = 0;
        },
        onFailure: (error) {});
  }

  void _loadPostData() {
    var body = {Parameters.Cid: widget.id};
    RequestManager.postRequest(
        uri: endPoints.GetUsersPost,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          _list.clear();
          var temp = List<FeedListDataModel>.from(
              response.map((x) => FeedListDataModel.fromJson(x)));
          _list.addAll(temp);
          generateSizeArray();
          postListLength.value = _list.length;
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {
          _list.clear();
          widgetRefresher.value = Utilities.getRandomString();
        });
  }

  void generateSizeArray() {
    int counter = (_list.length / 6).ceil();
    _sizes.clear();
    for (var i = 0; i < counter; i++) {
      _sizes.addAll(_sizeSample);
    }
  }

  void generateSizeArrayMemories() {
    int counter = (_listMemories.length / 6).ceil();
    _sizesMemories.clear();
    for (var i = 0; i < counter; i++) {
      _sizesMemories.addAll(_sizeSampleMemories);
    }
  }

  List<String> _sizes = [];
  List<String> _sizesMemories = [];

  final List<String> _sizeSample = ["2,1", "1,2", "1,1", "1,2", "1,1", "1,1"];
  final List<String> _sizeSampleMemories = [
    "1,2",
    "2,1",
    "1,2",
    "1,1",
    "1,1",
    "1,1"
  ];

  void _loadMemoriesData(bool isLoader) {
    var body = {
      Parameters.CpageNumber: 1,
      Parameters.CpageSize: 100,
      Parameters.Csearch: '',
      Parameters.CtotalRecords: 0,
      Parameters.Cid: widget.id,
    };
    RequestManager.postRequest(
        uri: endPoints.GetUserMemories,
        body: body,
        isLoader: isLoader,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          _listMemories.clear();
          if (SessionImpl.getId() == widget.id) {
            _listMemories.add(null); //for add new button
          }
          var temp = List<MemoriesModel>.from(
              response['data'].map((x) => MemoriesModel.fromJson(x)));
          temp.forEach((element) {
            if (element.memorieMediaLinks.isNotEmpty)
              _listMemories.add(element);
          });
          generateSizeArrayMemories();
          memoriesListLength.value = _listMemories.length;
          widgetRefresherMemories.value = Utilities.getRandomString();
          startIntro2();
        },
        onFailure: (error) {
          _listMemories.clear();
          if (SessionImpl.getId() != widget.id) {
            _listMemories.add(null);
          }
          generateSizeArrayMemories();
          memoriesListLength.value = _listMemories.length;
          widgetRefresherMemories.value = Utilities.getRandomString();
          startIntro2();
        });
  }

  var isIntro2Done = false;

  void startIntro2() {
    if (!SessionImpl.getIntro3()) {
      if (!isIntro2Done) {
        isIntro2Done = true;
        intro2.start(context);
      }
    }
  }

  void checkRotationOnResume() {
    if (widgetRefresherTracks.value.isNotEmpty) {
      if (rotationList.length !=
          (rq.selectedTracks.length +
              rq.selectedGener.length +
              rq.selectedArtist.length +
              rq.selectedEvents.length +
              rq.nextEvents.length)) {
        //call again for reload data
        rotationList.clear();
        widgetRefresherTracks.value = Utilities.getRandomString();
        if (SessionImpl.getId() == widget.id ||
            !countModel.value.profileDetails.isPrivate ||
            (countModel.value.profileDetails.isPrivate &&
                countModel.value.isfollow == 1)) {
          //for own songs
          _getTrackApiCall();
          _loadPostData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: VisibilityDetector(
        key: Key("profile_screen"),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction == 1) {
            checkRotationOnResume();
            _getFollowerCount({
              Parameters.CUserId: SessionImpl.getId(),
              Parameters.Cid: widget.id
            }, false);
          }
        },
        child: Container(
          child: Obx(() => countModel.value.profileDetails == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(
                      left: dimen.paddingExtraLarge,
                      right: dimen.paddingExtraLarge),
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            _sliveBodyView(),
                          ],
                        ),
                      ),
                      _bottomView(),
                      _bottomSpaceView()
                    ],
                  ),
                )),
        ),
      ),
    );
  }

  _bottomView() {
    return Container(
      //key: intro2.keys[0],
      child: Obx(() => countModel.value.profileDetails.isPrivate &&
              isFollow.value != 1
          ? (countModel.value.profileDetails.id == SessionImpl.getId()
              ? pageSelectOption.value == 0
                  ? (widgetRefresher.value == ''
                      ? _postViewDummy()
                      : _postView())
                  : (widgetRefresherMemories.value == ''
                      ? _postViewDummyMemories()
                      : _memoriesView())
              : _bottomSpaceView())
          : pageSelectOption.value == 0
              ? (widgetRefresher.value == '' ? _postViewDummy() : _postView())
              : (widgetRefresherMemories.value == ''
                  ? _postViewDummyMemories()
                  : _memoriesView())),
    );
  }

  _sliveBodyView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: Color.fromRGBO(62, 192, 197, 1),
                  )),
              margin: EdgeInsets.only(
                top: 10,
              ),
              child: CommonNetworkImage(
                height: 70,
                width: 70,
                radius: 35,
                imageUrl: countModel.value.profileDetails.image,
              ),
            ),
            Expanded(
              flex: 1,
              child: _countView(),
            )
          ],
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: dimen.marginSmall),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 1.0),
                child: Text(
                  countModel.value.profileDetails.firstname +
                      " " +
                      countModel.value.profileDetails.lastname,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: MyFont.Poppins_medium,
                      color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: ExpandableText(
                  countModel.value.profileDetails.bio,
                  trimLines: 3,
                ),
              ),
            ],
          ),
        ),
        _buttonView(),
        Obx(() =>
            countModel.value.profileDetails.isPrivate && isFollow.value != 1
                ? (countModel.value.profileDetails.id == SessionImpl.getId()
                    ? _publicView()
                    : _privateView())
                : _publicView()),
      ],
    );
  }

  _countView() {
    return Padding(
        padding: EdgeInsets.only(
          top: dimen.paddingVerySmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  if (SessionImpl.getId() == widget.id ||
                      !countModel.value.profileDetails.isPrivate ||
                      (countModel.value.profileDetails.isPrivate &&
                          countModel.value.isfollow == 1)) {
                    if (countModel.value.postCount > 0)
                      Get.to(PostListing(
                          1,
                          countModel.value.profileDetails.firstname +
                              " " +
                              countModel.value.profileDetails.lastname,
                          countModel.value.profileDetails.id,
                          0));
                  }
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      countModel.value.postCount.toString(),
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: MyFont.Poppins_semibold,
                          color: Colors.white),
                    ),
                    Text(
                      LabelStr.lblPosts,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: MyFont.Poppins_medium,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1.0,
              height: 45.0,
              color: Colors.blueGrey,
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  if (widget.id == SessionImpl.getId()) {
                    Get.to(FollowersScreen(0));
                  } else if (!countModel.value.profileDetails.isPrivate ||
                      (countModel.value.profileDetails.isPrivate &&
                          countModel.value.isfollow == 1)) {
                    Get.to(OtherUserFollowers(widget.id));
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      countModel.value.followers.toString(),
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: MyFont.Poppins_semibold,
                          color: Colors.white),
                    ),
                    Text(
                      LabelStr.lblFollowers,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: MyFont.Poppins_medium,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1.0,
              height: 45.0,
              color: Colors.blueGrey,
            ),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  if (widget.id == SessionImpl.getId()) {
                    Get.to(FollowersScreen(1));
                  } else if (!countModel.value.profileDetails.isPrivate ||
                      (countModel.value.profileDetails.isPrivate &&
                          countModel.value.isfollow == 1)) {
                    Get.to(OtherUserFollowing(widget.id));
                  }
                },
                child: Column(
                  children: <Widget>[
                    Text(
                      countModel.value.following.toString(),
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: MyFont.Poppins_semibold,
                          color: Colors.white),
                    ),
                    Text(
                      LabelStr.lblFollowing,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: MyFont.Poppins_medium,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  _buttonView() {
    return widget.id != SessionImpl.getId()
        ? Container(
            padding: EdgeInsets.symmetric(vertical: dimen.paddingExtraLarge),
            child: Obx(() => isFollow.value == 1
                ? InkWell(
                    onTap: () {
                      Get.to(ChatDetailScreen(conversationID, {
                        Parameters.CUserId: countModel.value.profileDetails.id,
                        Parameters.CuserName:
                            countModel.value.profileDetails.username,
                        Parameters.CUserProfile:
                            countModel.value.profileDetails.image,
                        Parameters.CFirstName:
                            countModel.value.profileDetails.firstname,
                        Parameters.CLastName:
                            countModel.value.profileDetails.lastname,
                      })).then(
                          (conversationId) => conversationID = conversationId);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: HexColor.borderColor,
                          )),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            LabelStr.lblMessage,
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: MyFont.Poppins_medium,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                : isFollow.value == 0
                    ? InkWell(
                        onTap: () {
                          _callFollowApi();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: HexColor.borderColor,
                              )),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                LabelStr.lblFollow,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: MyFont.Poppins_medium,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          _callFollowApi();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: HexColor.borderColor,
                              )),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                LabelStr.lblRequested,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: MyFont.Poppins_medium,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )))
        : InkWell(
            onTap: () {
              rq.selectedEvents = [];
              rq.selectedArtist = [];
              rq.selectedGener = [];
              rq.selectedTracks = [];
              Get.to(CreateProfile(
                isEdit: true,
              ));
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: dimen.paddingExtraLarge),
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: HexColor.borderColor,
                  )),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: MyFont.Poppins_medium,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          );
  }

  _publicView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          height: 4.0,
          color: HexColor("#3C456C"),
        ),
        Column(
          key: intro.keys[0],
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                children: <Widget>[
                  rotationTitle.value == LabelStr.lblTopSongs
                      ? SvgPicture.asset(
                          MyImage.ic_spotify,
                          height: 30,
                          width: 30,
                        )
                      : Container(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        rotationTitle.value,
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: MyFont.Poppins_semibold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      onTap: () {
                        Get.to(IntersetScreen(widget.id));
                      },
                      child: Text(
                        LabelStr.lblSeeAll,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: MyFont.Poppins_medium,
                            color: HexColor("#3EC0C5")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 70,
              padding: EdgeInsets.only(top: 10),
              // child: _favoritelist(),
              child: _favoriteSongsList(),
            ),
          ],
        ),
        postAndMemoriesSegmentView(),
        Container(key: intro2.keys[0], width: Get.width * 0.3)
      ],
    );
  }

  _privateView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: dimen.paddingExtraLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 35,
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: HexColor.borderColor, width: 2.0)),
              child: SvgPicture.asset(
                MyImage.ic_lock,
                height: 18,
                width: 18,
              )),
          SizedBox(
            width: dimen.paddingMedium,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LabelStr.lblThisAccountPrivate,
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: MyFont.Poppins_semibold,
                    color: Colors.white),
              ),
              Text(
                LabelStr.lblFollowAccount,
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: MyFont.Poppins_medium,
                    color: Colors.white60),
              ),
            ],
          ))
        ],
      ),
    );
  }

  _favoriteSongsList() {
    return Obx(() => PageView.builder(
          itemCount: rotationList.length,
          scrollDirection: Axis.horizontal,
          controller: _controller,
          restorationId: widgetRefresherTracks.value,
          itemBuilder: (context, index) {
            return Container(
                width: ScreenUtil().screenWidth * 0.80,
                margin: EdgeInsets.only(right: dimen.paddingExtraLarge),
                child: _getPagerItem(index));
          },
          // ),
        ));
  }

  _updateRotationTitle(int index) {
    if (rotationList[index]['type'] == "track")
      rotationTitle.value = LabelStr.lblTopSongs;
    else if (rotationList[index]['type'] == "geners")
      rotationTitle.value = LabelStr.lblFavoriteGenres;
    else if (rotationList[index]['type'] == "artist")
      rotationTitle.value = LabelStr.lblArtists;
    else if (rotationList[index]['type'] == "event")
      rotationTitle.value = LabelStr.lblEvents;
    else if (rotationList[index]['type'] == "nextEvent")
      rotationTitle.value = LabelStr.lblNextEvents;
  }

  _getPagerItem(int index) {
    switch (rotationList[index]['type']) {
      case "track":
        return _trackItem(rotationList[index]['dataIndex']);
      case "geners":
        return _genersItem(rotationList[index]['dataIndex']);
      case "artist":
        return _artistItem(rotationList[index]['dataIndex']);
      case "event":
        return _eventItem(rq.selectedEvents[rotationList[index]['dataIndex']]);
      case "nextEvent":
        return _eventItem(rq.nextEvents[rotationList[index]['dataIndex']]);
    }
    return Container();
  }

  _trackItem(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CommonNetworkImage(
            height: 50,
            width: 50,
            radius: 25,
            imageUrl: rq.selectedTracks[index].image),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rq.selectedTracks[index].trackName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: MyFont.poppins_regular,
                      color: Colors.white),
                ),
                Text(
                  rq.selectedTracks[index].albumName +
                      " " +
                      (rq.selectedTracks[index].artistName.isNotEmpty
                          ? "(" + rq.selectedTracks[index].artistName + ")"
                          : ""),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      fontFamily: MyFont.poppins_regular,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: InkWell(
            onTap: () {
              _openSongPreview(index);
              //_launchURL(rq.selectedTracks[index].songlink);
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconPrimerColor,
                  border: Border.all(color: HexColor.borderColor)),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(MyImage.ic_music)),
            ),
          ),
        ),
      ],
    );
  }

  _genersItem(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: Container(
              height: 50.0,
              width: 50.0,
              color: purpleTextColor,
              child: Center(
                child: Text(rq.selectedGener[index][0].toUpperCase(),
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: MyFont.Poppins_semibold,
                        color: Colors.white)),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              rq.selectedGener[index].capitalizeFirst,
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: MyFont.poppins_regular,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  _artistItem(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CommonNetworkImage(
          height: 50,
          width: 50,
          radius: 25,
          imageUrl: rq.selectedArtist[index].image,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              rq.selectedArtist[index].name,
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: MyFont.poppins_regular,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  _eventItem(EventHomeModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CommonNetworkImage(
          height: 50,
          width: 50,
          radius: 25,
          imageUrl: data.eventImages.length > 0
              ? data.eventImages[0].downloadlink
              : "",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.eventName.toTitleCase(),
                  style: TextStyle(
                      fontSize: 12,
                      fontFamily: MyFont.poppins_regular,
                      color: Colors.white),
                ),
                Text(
                  data.address,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      fontFamily: MyFont.poppins_regular,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  var postListLength = 0.obs;

  _postView() {
    return _list.length > 0
        ? SliverStaggeredGrid.countBuilder(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            staggeredTileBuilder: (int index) => StaggeredTile.count(
                int.parse(_sizes[index].split(",")[0]),
                double.parse(_sizes[index].split(",")[1])),
            itemBuilder: _getChild,
            itemCount: postListLength.value,
          )
        : SliverStaggeredGrid.count(
            crossAxisCount: 1,
            staggeredTiles: _staggeredTiles,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [Widgets.dataNotFound()],
          );
  }

  List<StaggeredTile> _staggeredTiles = <StaggeredTile>[
    StaggeredTile.count(1, 1),
  ];

  var memoriesListLength = 0.obs;

  _memoriesView() {
    return _listMemories.length > 0
        ? SliverStaggeredGrid.countBuilder(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            staggeredTileBuilder: (int index) => StaggeredTile.count(
                int.parse(_sizesMemories[index].split(",")[0]),
                double.parse(_sizesMemories[index].split(",")[1])),
            itemBuilder: _getChildMemories,
            itemCount: memoriesListLength.value,
          )
        : SliverStaggeredGrid.count(
            crossAxisCount: 1,
            staggeredTiles: _staggeredTiles,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [Widgets.dataNotFound()],
          );
  }

  _postViewDummy() {
    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      staggeredTileBuilder: (int index) => StaggeredTile.count(
          int.parse(_sizeSample[index].split(",")[0]),
          double.parse(_sizeSample[index].split(",")[1])),
      itemBuilder: _getChildDummy,
      itemCount: _sizeSample.length,
    );
  }

  _postViewDummyMemories() {
    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      staggeredTileBuilder: (int index) => StaggeredTile.count(
          int.parse(_sizeSampleMemories[index].split(",")[0]),
          double.parse(_sizeSampleMemories[index].split(",")[1])),
      itemBuilder: _getChildDummy,
      itemCount: _sizeSampleMemories.length,
    );
  }

  _bottomSpaceView() {
    return SliverStaggeredGrid.count(
      crossAxisCount: 1,
      staggeredTiles: _staggeredTiles,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: [_getPaddingView()],
    );
  }

  Widget _getChildDummy(BuildContext context, int index) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: textColorGreyLight,
    );
  }

  Widget _getPaddingView() {
    return Container(
      height: 10,
    );
  }

  Widget _getChild(BuildContext context, int index) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: InkWell(
        onTap: () {
          Get.to(PostDetail(_list[index].postId));
        },
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              child: CachedNetworkImage(
                  imageUrl: _list.length > 0
                      ? (_list[index].postMediaLinks.length != 0
                          ? _list[index].postMediaLinks[0].downloadlink
                          : '')
                      : '',
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Image.asset(MyImage.ic_preview, fit: BoxFit.cover),
                  errorWidget: (context, url, error) =>
                      Image.asset(MyImage.ic_preview, fit: BoxFit.cover)),
            ),
            _list[index].id == SessionImpl.getId()
                ? Container()
                : widget.id != SessionImpl.getId()
                    ? Container()
                    : Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            // 10% of the width, so there are ten blinds.
                            colors: <Color>[
                              Colors.black54,
                              Color(0x11000000)
                            ], // red to yellow
                            // tileMode: TileMode.repeated,
                          )),
                          padding: const EdgeInsets.only(
                              left: dimen.paddingSmall,
                              right: dimen.paddingSmall,
                              top: dimen.paddingSmall,
                              bottom: dimen.paddingSmall * .75),
                          child: Text(
                            // "@ ${_list[index].id}",
                            "@ ${_list[index].username}",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: dimen.textMidSmall,
                              color: Colors.white,
                              fontFamily: MyFont.poppins_regular,
                            ),
                          ),
                        )),
            _list[index].id == SessionImpl.getId()
                ? Container()
                : widget.id != SessionImpl.getId()
                    ? Container()
                    : Positioned(
                        top: dimen.marginVerySmall,
                        right: dimen.marginVerySmall,
                        child: InkWell(
                            onTap: () {
                              showAlertDialogRemovePost(
                                  _list[index].postId, index, 0);
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
                                    // tileMode: TileMode.repeated,
                                  )),
                                  padding: const EdgeInsets.all(
                                      dimen.paddingSmall * .75),
                                  child: Icon(
                                    Icons.delete_sweep,
                                    color: whiteTextColor,
                                    size: 16,
                                  )),
                            )),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _getChildMemories(BuildContext context, int index) {
    return _listMemories[index] == null
        ? InkWell(
            onTap: () {
              Get.to(AddNewPost(LabelStr.lblAddMemories));
            },
            child: Container(
              //key: intro2.keys[0],
              color: iconPrimerColor,
              child: Center(
                  child: Icon(
                Icons.add,
                color: Colors.white,
                size: dimen.iconButtonSize,
              )),
            ),
          )
        : InkWell(
            onTap: () {
              Get.to(MemoriesDetail(_listMemories[index]));
            },
            child: Container(
                child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: CachedNetworkImage(
                      imageUrl: _listMemories.length > 0
                          ? (_listMemories[index].memorieMediaLinks.length != 0
                              ? _listMemories[index]
                                  .memorieMediaLinks[0]
                                  .downloadlink
                              : '')
                          : '',
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url,
                              downloadProgress) =>
                          Image.asset(MyImage.ic_preview, fit: BoxFit.cover),
                      errorWidget: (context, url, error) =>
                          Image.asset(MyImage.ic_preview, fit: BoxFit.cover)),
                ),
                Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.black38),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    _listMemories.length > 0
                        ? _listMemories[index].eventName +
                            " " +
                            _listMemories[index].startDate.year.toString()
                        : '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: MyFont.Poppins_semibold,
                        color: Colors.white),
                  ),
                ),
              ],
            )),
          );
  }

  showAlertDialogRemovePost(postId, index, type) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        Get.back();
        _removePost(postId, index, type);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Remove Tag Post"),
      content: Text("Are you sure you want to remove"),
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

  void _removePost(postId, index, type) {
    var body = {
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CPostId: postId,
    };
    RequestManager.postRequest(
        uri: endPoints.RemoveTagOfPost,
        body: body,
        isLoader: true,
        isSuccessMessage: true,
        isFailedMessage: false,
        onSuccess: (response) {
          if (type == 0) {
            _list.removeAt(index);
            postListLength.value = _list.length;
          } else {
            _listMemories.removeAt(index);
            memoriesListLength.value = _listMemories.length;
          }
        },
        onFailure: (error) {});
  }

  _openSongPreview(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SpotifyPreviewPlayer(index);
      },
    );
  }

  Widget postAndMemoriesSegmentView() {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(10), bottom: ScreenUtil().setHeight(10)),
      child: Stack(
        children: [
          Container(
            padding:
                EdgeInsets.only(left: dimen.paddingTiny, right: dimen.paddingTiny),
            height: 40,
            //key: intro.keys[1],
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(color: HexColor.hintColor, width: 1),
                borderRadius: BorderRadius.circular(8)),
            child: CupertinoSlidingSegmentedControl(
              //backgroundColor: Colors.white,
              thumbColor: tabActiveColor,
              groupValue: pageSelectOption.value,
              children: <int, Widget>{
                0: Text(
                  LabelStr.lblPosts,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: (pageSelectOption.value == 0)
                        ? Colors.white
                        : blueGrayColor,
                  ),
                ),
                1: Container(child: Text(LabelStr.lblMemories,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: (pageSelectOption.value == 1)
                          ? Colors.white
                          : blueGrayColor,
                    ))),
              },
              onValueChanged: (selectedValue) {
                changeTab(selectedValue as int);
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              key: intro.keys.length > 1 ? intro.keys[1] : intro.keys[0],
              width: MediaQuery.of(context).size.width/2.5,
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  void changeTab(int selectedValue){
    pageSelectOption.value = selectedValue;
    if (selectedValue == 1) {
      if (widgetRefresherMemories.value == '') {
        _loadMemoriesData(true);
      } else {
        widgetRefresherMemories.value = Utilities.getRandomString();
      }
    } else {
      if (widgetRefresher.value == '') {
        _loadPostData();
      } else {
        widgetRefresher.value = Utilities.getRandomString();
      }
    }
  }
}
