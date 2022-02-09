import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/EventUserModel.dart';
import 'package:totem_app/Models/FeedListDataModel.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Ui/Event/AboutEvent.dart';
import 'package:totem_app/Ui/Event/MemoriesEvent.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:get/get.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import 'CreateEvent.dart';

class EventDetails extends StatefulWidget {
  int index;

  EventDetails(this.index);

  @override
  _EventDetails createState() => _EventDetails();
}

class _EventDetails extends State<EventDetails> {
  var selectedSegmentOption = 0.obs;
  var isCollepsed = false.obs;

  List<Widget> pageList = [AboutEvent(), MemoriesEvent()];

  var coverImgUrl = ''.obs;

  @override
  void initState() {
    super.initState();
    if(widget.index != -1) {
      rq.eventDetails.value = rq.eventList[widget.index];
      rq.editEventIndex = widget.index;
    }
    if (rq.eventDetails.value.eventImages.length != 0) {
      for (int i = 0; i < rq.eventDetails.value.eventImages.length; i++) {
        if (rq.eventDetails.value.eventImages[i].fileType == LabelStr.lblCover)
          rq.coverUrl.value = rq.eventDetails.value.eventImages[i].downloadlink;
        if (rq.eventDetails.value.eventImages[i].fileType == LabelStr.lblMap)
          rq.mapUrl.value = rq.eventDetails.value.eventImages[i].downloadlink;
        if (rq.eventDetails.value.eventImages[i].fileType == LabelStr.lblHeadliners)
          rq.lineupUrl.value =
              rq.eventDetails.value.eventImages[i].downloadlink;
      }
    }
  }

  _updateInterest(Map<String, dynamic> params) {
    RequestManager.postRequest(
        uri: endPoints.addEventInterest,
        body: params,
        isFailedMessage: true,
        isSuccessMessage: false,
        onSuccess: (response) {
          if(widget.index != -1)
          rq.eventList[widget.index] = rq.eventDetails.value;
        },
        onFailure: () {});
  }

  _clickedFavoriteToggle() {
    rq.eventDetails.update((val) {
      val.favorite = val.favorite ? false : true;
    });
    _updateInterest({
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CeventId: rq.eventDetails.value.eventId,
      Parameters.CFavorite: rq.eventDetails.value.favorite,
      Parameters.CInterest: rq.eventDetails.value.interest,
      Parameters.CgoLive: rq.eventDetails.value.golive,
    });
  }

  _clickedInterestedToggle() {
    if (rq.eventDetails.value.interest) {
      rq.eventDetails.update((val) {
        val.interest = false;
        val.interestCount = val.interestCount - 1;
      });
    } else {
      rq.eventDetails.update((val) {
        val.interest = true;
        val.interestCount = val.interestCount + 1;
      });
    }
    _updateInterest({
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CeventId: rq.eventDetails.value.eventId,
      Parameters.CFavorite: rq.eventDetails.value.favorite,
      Parameters.CInterest: rq.eventDetails.value.interest,
      Parameters.CgoLive: rq.eventDetails.value.golive,
    });
  }

  _clickedGoinToggle() {
    if (rq.eventDetails.value.golive) {
      rq.eventDetails.update((val) {
        val.golive = false;
        val.goliveCount = val.goliveCount - 1;
      });
    } else {
      rq.eventDetails.update((val) {
        val.golive = true;
        val.goliveCount = val.goliveCount + 1;
      });
    }
    _updateInterest({
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CeventId: rq.eventDetails.value.eventId,
      Parameters.CFavorite: rq.eventDetails.value.favorite,
      Parameters.CInterest: rq.eventDetails.value.interest,
      Parameters.CgoLive: rq.eventDetails.value.golive,
    });
  }

