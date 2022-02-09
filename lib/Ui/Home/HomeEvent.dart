import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/CreateEventModel.dart';
import 'package:totem_app/Models/EventHomeModel.dart';
import 'package:totem_app/Models/EventTicketMaster.dart';
import 'package:totem_app/Models/EventUserModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/HomeItemSkeleton.dart';
import 'package:totem_app/Ui/Event/CreateEvent.dart';
import 'package:totem_app/Ui/Event/EventDetails.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class HomeEvent extends StatefulWidget {
  int selectedSegmentOption = 0;
  bool createEventEnable;
  final bool isExplore;

  HomeEvent(this.createEventEnable, this.isExplore);

  @override
  _HomeEventState createState() => _HomeEventState();
}

class _HomeEventState extends State<HomeEvent> {
  var onLoadMore = true;
  var dataOver = false;
  int pageNumber = 0;
  int totalRecords = 0;
  var widgetRefresher = "".obs;

  Timer _timer;
  String _searchText = '';
  List<String> duplicateEvents = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Intro intro;

  void setupIntro() {
    List<String> texts = [
      IntroMessage.lblIntro2,
    ];
    intro = Intro(
      noAnimation: false,
      maskColor: Colors.black.withAlpha(170),
      stepCount: 1,
      maskClosable: false,
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
                OutlinedButton(
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
                    if (params.currentStepIndex < params.stepCount - 1) {
                      params.onNext();
                    } else {
                      params.onFinish();
                      SessionImpl.setIntro10(true);
                    }
                  },
                  child: Text(
                    params.currentStepIndex < params.stepCount - 1
                        ? LabelStr.lblNext
                        : LabelStr.lblNext,
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

  void startIntro() {
    if (!SessionImpl.getIntro10()) {
      intro.start(Get.context);
    }
  }

  @override
  void initState() {
    setupIntro();
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) => startIntro());
    pageNumber = 0;
    _searchText = "";
    if (!widget.isExplore) {
      rq.searchText.value = "";
      _searchText = "";
      if (rq.eventList.length > 0) {
        widgetRefresher.value = Utilities.getRandomString();
      }
      _callEventsApi();
    }
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    pageNumber = 0;
    _callEventsApi();
  }

  void _onLoading() async {
    await Future.delayed(Duration(seconds: 1));
  }

  void startTimer() {
    if (_timer != null) _timer.cancel();
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (rq.searchText.value != _searchText) {
        _searchText = rq.searchText.value;
        resetEventSearch();
      }
    });
  }

  resetEventSearch() {
    if (_searchText.isEmpty) {
      rq.homeFeedList.clear();
      widgetRefresher.value = Utilities.getRandomString();
    } else {
      pageNumber = 0;
      totalRecords = 0;
      _callEventsApi();
    }
  }

  void _callEventsApi() async {
    pageNumber++;
    var body = {
      Parameters.CpageNumber: pageNumber,
      Parameters.CpageSize: global.PAGE_SIZE,
      Parameters.Csearch: _searchText,
      Parameters.CtotalRecords: totalRecords,
      Parameters.CeventId: 0,
      Parameters.CUserId: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.getAllEvent,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          onLoadMore = false;
          _refreshController.loadComplete();
          _refreshController.refreshCompleted();
          pageNumber = response[Parameters.CpageNumber];
          totalRecords = response[Parameters.CtotalRecords];
          if ((pageNumber * global.PAGE_SIZE) < totalRecords) {
            dataOver = false;
          } else {
            dataOver = true;
          }
          if (pageNumber == 1) {
            rq.eventList.clear();
            duplicateEvents.clear();
          }
          var temp = List<EventHomeModel>.from(
              response[Parameters.CData].map((x) => EventHomeModel.fromJson(x)));
          rq.eventList.addAll(temp);
          temp.forEach((element) {
            duplicateEvents.add(element.eventName + " " + element.vanueId);
          });
          if (_searchText.isNotEmpty) {
            _callTicketMasterApi();
          } else
            widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {
          onLoadMore = false;
          if (pageNumber == 1) {
            dataOver = true;
            rq.eventList.clear();
            duplicateEvents.clear();
            widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  void _callTicketMasterApi() {
    RequestManager.getTicketMasterEvents(
        keyword: _searchText,
        onSuccess: (response) {
          try {
            var temp = List<EventTicketMaster>.from(
                response[Parameters.CEvents].map((x) => EventTicketMaster.fromJson(x)));
            temp.forEach((element) {
              List<EventImage> images = [];
              print(element.name +
                  ' ' +
                  element.id +
                  ' ' +
                  element.embedded.venues[0].id);
              if (!duplicateEvents.contains(
                  element.name + " " + element.embedded.venues[0].id)) {
                duplicateEvents
                    .add(element.name + " " + element.embedded.venues[0].id);
                images.add(EventImage(
                    downloadlink: element.images[0].url, fileType: LabelStr.lblCover));
                EventHomeModel model = EventHomeModel(
                    id: 0,
                    eventId: 0,
                    vanueId: element.embedded.venues[0].id,
                    eventName: element.name,
                    startDate: element.dates.start.dateTime,
                    address: element.embedded.venues[0].name +
                        ' ' +
                        element.embedded.venues[0].address.line1 +
                        ' ' +
                        element.embedded.venues[0].city.name +
                        ' ' +
                        element.embedded.venues[0].country.name,
                    details: '',
                    longitude: element.embedded.venues[0].location.longitude,
                    latitude: element.embedded.venues[0].location.latitude,
                    eventImages: images,
                    image: '',
                    interestCount: 0,
                    interest: false,
                    goliveCount: 0,
                    golive: false,
                    favorite: false,
                    favoriteCount: 0);
                rq.eventList.add(model);
              }
            });
          } catch (e) {}
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void callCreateEvent(int index, int createFor) {
    var param = {
      Parameters.CeventId: 0,
      Parameters.CEventName: rq.eventList[index].eventName,
      Parameters.CStartDate: rq.eventList[index].startDate.toIso8601String(),
      Parameters.Caddress: rq.eventList[index].address,
      Parameters.Clatitude: rq.eventList[index].latitude,
      Parameters.Clongitude: rq.eventList[index].longitude,
      Parameters.CVanueId: rq.eventList[index].vanueId,
      Parameters.Cimage: rq.eventList[index].eventImages[0].downloadlink,
    };
    RequestManager.postRequest(
        uri: endPoints.CreateEventwithvanueId,
        body: param,
        isSuccessMessage: false,
        isLoader: true,
        onSuccess: (response) {
          CreateEventresult event = CreateEventresult.fromJson(response);
          rq.eventList[index].eventId = event.eventId;
          rq.eventList[index].id = event.id;
          rq.eventList[index].firstname = "";
          widgetRefresher.value = Utilities.getRandomString();
          if (createFor == 1) {
            Get.to(EventDetails(index)).then(
                (value) => widgetRefresher.value = Utilities.getRandomString());
          } else if (createFor == 2) {
            _clickedInterestedToggle(index);
          }
        },
        onFailure: () {});
  }

  showAlertDialogForEvent(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(LabelStr.lblOK),
      onPressed: () {
        Get.back();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        Messages.CVerifyEmail,
        style: TextStyle(fontFamily: MyFont.Poppins_medium, fontSize: 14),
      ),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: screenBgColor,
        child: Column(
          children: <Widget>[
            widget.createEventEnable
                ? InkWell(
                    child: Container(
                      margin: EdgeInsets.only(top: 13, right: 20, left: 20),
                      height: 32,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          shape: BoxShape.rectangle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: homeBorderColor,
                            width: 1.0,
                          )),
                      child: Center(
                          child: Text(
                        LabelStr.lblCreateEvent,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.44,
                            fontFamily: MyFont.Poppins_medium),
                      )),
                    ),
                    onTap: () {
                      rq.isEditEvent.value = false;
                      Get.to(CreateEvent());
                    },
                  )
                : SizedBox(
                    height: 1.0,
                  ),
            Container(
              key: intro.keys[0],
              height: 0,
              width: 0,
            ),
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
              ),
            ),
            Flexible(
                child: Obx(() => widgetRefresher.value == ''
                    ? widget.isExplore
                        ? Container(
                            color: containerColor,
                            height: double.infinity,
                            width: double.infinity,
                          )
                        : _homeSkeletonList()
                    : rq.eventList.length == 0
                        ? Container(
                            color: containerColor,
                            child: Widgets.dataNotFound())
                        : _feedList()))
          ],
        ));
  }

  _feedList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (!onLoadMore) {
            onLoadMore = true;
            if (!dataOver) {
              _callEventsApi();
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
            itemCount: dataOver ? rq.eventList.length : rq.eventList.length + 1,
            itemBuilder: (context, index) {
              return index == rq.eventList.length
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
                  : Container(
                      decoration: BoxDecoration(
                        color: containerColor,
                      ),
                      padding: EdgeInsets.all(
                        ScreenUtil().setHeight(20),
                      ),
                      margin:
                          EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              if (rq.eventList[index].eventId == 0) {
                                callCreateEvent(index, 1);
                              } else {
                                Get.to(EventDetails(index)).then((value) =>
                                    widgetRefresher.value =
                                        Utilities.getRandomString());
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CommonNetworkImage(
                                  imageUrl: rq.eventList[index].image,
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
                                        Text(
                                          rq.eventList[index].eventName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily:
                                                  MyFont.Poppins_semibold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          convertUtcToLocal(rq
                                              .eventList[index].startDate
                                              .toString()),
                                          style: TextStyle(
                                              fontFamily:
                                                  MyFont.poppins_regular,
                                              fontSize: 12,
                                              color: HexColor.textColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.32,
                            margin: EdgeInsets.only(bottom: 15, top: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                shape: BoxShape.rectangle,
                                color: darkBlue,
                                border:
                                    Border.all(color: HexColor.borderColor)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: coverImageUrl(
                                          rq.eventList[index].eventImages) ==
                                      ''
                                  ? Image.asset(
                                      MyImage.ic_preview,
                                      fit: BoxFit.cover,
                                    )
                                  : CommonImage(
                                      coverImageUrl(
                                          rq.eventList[index].eventImages),
                                      double.infinity,
                                      double.infinity),
                            ),
                          ),
                          InkWell(
                            onTap: () => Widgets.openMap(
                                rq.eventList[index].latitude,
                                rq.eventList[index].longitude),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: ScreenUtil().setHeight(20),
                                  width: ScreenUtil().setWidth(13),
                                  margin: EdgeInsets.only(
                                      right: dimen.marginMedium),
                                  child: SvgPicture.asset(MyImage.ic_map_pin),
                                ),
                                Flexible(
                                    child: Text(
                                  rq.eventList[index].address,
                                  maxLines: 3,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: MyFont.poppins_regular,
                                      color: Color.fromRGBO(214, 209, 218, 1)),
                                )),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              InkWell(
                                onTap: () => {
                                  if (rq.eventList[index].interestCount > 0)
                                    _callEventUserList(
                                        LabelStr.lblInterest, rq.eventList[index].eventId)
                                },
                                child: Text(
                                  rq.eventList[index].interestCount.toString() +
                                      " "+LabelStr.lblInterested,
                                  style: TextStyle(
                                      color: Color.fromRGBO(106, 206, 212, 1),
                                      fontSize: 12,
                                      fontFamily: MyFont.Poppins_medium),
                                ),
                              ),
                              Container(
                                child: InkWell(
                                  onTap: () => {
                                    if (rq.eventList[index].goliveCount > 0)
                                      _callEventUserList(
                                          LabelStr.lblGoLive, rq.eventList[index].eventId)
                                  },
                                  child: Text(
                                    rq.eventList[index].goliveCount.toString() +
                                        " "+LabelStr.lblGoin,
                                    style: TextStyle(
                                      fontFamily: MyFont.Poppins_medium,
                                      fontSize: 12,
                                      color: skyBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            child: Container(
                              margin: EdgeInsets.only(
                                top: 12,
                              ),
                              height: ScreenUtil().setHeight(32),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                shape: BoxShape.rectangle,
                                color: rq.eventList[index].interest
                                    ? Colors.white24
                                    : lightBlue,
                              ),
                              child: Center(
                                  child: Text(
                                LabelStr.lblInterested,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: MyFont.Poppins_medium),
                              )),
                            ),
                            onTap: () {
                              if (!rq.eventList[index].interest) {
                                if (rq.eventList[index].eventId == 0) {
                                  callCreateEvent(index, 2);
                                } else
                                  _clickedInterestedToggle(index);
                              }
                            },
                          ),
                        ],
                      ),
                    );
            },
          )),
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

  String convertUtcToLocal(String time) {
    DateTime fromUtc = DateFormat("yyyy-MM-dd HH:mm:ss").parse(time, true);
    final convertLocal = fromUtc.toLocal();
    var newFormat = DateFormat("EEE, dd MMM yyyy hh:mm aaa");
    String updatedDt = newFormat.format(convertLocal);
    return updatedDt;
  }

  String coverImageUrl(List<EventImage> imagelist) {
    String url = '';
    if (imagelist.length != 0) {
      imagelist.forEach((element) {
        if (element.fileType == LabelStr.lblCover) url = element.downloadlink;
      });
    }
    return url;
  }

  _clickedInterestedToggle(int index) {
    if (!rq.eventList[index].interest) {
      rq.eventList[index].interest = true;
      rq.eventList[index].interestCount++;
    } else {
      rq.eventList[index].interest = false;
    }

    _updateInterest({
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CeventId: rq.eventList[index].eventId,
      Parameters.CFavorite: rq.eventList[index].favorite,
      Parameters.CInterest: rq.eventList[index].interest,
      Parameters.CgoLive: rq.eventList[index].golive,
    });
  }

  _updateInterest(Map<String, dynamic> params) {
    RequestManager.postRequest(
        uri: endPoints.addEventInterest,
        body: params,
        isLoader: true,
        isFailedMessage: true,
        isSuccessMessage: true,
        onSuccess: (response) {
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: () {});
  }

  void _callEventUserList(String type, int eventId) {
    var body = {
      Parameters.CeventId: eventId,
      Parameters.CType: type,
    };
    RequestManager.postRequest(
        uri: endPoints.getUserListByEventType,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          var _userList = List<EventUserModel>.from(
              response.map((x) => EventUserModel.fromJson(x)));
          Widgets.usersBottomSheet(list: _userList);
        },
        onFailure: (error) {});
  }
}
