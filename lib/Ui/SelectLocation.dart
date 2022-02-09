import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:google_maps_webservice/places.dart';

class SelectLocation extends StatefulWidget {
  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  var getPlaceList = [];
  var widgetRefresher = "".obs;
  List<String> plaseId = [];
  var _searchText = "";

  var _searchController = TextEditingController();
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: endPoints.kGoogleApiKey);

  LatLng userLocation = LatLng(0.0, 0.0);
  LatLng selectedLocation = LatLng(0.0, 0.0);
  String currentUserLocation = "";
  List<PlacesSearchResult> places = [];
  var selectedLat = 0.00;
  var selectedLng = 0.00;
  Timer _timer;

  searchApi(searchText) {
    RequestManager().getGooglePlaces(
      searchText,
      requestCode: LabelStr.lblgoogle,
      onSuccess: (response, requestCode) {
        getPlaceList.clear();
        plaseId.clear();
        if (_searchController.text.length != 0) {
          var result = response[LabelStr.lblPredictions];
          for (int i = 0; i < result.length; i++) {
            Map<String, String> tmpLocation = {
              LabelStr.lblMainText: result[i]['structured_formatting']['main_text'],
              LabelStr.lbldescription.toLowerCase(): result[i]['structured_formatting']
                  ['secondary_text'],
              Parameters.CPlaceId: result[i]["place_id"]
            };
            getPlaceList.add(tmpLocation);
            plaseId.add(result[i]["place_id"]);
          }
        }
        widgetRefresher.value = Utilities.getRandomString();
      },
      onFailure: (errorMsg, requestCode) {
        Widgets.loadingDismiss();
      },
    );
  }

  @override
  void initState() {
    _searchText = '';
    startTimer();
    super.initState();
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
          searchApi(_searchController.text);
        }
      },
    );
  }

  Future<Null> displayPrediction({String placeId, String plaseName}) async {
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);
    selectedLat = detail.result.geometry.location.lat;
    selectedLng = detail.result.geometry.location.lng;
    Widgets.loadingDismiss();
    getPlaceList.clear();
    widgetRefresher.value = Utilities.getRandomString();
    Navigator.pop(context, [
      true,
      {
        Parameters.CLat: selectedLat,
        Parameters.CLng: selectedLng,
        Parameters.CPlaceName: plaseName
      }
    ]);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget addressListView() {
    return Container(
        child: Obx(() => ListView.builder(
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: getPlaceList.length,
            restorationId: widgetRefresher.value,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return addressListCell(index);
            })));
  }

  Widget addressListCell(int position) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getPlaceList[position][LabelStr.lblMainText].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: dimen.textMedium),
                  ),
                  SizedBox(
                    height: dimen.paddingSmall,
                  ),
                  Text(
                    getPlaceList[position]['description'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: 0.8,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        fontSize: dimen.textMedium),
                  ),
                ],
              ),
              onTap: () {
                Widgets.showLoading();
                displayPrediction(
                    placeId: getPlaceList[position][Parameters.CPlaceId],
                    plaseName: getPlaceList[position][LabelStr.lblMainText].toString() + " " + getPlaceList[position]['description'].toString());
              },
            ),
          ),
          Container(
            color: greyTextColor,
            height: 1.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: screenBgColor,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                        child: Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.white,
                        ),
                      )),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: screenBgLightColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 30, left: 10),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: Colors.white),
                              cursorColor: Colors.blue,
                              enabled: true,
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
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: addressListView())
          ],
        ),
      ),
    );
  }
}