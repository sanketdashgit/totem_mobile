import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/SongTotemModel.dart';
import 'package:totem_app/Ui/Profile/AddSongs.dart';
import 'package:totem_app/Ui/NavigationDrawerScreen.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:get/get.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Customs/ButtonRegular.dart';
import '../Customs/CommonNetworkImage.dart';

class CreateProfileMusic extends StatefulWidget {
  bool isEdit = false;

  CreateProfileMusic({this.isEdit});

  @override
  _CreateProfileIntersetsState createState() => _CreateProfileIntersetsState();
}

class _CreateProfileIntersetsState extends State<CreateProfileMusic> {
  var widgetRefresherTracks = "".obs;
  List<SongTotemModel> _tracks = [];
  var isButtonLoaderEnabled = false.obs;

  Intro intro;

  void setupIntro() {
    intro = Intro(
      noAnimation: false,
      maskColor: Colors.black.withAlpha(170),
      stepCount: 1,
      maskClosable: false,
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          IntroMessage.lblIntro10,
        ],
        buttonTextBuilder: (currPage, totalPage) {
          if (currPage < totalPage - 1) {
            return LabelStr.lblNext;
          } else {
            SessionImpl.setIntro8(true);
            return LabelStr.lblNext;
          }
        },
      ),
    );
  }

  void startIntro8() {
    if (!SessionImpl.getIntro8()) {
      intro.start(context);
    }
  }

  @override
  void initState() {
    setupIntro();
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) => startIntro8());
    if (widget.isEdit) _getTrackApiCall();
  }

  void _updateGenres() {
    _tracks.clear();
    _tracks.addAll(rq.selectedTracks);
    widgetRefresherTracks.value = Utilities.getRandomString();
  }

  List<String> originalSongs = [];

  void _getTrackApiCall() {
    var body = {Parameters.Cid: SessionImpl.getId()};
    RequestManager.postRequest(
        uri: endPoints.getFavSongs,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          originalSongs = List<SongTotemModel>.from(
                  response.map((x) => SongTotemModel.fromJson(x)))
              .map((e) => e.spotifyId)
              .toList();
          rq.selectedTracks = List<SongTotemModel>.from(
              response.map((x) => SongTotemModel.fromJson(x)));
          _updateGenres();
        },
        onFailure: (error) {});
  }

  void _saveTrackApiCall() {
    Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
    if (!unOrdDeepEq(originalSongs, _tracks.map((e) => e.spotifyId).toList())) {
      var songs = List<dynamic>.from(_tracks.map((x) => x.toJson()));
      var body = {
        Parameters.Cid: SessionImpl.getId(),
        Parameters.CSongs: songs
      };
      RequestManager.postRequest(
          uri: endPoints.favSongs,
          body: body,
          isLoader: true,
          isSuccessMessage: false,
          isFailedMessage: true,
          onSuccess: (response) {
            Get.offAll(NavigationDrawerScreen(9));
          },
          onFailure: (error) {
            Get.offAll(NavigationDrawerScreen(9));
          });
    } else {
      Get.offAll(NavigationDrawerScreen(9));
    }
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
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(dimen.paddingForBackArrow),
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
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(22)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            MyImage.ic_spotify,
                            height: 30,
                            width: 30,
                          ),
                          SizedBox(
                            width: dimen.paddingSmall,
                          ),
                          Text(
                            LabelStr.lblTopSongs,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: MyFont.Poppins_semibold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(AddSongs()).then((value) => _updateGenres());
                    },
                    child: Row(
                      key: intro.keys[0],
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 7.0),
                          child: SvgPicture.asset(
                            MyImage.ic_addedit,
                            color: buttonPrimary,
                          ),
                        ),
                        Text(
                          LabelStr.lblAdd,
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: MyFont.Poppins_medium,
                              color: buttonPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _favoritelist()),
            Padding(
              padding: const EdgeInsets.only(bottom: 26, top: 8),
              child: Obx(
                () => ButtonRegular(
                    buttonText:
                        isButtonLoaderEnabled.value ? null : LabelStr.lblNext,
                    onPressed: () {
                      _saveTrackApiCall();
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  _removeTrack(int index) {
    _tracks.removeAt(index);
    rq.selectedTracks.removeAt(index);
    widgetRefresherTracks.value = Utilities.getRandomString();
  }

  _favoritelist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresherTracks.value,
          itemCount: _tracks.length,
          itemBuilder: (context, index) {
            return Slidable(
              key: ValueKey(_tracks[index].spotifyId),
              actionPane: SlidableDrawerActionPane(),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: LabelStr.lbldelete,
                  color: Colors.red,
                  icon: Icons.delete,
                  closeOnTap: true,
                  onTap: () {
                    _removeTrack(index);
                  },
                )
              ],
              dismissal: SlidableDismissal(
                child: SlidableDrawerDismissal(),
                onDismissed: (actionType) {
                  _removeTrack(index);
                },
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: dimen.paddingSmall),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CommonNetworkImage(
                            height: 50,
                            width: 50,
                            radius: 25,
                            imageUrl: _tracks[index].image),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tracks[index].trackName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: MyFont.poppins_regular,
                                      color: Colors.white),
                                ),
                                Text(
                                  _tracks[index].albumName +
                                      " " +
                                      (_tracks[index].artistName.isNotEmpty
                                          ? "(" +
                                              _tracks[index].artistName +
                                              ")"
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
                              _launchURL(_tracks[index].songlink);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: iconPrimerColor,
                                  border:
                                      Border.all(color: HexColor.borderColor)),
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(MyImage.ic_music)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 56, top: dimen.paddingSmall),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: index == _tracks.length - 1
                                        ? Colors.transparent
                                        : chatTextBorderColor)),
                            // color: listDividerColor
                          ),
                        ))
                  ],
                ),
              ),
            );
          },
        ));
  }

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw '${LabelStr.lblCouldNotLaunch} $_url';

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
              _circleContainerTic(),
              _lineContainer(true),
              _circleContainer(true),
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
                    color: purpleTextColor),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  LabelStr.lblinterests,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: 12,
                      color: purpleTextColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: Text(
                  LabelStr.lblmusic,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: 12,
                      color: Colors.white),
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
              color: isActive ? purpleTextColor : greyTextColor, width: 2)),
    );
  }

  Widget _circleContainerTic() {
    return Container(
      width: ScreenUtil().setWidth(30),
      height: ScreenUtil().setHeight(30),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: purpleTextColor, width: 2)),
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
}
