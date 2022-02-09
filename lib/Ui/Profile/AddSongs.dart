import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/CommonStuff.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/SongTotemModel.dart';
import 'package:totem_app/Models/TrackModel.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import '../Customs/ButtonRegular.dart';
import '../Customs/CommonNetworkImage.dart';

class AddSongs extends StatefulWidget {
  @override
  _AddSongsState createState() => _AddSongsState();
}

class _AddSongsState extends State<AddSongs> {
  Timer _timer;
  var widgetRefresher = "".obs;
  var _searchController = TextEditingController();
  String _searchText = "";
  List<SongTotemModel> _list = [];
  List<SongTotemModel> _selectedData = [];
  List<String> _selectedIds = [];
  int userId = SessionImpl.getId();

  @override
  void initState() {
    super.initState();
    _searchText = "";
    _selectedData.addAll(rq.selectedTracks);
    _selectedData.forEach((element) {
      _selectedIds.add(element.spotifyId);
    });
    _getFavTrackApiCall();
    //_callTrackApi();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _callTrackApi() {
    RequestManager.getSpotifyDetails(
        uri:
            "https://api.spotify.com/v1/search?q=$_searchText&type=track&limit=20",
        token: SessionImpl.getSpotifyToken().toString(),
        onSuccess: (response) {
          _list.clear();
          Tracks tracks = Tracks.fromJson(response['tracks']);
          tracks.items.forEach((element) {
            String image = "";
            String artist = "";
            if (element.album.images.length > 0)
              image = element.album.images[0].url;
            if (element.artists.length > 0) artist = element.artists[0].name;
            _list.add(SongTotemModel(
                id: userId,
                spotifyId: element.id,
                trackName: element.name,
                albumName: element.album.name,
                artistName: artist,
                image: image,
                songlink: element.externalUrls.spotify,
                albumId: element.album.id));
          });
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void _getFavTrackApiCall() {
    var body = {Parameters.Cid: SessionImpl.getId()};
    RequestManager.postRequest(
        uri: endPoints.getTopSongs,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          _list = List<SongTotemModel>.from(
              response.map((x) => SongTotemModel.fromJson(x)));
          _list.forEach((element) {
            element.id = userId;
          });
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Get.back();
          return false;
        },
        child: Scaffold(
          backgroundColor: screenBgColor,
          appBar: AppBar(
              centerTitle: true,
              brightness: Brightness.dark,
              leading: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                    child: Icon(Icons.arrow_back_ios_outlined),
                  )),
              title: Text(
                LabelStr.lblTopSongs,
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: MyFont.Poppins_semibold,
                    color: Colors.white),
              )),
          body: Container(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(10),
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(20)),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: screenBgLightColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30, left: 10),
                      child: TextField(
                        onChanged: onItemChanged,
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.blue,
                        enabled: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: LabelStr.lblSearchSongs,
                            hintStyle: TextStyle(color: colorHintText),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Obx(() => widgetRefresher.value == ''
                        ? Container()
                        : _list.length == 0 && _searchText.isNotEmpty
                            ? Widgets.dataNotFound()
                            : _favoritelist())),
                Padding(
                  padding: const EdgeInsets.only(bottom: 26, top: 8),
                  child: Container(
                      child: ButtonRegular(
                          buttonText: LabelStr.lblSave,
                          onPressed: () {
                            rq.selectedTracks.clear();
                            rq.selectedTracks.addAll(_selectedData);
                            Get.back();
                          })),
                )
              ],
            ),
          ),
        ));
  }

  onItemChanged(String value) {
    if (_searchController.text != '') {
      startTimer();
    } else {
      _timer.cancel();
      _searchText = _searchController.text;
      resetSearch();
    }
  }

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_searchController.text != _searchText) {
          _searchText = _searchController.text;
          _callTrackApi();
        }
      },
    );
  }

  resetSearch() {
    _list.clear();
    widgetRefresher.value = Utilities.getRandomString();
  }

  _favoritelist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresher.value,
          itemCount: _list.length,
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
                        imageUrl: _list[index].image),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _list[index].trackName,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: MyFont.poppins_regular,
                                  color: Colors.white),
                            ),
                            Text(
                              _list[index].albumName +
                                  " " +
                                  (_list[index].artistName.isNotEmpty
                                      ? "(" + _list[index].artistName + ")"
                                      : ""),
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
                          launchURL(_list[index].songlink);
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
                    Center(
                      child: InkWell(
                        onTap: () {
                          if (!_selectedIds.contains(_list[index].spotifyId)) {
                            if (_selectedData.length < 5) {
                              _selectedIds.add(_list[index].spotifyId);
                              _selectedData.add(_list[index]);
                            } else {
                              RequestManager.getSnackToast(
                                  title: LabelStr.lblLimitOver,
                                  message: Messages.C5songs);
                            }
                          } else {
                            var removeIndex = 0;
                            _selectedData.forEach((element) {
                              if (element.spotifyId == _list[index].spotifyId) {
                                removeIndex = _selectedData.indexOf(element);
                              }
                            });
                            _selectedIds.remove(_list[index].spotifyId);
                            _selectedData.removeAt(removeIndex);
                          }
                          widgetRefresher.value = Utilities.getRandomString();
                        },
                        child: Container(
                          margin: EdgeInsets.all(3.0),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: iconPrimerColor,
                              border: Border.all(color: HexColor.borderColor)),
                          child: Center(
                              child: Icon(
                            _selectedIds.contains(_list[index].spotifyId)
                                ? Icons.remove
                                : Icons.add,
                            color: Colors.white,
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                index == _list.length - 1
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