  void _callEventUserList(String type) {
    var body = {
      Parameters.CeventId: rq.eventDetails.value.eventId,
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: true);
        return false;
      },
      child: Scaffold(
          backgroundColor: screenBgColor,
          body: Obx(
            () => rq.eventDetails.value.eventId == null
                ? Container()
                : DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            floating: false,
                            pinned: true,
                            snap: false,
                            backgroundColor: screenBgColor,
                            expandedHeight: 460.0,
                            flexibleSpace: LayoutBuilder(builder:
                                (BuildContext context,
                                    BoxConstraints constraints) {
                              isCollepsed.value =
                                  constraints.biggest.height <= 106.0;
                              return FlexibleSpaceBar(
                                  titlePadding: EdgeInsets.only(
                                      left: dimen.paddingExtra,
                                      right: dimen.paddingLarge,
                                      bottom: dimen.paddingSmall),
                                  centerTitle: false,
                                  title: Title(
                                      color: whiteTextColor,
                                      child: Obx(() => Container(
                                            padding: EdgeInsets.only(
                                                bottom: dimen.paddingMedium),
                                            child: Visibility(
                                              visible: isCollepsed.value,
                                              child: Text(
                                                rq.eventDetails.value.eventName
                                                        .isEmpty
                                                    ? ''
                                                    : rq.eventDetails.value
                                                        .eventName,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: whiteTextColor,
                                                  fontSize:
                                                      dimen.textExtraMedium,
                                                ),
                                              ),
                                            ),
                                          ))),
                                  background: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                            height: 260.0,
                                            alignment: Alignment(-0.60, 0.9),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              image: rq.coverUrl.value.isEmpty
                                                  ? AssetImage(
                                                      "assets/bg_image/preview.png",
                                                    )
                                                  : CachedNetworkImageProvider(
                                                      rq.coverUrl.value),
                                              fit: BoxFit.cover,
                                            )),
                                            child: Container(
                                              height: double.infinity,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                stops: [
                                                  0.1,
                                                  0.4,
                                                  0.7,
                                                  0.95,
                                                ],
                                                colors: [
                                                  Colors.black12,
                                                  Colors.black26,
                                                  Colors.black54,
                                                  Colors.black87,
                                                ],
                                              )),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal:
                                                            dimen.paddingLarge),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      rq.eventDetails.value
                                                              .eventName.isEmpty
                                                          ? ''
                                                          : rq.eventDetails
                                                              .value.eventName,
                                                      style: TextStyle(
                                                          color: whiteTextColor,
                                                          fontSize: dimen
                                                              .textExtraMedium,
                                                          fontFamily: MyFont
                                                              .Poppins_semibold),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      convertUtcToLocal(rq
                                                          .eventDetails
                                                          .value
                                                          .startDate
                                                          .toString()),
                                                      style: TextStyle(
                                                          color: whiteTextColor,
                                                          fontSize:
                                                              dimen.textSmall,
                                                          fontFamily: MyFont
                                                              .poppins_regular),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                        Container(
                                            color: screenBgLightColor,
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(
                                                      dimen.paddingExtraLarge),
                                                  child: Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: () =>
                                                            Widgets.openMap(
                                                                rq
                                                                    .eventDetails
                                                                    .value
                                                                    .latitude,
                                                                rq
                                                                    .eventDetails
                                                                    .value
                                                                    .longitude),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SvgPicture.asset(
                                                                MyImage
                                                                    .ic_map_pin),
                                                            Flexible(
                                                                child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                left: dimen
                                                                    .paddingSmall,
                                                              ),
                                                              child: Text(
                                                                rq
                                                                        .eventDetails
                                                                        .value
                                                                        .address
                                                                        .isEmpty
                                                                    ? ''
                                                                    : rq
                                                                        .eventDetails
                                                                        .value
                                                                        .address,
                                                                maxLines: 2,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily: MyFont
                                                                      .poppins_regular,
                                                                  fontSize: dimen
                                                                      .textNormal,
                                                                  color:
                                                                      textColorGreyLight,
                                                                ),
                                                              ),
                                                            ))
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            dimen.paddingSmall,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SvgPicture.asset(MyImage
                                                              .ic_goin_indicator),
                                                          Flexible(
                                                              child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: dimen
                                                                  .paddingSmall,
                                                            ),
                                                            child: Row(
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      if (rq.eventDetails.value
                                                                              .interestCount >
                                                                          0)
                                                                        _callEventUserList(
                                                                            LabelStr.lblInterest);
                                                                    },
                                                                    child: Text(
                                                                      rq.eventDetails.value
                                                                              .interestCount
                                                                              .toString() +
                                                                          ' ${LabelStr.lblInterested}',
                                                                      style: TextStyle(
                                                                          fontFamily: MyFont
                                                                              .poppins_regular,
                                                                          fontSize: dimen
                                                                              .textNormal,
                                                                          color:
                                                                              textColorGreyLight),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    ' | ',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            MyFont
                                                                                .poppins_regular,
                                                                        fontSize:
                                                                            dimen
                                                                                .textNormal,
                                                                        color:
                                                                            textColorGreyLight),
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      if (rq.eventDetails.value
                                                                              .goliveCount >
                                                                          0)
                                                                        _callEventUserList(
                                                                            LabelStr.lblGoLive);
                                                                    },
                                                                    child: Text(
                                                                      rq.eventDetails.value
                                                                              .goliveCount
                                                                              .toString() +
                                                                          ' ${LabelStr.lblGoin}',
                                                                      style: TextStyle(
                                                                          fontFamily: MyFont
                                                                              .poppins_regular,
                                                                          fontSize: dimen
                                                                              .textNormal,
                                                                          color:
                                                                              textColorGreyLight),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ))
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            dimen.paddingSmall,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SvgPicture.asset(MyImage
                                                              .ic_event_name_flag),
                                                          Flexible(
                                                              child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: dimen
                                                                  .paddingSmall,
                                                            ),
                                                            child: rq
                                                                    .eventDetails
                                                                    .value
                                                                    .firstname
                                                                    .isEmpty
                                                                ? Text(
                                                                    LabelStr.lblEventByUnknown,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            MyFont
                                                                                .poppins_regular,
                                                                        fontSize:
                                                                            dimen
                                                                                .textNormal,
                                                                        color:
                                                                            textColorGreyLight),
                                                                  )
                                                                : Widgets
                                                                    .userNameWithIndicator(
                                                                        OpenProfileNeedDataModel(
                                                                            rq.eventDetails.value
                                                                                .id,
                                                                            rq.eventDetails.value.firstname +
                                                                                " " +
                                                                                rq
                                                                                    .eventDetails.value.lastname,
                                                                            rq.eventDetails.value
                                                                                .username,
                                                                            rq.eventDetails.value
                                                                                .profileVerified,
                                                                            rq.eventDetails.value
                                                                                .image),
                                                                        fontFamily:
                                                                            MyFont
                                                                                .poppins_regular,
                                                                        textSize:
                                                                            dimen
                                                                                .textNormal,
                                                                        color:
                                                                            textColorGreyLight),
                                                          ))
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                  height: dimen
                                                      .dividerHeightVerySmall,
                                                  color:
                                                      createEventReviewDividerColor,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      left: dimen
                                                          .paddingExtraLarge,
                                                      right: dimen
                                                          .paddingExtraLarge,
                                                      top: dimen.paddingMedium,
                                                      bottom:
                                                          dimen.paddingMedium),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      InkWell(
                                                        onTap: (() {
                                                          _clickedFavoriteToggle();
                                                        }),
                                                        child: Column(
                                                          children: [
                                                            SvgPicture.asset(
                                                              rq.eventDetails.value
                                                                      .favorite
                                                                  ? MyImage
                                                                      .ic_heart_filled
                                                                  : MyImage
                                                                      .ic_heart_outline,
                                                              color:
                                                                  appColorDefaultLight,
                                                              height: dimen
                                                                  .appBarActionIconHeight,
                                                              width: dimen
                                                                  .appBarActionIconWidth,
                                                            ),
                                                            Text(
                                                              LabelStr
                                                                  .lblFavorite,
                                                              style: TextStyle(
                                                                  fontFamily: MyFont
                                                                      .poppins_regular,
                                                                  fontSize: dimen
                                                                      .textNormal,
                                                                  color:
                                                                      textColorGreyLight),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: (() {
                                                          _clickedInterestedToggle();
                                                        }),
                                                        child: Column(
                                                          children: [
                                                            SvgPicture.asset(
                                                              rq.eventDetails.value
                                                                      .interest
                                                                  ? MyImage
                                                                      .ic_star_filled
                                                                  : MyImage
                                                                      .ic_star_outline,
                                                              color:
                                                                  appColorDefaultLight,
                                                              height: dimen
                                                                  .appBarActionIconHeight,
                                                              width: dimen
                                                                  .appBarActionIconWidth,
                                                            ),
                                                            Text(
                                                              LabelStr
                                                                  .lblInterested,
                                                              style: TextStyle(
                                                                  fontFamily: MyFont
                                                                      .poppins_regular,
                                                                  fontSize: dimen
                                                                      .textNormal,
                                                                  color:
                                                                      textColorGreyLight),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: (() {
                                                          _clickedGoinToggle();
                                                        }),
                                                        child: Column(
                                                          children: [
                                                            SvgPicture.asset(
                                                              rq.eventDetails.value
                                                                      .golive
                                                                  ? MyImage
                                                                      .ic_tick_unfilled
                                                                  : MyImage
                                                                      .ic_tick_outline,
                                                              color:
                                                                  appColorDefaultLight,
                                                              height: dimen
                                                                  .appBarActionIconHeight,
                                                              width: dimen
                                                                  .appBarActionIconWidth,
                                                            ),
                                                            Text(
                                                              LabelStr.lblGoin,
                                                              style: TextStyle(
                                                                  fontFamily: MyFont
                                                                      .poppins_regular,
                                                                  fontSize: dimen
                                                                      .textNormal,
                                                                  color:
                                                                      textColorGreyLight),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ))
                                      ],
                                    ),
                                  ));
                            }),
                            leading: Container(
                              child: IconButton(
                                icon: SvgPicture.asset(MyImage.ic_arrow),
                                onPressed: () => Get.back(result: true),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(40)),
                            ),
                            actions: <Widget>[
                              rq.eventDetails.value.id == SessionImpl.getId()
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          right: dimen.paddingSmall),
                                      child: Container(
                                        child: IconButton(
                                          icon: SvgPicture.asset(
                                            MyImage.ic_addedit,
                                            color: whiteTextColor,
                                            height:
                                                dimen.appBarActionIconHeight,
                                            width: dimen.appBarActionIconWidth,
                                          ),
                                          tooltip: LabelStr.lblAddEdit,
                                          onPressed: () {
                                            rq.isEditEvent.value = true;
                                            Get.to(CreateEvent());
                                          },
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.black26,
                                            borderRadius:
                                                BorderRadius.circular(40)),
                                      ))
                                  : Container(),
                            ],
                          ),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate:
                                _SliverAppBarDelegate(sliderSegementView()),
                          ),
                        ];
                      },
                      body: bottomView(),
                    ),
                  ),
          )),
    );
  }

  Widget bottomView() {
    return Obx(() =>
        selectedSegmentOption.value == 0 ? AboutEvent() : MemoriesEvent());
  }

  Widget sliderSegementView() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
      ),
      child: Container(
          padding: EdgeInsets.only(
              left: dimen.paddingVerySmall, right: dimen.paddingVerySmall),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              border: Border.all(color: HexColor.hintColor, width: 1),
              borderRadius: BorderRadius.circular(8)),
          child: Obx(() => Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: (() => {selectedSegmentOption.value = 0}),
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.all(dimen.paddingVerySmall / 2),
                        decoration: selectedSegmentOption.value != 0
                            ? null
                            : BoxDecoration(
                                border: Border.all(
                                    color: HexColor.hintColor, width: 1),
                                borderRadius: BorderRadius.circular(8),
                                color: tabActiveColor,
                              ),
                        child: Center(
                          child: Text(
                            'About',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // fontWeight: FontWeight.w800,
                              fontFamily: MyFont.Poppins_medium,
                              fontSize: dimen.textNormal,
                              color: (selectedSegmentOption.value == 0)
                                  ? Colors.white
                                  : blueGrayColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        selectedSegmentOption.value = 1;
                      },
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.all(dimen.paddingVerySmall / 2),
                        decoration: selectedSegmentOption.value != 1
                            ? null
                            : BoxDecoration(
                                border: Border.all(
                                    color: HexColor.hintColor, width: 1),
                                borderRadius: BorderRadius.circular(8),
                                color: tabActiveColor,
                              ),
                        child: Center(
                          child: Text(LabelStr.lblMemories,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                // fontWeight: FontWeight.w800,
                                fontFamily: MyFont.Poppins_medium,
                                fontSize: 14,
                                color: (selectedSegmentOption.value == 1)
                                    ? Colors.white
                                    : blueGrayColor,
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }

  String convertUtcToLocal(String time) {
    DateTime fromUtc = DateFormat("yyyy-MM-dd HH:mm:ss").parse(time, true);
    final convertLocal = fromUtc.toLocal();

    var newFormatDate = DateFormat("EEE, dd MMM");
    var newFormatDateWithYear = DateFormat("EEE, dd MMM yyyy");
    var newFormatTime = DateFormat("hh:mm aaa");
    var year = DateFormat("yyyy");

    String updatedDate = '';
    if (year.format(convertLocal) == year.format(DateTime.now()))
      updatedDate = newFormatDateWithYear.format(convertLocal);
    else
      updatedDate = newFormatDate.format(convertLocal);

    String updatedTme = newFormatTime.format(convertLocal);

    return "$updatedDate at $updatedTme";
  }

  List<FeedListDataModel> _listMemories = [];
  var widgetRefresherMemories = ''.obs;

  void generateSizeArrayMemories() {
    int counter = (_listMemories.length / 6).ceil();
    _sizesMemories.clear();
    for (var i = 0; i < counter; i++) {
      _sizesMemories.addAll(_sizeSample);
    }
  }

  List<String> _sizesMemories = [];

  final List<String> _sizeSample = ["2,1", "1,2", "1,1", "1,2", "1,1", "1,1"];
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Widget _tabBar;

  @override
  double get minExtent => 50.0;

  @override
  double get maxExtent => 50.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: screenBgColor,
      height: 50,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
