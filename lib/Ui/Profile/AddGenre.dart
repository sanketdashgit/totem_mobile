import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import '../Customs/ButtonRegular.dart';
import '../Customs/ItemSkeleton.dart';

class AddGenre extends StatefulWidget {
  @override
  _AddGenreState createState() => _AddGenreState();
}

class _AddGenreState extends State<AddGenre> {
  List<String> _originalData = [];
  List<String> _filteredData = [];
  List<String> _selectedData = [];
  List<String> _removedGenres = [
    "Detroit-techno",
    "Disney",
    "Mandopop",
    "Mpb",
    "New-release",
    "Philippines-opm",
    "sertanejo",
    "Show-tunes",
    "Study",
    "Turkish"
  ];

  Timer _timer;
  var widgetRefresher = "".obs;
  var _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchText = "";
    _selectedData.addAll(rq.selectedGener);
    _callGenreApi();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  var isChristianAdd = false;

  void _callGenreApi() {
    RequestManager.getSpotifyDetails(
        uri: "https://api.spotify.com/v1/recommendations/available-genre-seeds",
        token: SessionImpl.getSpotifyToken().toString(),
        onSuccess: (response) {
          response['genres'].forEach((element) => _originalData.add(
              element.toString()[0].toUpperCase() +
                  element.toString().substring(1)));

          _originalData.forEach((element) {
            if (!_removedGenres.contains(element.toString())) {
              if (element.toString()[0].toUpperCase() == "C") {
                if (!isChristianAdd) {
                  isChristianAdd = true;
                  _filteredData.add(LabelStr.lblChristian);
                }
              }
              if (element.toString() == "R-n-b") {
                element = "R&B";
                _filteredData.add(LabelStr.lblRap);
              }
              _filteredData.add(element);
            }
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
              backgroundColor: screenBgColor,
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
                LabelStr.lblAddGenre,
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
                            hintText: LabelStr.lblSearch,
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
                        ? _skeletonList()
                        : _filteredData.length == 0
                            ? Widgets.dataNotFound()
                            : _favoritelist())),
                Padding(
                  padding: const EdgeInsets.only(bottom: 26, top: 8),
                  child: Container(
                      child: ButtonRegular(
                          buttonText: LabelStr.lblSave,
                          onPressed: () {
                            rq.selectedGener.clear();
                            rq.selectedGener.addAll(_selectedData);
                            Get.back();
                          })),
                )
              ],
            ),
          ),
        ));
  }

  _skeletonList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return ItemSkeleton();
        });
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
          resetSearch();
        }
      },
    );
  }

  resetSearch() {
    if (_searchText.isEmpty) {
      _filteredData.clear();
      _filteredData.addAll(_originalData);
    } else {
      _filteredData.clear();
      _originalData.forEach((element) {
        if (element.toLowerCase().contains(_searchText.toLowerCase())) {
          _filteredData.add(element.toString());
        }
      });
    }
    widgetRefresher.value = Utilities.getRandomString();
  }

  _favoritelist() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          restorationId: widgetRefresher.value,
          itemCount: _filteredData.length,
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
                            child: Text(_filteredData[index][0].toUpperCase(),
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
                          _filteredData[index],
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: MyFont.poppins_regular,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          if (!_selectedData.contains(_filteredData[index])) {
                            if (_selectedData.length < 20) {
                              _selectedData.add(_filteredData[index]);
                            } else {
                              RequestManager.getSnackToast(
                                  title: LabelStr.lblLimitOver,
                                  message: Messages.C20Genres);
                            }
                          } else {
                            var removeIndex = 0;
                            _selectedData.forEach((element) {
                              if (element == _filteredData[index]) {
                                removeIndex = _selectedData.indexOf(element);
                              }
                            });
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
                                border:
                                    Border.all(color: HexColor.borderColor)),
                            child: Center(
                                child: Icon(
                              _selectedData.contains(_filteredData[index])
                                  ? Icons.remove
                                  : Icons.add,
                              color: Colors.white,
                            ))),
                      ),
                    ),
                  ],
                ),
                index == _filteredData.length - 1
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
