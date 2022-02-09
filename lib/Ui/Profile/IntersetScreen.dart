import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/ArtistTotemModel.dart';
import 'package:totem_app/Models/EventHomeModel.dart';
import 'package:totem_app/Models/IntrestSaveModel.dart';
import 'package:totem_app/Models/SongTotemModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:url_launcher/url_launcher.dart';

class IntersetScreen extends StatefulWidget {
  int id;

  IntersetScreen(this.id);

  @override
  _IntersetScreenState createState() => _IntersetScreenState();
}

class _IntersetScreenState extends State<IntersetScreen> {
  var widgetRefresherGenre = "".obs;
  var widgetRefresherArtist = "".obs;
  var widgetRefresherEvents = "".obs;
  var widgetRefresherNextEvents = "".obs;
  var widgetRefresherTracks = "".obs;
  List<String> _genre = [];
  List<ArtistTotemModel> _artists = [];
  List<EventHomeModel> _events = [];
  List<EventHomeModel> _nextEvents = [];
  List<SongTotemModel> _tracks = [];

  @override
  void initState() {
    super.initState();
    _getTrackApiCall();
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

  void _updateSongs() {
    _tracks.clear();
    _tracks.addAll(rq.selectedTracks);
    widgetRefresherTracks.value = Utilities.getRandomString();
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
          _updateGenres();
          _updateAtrists();
          _updateEvents();
          _callNextEventsApi();
        },
        onFailure: (error) {});
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
          _updateNextEvents();
        },
        onFailure: (error) {});
  }

  void _getTrackApiCall() {
    var body = {Parameters.Cid: widget.id};
    RequestManager.postRequest(
        uri: endPoints.getFavSongs,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          rq.selectedTracks = List<SongTotemModel>.from(
              response.map((x) => SongTotemModel.fromJson(x)));
          _updateSongs();
          _getSpotifyApiCall();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                      child: SvgPicture.asset(MyImage.ic_arrow),
                    )),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      LabelStr.lblinterests,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: MyFont.Poppins_semibold,
                          color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  width: 30,
                )
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
                                LabelStr.lblTopSongs,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: MyFont.Poppins_semibold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _favoritelist(),
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
                                LabelStr.lblFavoriteGenres,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: MyFont.Poppins_semibold,
                                    color: Colors.white),
                              ),
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
          ],
        ),
      ),
    );
  }

  _favoritelist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          restorationId: widgetRefresherTracks.value,
          itemCount: _tracks.length,
          itemBuilder: (context, index) {
            return Padding(
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
                                        ? "(" + _tracks[index].artistName + ")"
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
            );
          },
        ));
  }

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw '${LabelStr.lblCouldNotLaunch} $_url';

  _genrelist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          restorationId: widgetRefresherGenre.value,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _genre.length,
          itemBuilder: (context, index) {
            return Column(
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
                index == _genre.length - 1
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: Divider(
                          color: chatTextBorderColor,
                        ),
                      )
              ],
            );
          },
        ));
  }

  _artistlist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresherArtist.value,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          physics: NeverScrollableScrollPhysics(),
          itemCount: _artists.length,
          itemBuilder: (context, index) {
            return Column(
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
                index == _artists.length - 1
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: Divider(
                          color: chatTextBorderColor,
                        ),
                      )
              ],
            );
          },
        ));
  }

  _eventlist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresherEvents.value,
          itemCount: _events.length,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
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
                              _events[index].eventName.capitalize,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: MyFont.poppins_regular,
                                  color: Colors.white),
                            ),
                            Text(
                              _events[index].address,
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
                index == _events.length - 1
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: Divider(
                          color: chatTextBorderColor,
                        ),
                      )
              ],
            );
          },
        ));
  }

  _nextEventlist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresherNextEvents.value,
          itemCount: _nextEvents.length,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
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
                              _nextEvents[index].eventName.capitalize,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: MyFont.poppins_regular,
                                  color: Colors.white),
                            ),
                            Text(
                              _nextEvents[index].address,
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
                index == _nextEvents.length - 1
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: Divider(
                          color: chatTextBorderColor,
                        ),
                      )
              ],
            );
          },
        ));
  }
}
