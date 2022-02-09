import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/GeneralUtils/StringExtension.dart';
import 'package:totem_app/Models/ArtistTotemModel.dart';
import 'package:totem_app/Models/EventHomeModel.dart';
import 'package:totem_app/Models/IntrestSaveModel.dart';
import 'package:totem_app/Models/Product.dart';
import 'package:totem_app/Ui/Profile/AddEventProfile.dart';
import 'package:totem_app/Ui/Profile/AddGenre.dart';
import 'package:totem_app/Ui/Profile/AddNextEventInProfile.dart';
import 'package:totem_app/Ui/Profile/CreateProfileMusic.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import '../Customs/ButtonRegular.dart';
import '../Customs/CommonNetworkImage.dart';
import 'AddArtist.dart';

class CreateProfileBasicInfo extends StatefulWidget {
  bool isEdit = false;

  CreateProfileBasicInfo({this.isEdit});

  @override
  _CreateProfileBasicInfoState createState() => _CreateProfileBasicInfoState();
}

class _CreateProfileBasicInfoState extends State<CreateProfileBasicInfo> {
  List<Product> _list = [];
  var widgetRefresherGenre = "".obs;
  var widgetRefresherArtist = "".obs;
  var widgetRefresherEvents = "".obs;
  var widgetRefresherNextEvents = "".obs;
  List<String> _genre = [];
  List<ArtistTotemModel> _artists = [];
  List<EventHomeModel> _events = [];
  List<EventHomeModel> _nextEvents = [];
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
          IntroMessage.lblIntro9,
        ],
        buttonTextBuilder: (currPage, totalPage) {
          if (currPage < totalPage - 1) {
            return LabelStr.lblNext;
          } else {
            SessionImpl.setIntro7(true);
            return LabelStr.lblNext;
          }
        },
      ),
    );
  }

  void startIntro7() {
    if (!SessionImpl.getIntro7()) {
      intro.start(context);
    }
  }

  @override
  void initState() {
    setupIntro();
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) => startIntro7());
    _callSpotifyAccessToken();
    if (widget.isEdit) _getSpotifyApiCall();
  }

  void _callSpotifyAccessToken() {
    RequestManager.getSpotifyAccessToken(
        onSuccess: (response) {
          SessionImpl.setSpotifyToken(response.toString());
        },
        onFailure: () {});
  }

  void _updateGenres() {
    _genre.clear();
    _genre.addAll(rq.selectedGener);
    widgetRefresherGenre.value = Utilities.getRandomString();
  }

  void _updateAtrists() {
    _artists.clear();
    _artists.addAll(rq.selectedArtist);
    widgetRefresherArtist.value = Utilities.getRandomString();
  }

  void _updateEvents() {
    _events.clear();
    _events.addAll(rq.selectedEvents);
    widgetRefresherEvents.value = Utilities.getRandomString();
  }

  void _updateNextEvents() {
    _nextEvents.clear();
    _nextEvents.addAll(rq.nextEvents);
    widgetRefresherNextEvents.value = Utilities.getRandomString();
  }

  void _callSaveApi() {
    isButtonLoaderEnabled.value = true;
    int userId = SessionImpl.getId();
    InterestSaveModel model = InterestSaveModel();
    model.id = userId;
    model.artists = _artists;
    List<ArtistTotemModel> _genresSave = [];
    _genre.forEach((element) {
      _genresSave.add(ArtistTotemModel(
          id: userId, image: "", name: element, spotifyId: ""));
    });
    model.genres = _genresSave;
    List<FavouriteEvent> _eventsSave = [];
    _events.forEach((element) {
      _eventsSave.add(FavouriteEvent(eventId: element.eventId, id: userId));
    });
    model.favouriteEvents = _eventsSave;

    List<FavouriteEvent> _nextEvent = [];
    _nextEvents.forEach((element) {
      _nextEvent.add(FavouriteEvent(eventId: element.eventId, id: userId));
    });
    model.nextEvents = _nextEvent;
    if (checkNeedApiCall(model)) {
      var body = model.toJson();
      RequestManager.postRequest(
          uri: endPoints.saveSpotify,
          body: body,
          isLoader: false,
          isSuccessMessage: false,
          onSuccess: (response) {
            isButtonLoaderEnabled.value = false;
            Get.to(CreateProfileMusic(isEdit: widget.isEdit));
          },
          onFailure: (error) {
            isButtonLoaderEnabled.value = false;
          });
    } else {
      isButtonLoaderEnabled.value = false;
      Get.to(CreateProfileMusic(isEdit: widget.isEdit));
    }
  }

  bool checkNeedApiCall(InterestSaveModel model) {
    try {
      Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
      if (!unOrdDeepEq(model.artists.map((e) => e.spotifyId).toList(),
          originalModel.artists.map((e) => e.spotifyId).toList())) {
        return true;
      }
      if (!unOrdDeepEq(model.genres.map((e) => e.name).toList(),
          originalModel.genres.map((e) => e.name).toList())) {
        return true;
      }
      if (!unOrdDeepEq(model.favouriteEvents.map((e) => e.eventId),
          originalModel.favouriteEvents.map((e) => e.eventId))) {
        return true;
      }
      List<int> nextEventIds = [];
      model.nextEvents.forEach((element) {
        nextEventIds.add(element.eventId);
      });
      if (!unOrdDeepEq(nextEventIds, originalEventList)) {
        return true;
      }
      return false;
    } catch (e) {}
    return true;
  }

  InterestGetModel originalModel;

  void _getSpotifyApiCall() {
    var body = {Parameters.Cid: SessionImpl.getId()};
    RequestManager.postRequest(
        uri: endPoints.getSpotify,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        onSuccess: (response) {
          originalModel = InterestGetModel.fromJson(response);
          InterestGetModel model = InterestGetModel.fromJson(response);
          List<String> genres = [];
          model.genres.forEach((element) {
            genres.add(element.name);
          });
          rq.selectedGener = genres;
          rq.selectedArtist = model.artists;
          rq.selectedEvents = model.favouriteEvents;
          _updateGenres();
          _updateAtrists();
          _updateEvents();
          _callNextEventsApi();
        },
        onFailure: (error) {
          originalModel = InterestGetModel();
        });
  }

  List<int> originalEventList = [];

  void _callNextEventsApi() {
    var body = {
      Parameters.CpageNumber: 1,
      Parameters.CpageSize: 50,
      Parameters.Csearch: '',
      Parameters.CtotalRecords: 0,
      Parameters.CeventId: 0,
      Parameters.CUserId: SessionImpl.getId(),
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
          originalEventList.clear();
          rq.nextEvents.forEach((element) {
            originalEventList.add(element.eventId);
          });
          _updateNextEvents();
        },
        onFailure: (error) {});
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
                  height: 29.0,
                ),
                _tabController(),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(22)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                LabelStr.lblFavoriteGenres,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: MyFont.Poppins_semibold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Get.to(AddGenre())
                                  .then((value) => _updateGenres());
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
                    _genrelist(),
                    Divider(
                      height: 4.0,
                      color: chatTextBorderColor,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                LabelStr.lblArtists,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: MyFont.Poppins_semibold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Get.to(AddArtist())
                                  .then((value) => _updateAtrists());
                            },
                            child: Row(
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
                    _artistlist(),
                    Divider(
                      height: 4.0,
                      color: chatTextBorderColor,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                LabelStr.lblEvents,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: MyFont.Poppins_semibold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Get.to(AddEventProfile())
                                  .then((value) => _updateEvents());
                            },
                            child: Row(
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
                    _eventlist(),
                    Divider(
                      height: 4.0,
                      color: chatTextBorderColor,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                LabelStr.lblNextEvents,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: MyFont.Poppins_semibold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Get.to(AddNextEventInProfile())
                                  .then((value) => _updateNextEvents());
                            },
                            child: Row(
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
                    _nextEventlist(),
                    SizedBox(
                      height: 16.0,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 26, top: 8),
              child: Obx(
                () => ButtonRegular(
                    buttonText:
                        isButtonLoaderEnabled.value ? null : LabelStr.lblNext,
                    onPressed: () {
                      _callSaveApi();
                    }),
              ),
            )
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
                  fontSize: 12,
                  color: purpleTextColor,
                ),
                //color: Color.fromRGBO(129, 100, 184, 1)),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  LabelStr.lblinterests,
                  style: TextStyle(
                      fontFamily: MyFont.poppins_regular,
                      fontSize: 12,
                      color: Colors.white),
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

  _removeGenre(int index) {
    _genre.removeAt(index);
    rq.selectedGener.removeAt(index);
    widgetRefresherGenre.value = Utilities.getRandomString();
  }

  _genrelist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          restorationId: widgetRefresherGenre.value,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _genre.length,
          itemBuilder: (context, index) {
            return Slidable(
              key: ValueKey(_genre[index]),
              actionPane: SlidableDrawerActionPane(),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: LabelStr.lbldelete,
                  color: Colors.red,
                  icon: Icons.delete,
                  closeOnTap: true,
                  onTap: () {
                    _removeGenre(index);
                  },
                )
              ],
              dismissal: SlidableDismissal(
                child: SlidableDrawerDismissal(),
                onDismissed: (actionType) {
                  _removeGenre(index);
                },
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: dimen.paddingSmall),
                child: Column(
                  children: [
                    Row(
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
                                child: Text(_genre[index][0].toUpperCase(),
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
                              _genre[index].capitalizeFirst,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: MyFont.poppins_regular,
                                  color: Colors.white),
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
                                    color: index == _genre.length - 1
                                        ? Colors.transparent
                                        : HexColor("#3C456C"))),
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

  _removeArtist(int index) {
    _artists.removeAt(index);
    rq.selectedArtist.removeAt(index);
    widgetRefresherArtist.value = Utilities.getRandomString();
  }

  _artistlist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresherArtist.value,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          physics: NeverScrollableScrollPhysics(),
          itemCount: _artists.length,
          itemBuilder: (context, index) {
            return Slidable(
              key: ValueKey(_artists[index].spotifyId),
              actionPane: SlidableDrawerActionPane(),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: LabelStr.lbldelete,
                  color: Colors.red,
                  icon: Icons.delete,
                  closeOnTap: true,
                  onTap: () {
                    _removeArtist(index);
                  },
                )
              ],
              dismissal: SlidableDismissal(
                child: SlidableDrawerDismissal(),
                onDismissed: (actionType) {
                  _removeArtist(index);
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
                          imageUrl: _artists[index].image,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              _artists[index].name,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: MyFont.poppins_regular,
                                  color: Colors.white),
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
                                    color: index == _artists.length - 1
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

  _removeEvent(int index) {
    _events.removeAt(index);
    rq.selectedEvents.removeAt(index);
    widgetRefresherEvents.value = Utilities.getRandomString();
  }

  _eventlist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresherEvents.value,
          itemCount: _events.length,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Slidable(
              key: ValueKey(_events[index].eventId),
              actionPane: SlidableDrawerActionPane(),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: LabelStr.lbldelete,
                  color: Colors.red,
                  icon: Icons.delete,
                  closeOnTap: true,
                  onTap: () {
                    _removeEvent(index);
                  },
                )
              ],
              dismissal: SlidableDismissal(
                child: SlidableDrawerDismissal(),
                onDismissed: (actionType) {
                  _removeEvent(index);
                },
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: dimen.paddingSmall, /*bottom: dimen.paddingSmall*/
                ),
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
                          imageUrl: _events[index].eventImages.length > 0
                              ? _events[index].eventImages[0].downloadlink
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
                                  _events[index].eventName.toTitleCase(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: MyFont.poppins_regular,
                                      color: Colors.white),
                                ),
                                Text(
                                  _events[index].address.capitalizeFirst,
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
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 56, top: dimen.paddingSmall),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: index == _events.length - 1
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

  _removeNextEvent(int index) {
    _nextEvents.removeAt(index);
    rq.nextEvents.removeAt(index);
    widgetRefresherNextEvents.value = Utilities.getRandomString();
  }

  _nextEventlist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresherNextEvents.value,
          itemCount: _nextEvents.length,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Slidable(
              key: ValueKey(_nextEvents[index].eventId),
              actionPane: SlidableDrawerActionPane(),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: LabelStr.lbldelete,
                  color: Colors.red,
                  icon: Icons.delete,
                  closeOnTap: true,
                  onTap: () {
                    _removeNextEvent(index);
                  },
                )
              ],
              dismissal: SlidableDismissal(
                child: SlidableDrawerDismissal(),
                onDismissed: (actionType) {
                  _removeNextEvent(index);
                },
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: dimen.paddingSmall, /*bottom: dimen.paddingSmall*/
                ),
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
                          imageUrl: _nextEvents[index].eventImages.length > 0
                              ? _nextEvents[index].eventImages[0].downloadlink
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
                                  _nextEvents[index].eventName.toTitleCase(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: MyFont.poppins_regular,
                                      color: Colors.white),
                                ),
                                Text(
                                  _nextEvents[index].address.capitalizeFirst,
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
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 56, top: dimen.paddingSmall),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: index == _nextEvents.length - 1
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
}
