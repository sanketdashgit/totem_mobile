import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/FeedListDataModel.dart';
import 'package:totem_app/Ui/Profile/PostListing.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';



class MemoriesEvent extends StatefulWidget {
  int selectedSegmentOption = 0;

  @override
  _MemoriesEventState createState() => _MemoriesEventState();
}

class _MemoriesEventState extends State<MemoriesEvent> {

  List<FeedListDataModel> _listMemories = [];
  var widgetRefresherMemories = ''.obs;
  void generateSizeArrayMemories(){
    int counter = (_listMemories.length/6).ceil();
    _sizesMemories.clear();
    for(var i =0;i < counter;i++){
      _sizesMemories.addAll(_sizeSample);
    }
  }
  List<String> _sizesMemories = [];

  final List<String> _sizeSample = ["2,1",
    "1,2",
    "1,1",
    "1,2",
    "1,1",
    "1,1"];

  void _loadMemoriesData() {
    var body = {
      Parameters.CpageNumber: 1,
      Parameters.CpageSize: 100,
      Parameters.Csearch: '',
      Parameters.CtotalRecords: 0,
      Parameters.CeventId: rq.eventDetails.value.eventId,
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CGetSelf: 0,
    };
    RequestManager.postRequest(
        uri: endPoints.GetFeedList,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          _listMemories.clear();
          var temp = List<FeedListDataModel>.from(
              response['data'].map((x) => FeedListDataModel.fromJson(x)));
          _listMemories.addAll(temp);
          generateSizeArrayMemories();
          widgetRefresherMemories.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }
  @override
  void initState() {
    super.initState();
    _loadMemoriesData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: dimen.paddingExtraLarge,
        right: dimen.paddingExtraLarge,
      top: dimen.paddingLarge),
      child: Obx(() =>
      widgetRefresherMemories.value == '' ? Container() : _listMemories.length == 0 ? Widgets.dataNotFound() : ClipRRect(
        borderRadius: BorderRadius.circular(dimen.radiusNormal),
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          staggeredTileBuilder: (int index) => StaggeredTile.count(
              int.parse(_sizesMemories[index].split(",")[0]),
              double.parse(_sizesMemories[index].split(",")[1])),
          itemBuilder: _getChildMemories,
          itemCount: _listMemories.length,
        ),
      )),
    );
  }


  Widget _getChildMemories(BuildContext context, int index) {
    return InkWell(
      onTap: (){
        Get.to(PostListing(0, _listMemories[index].eventName, SessionImpl.getId(),_listMemories[index].eventId));
      },
      child: Container(
          color: Colors.green,
          child: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                child: CachedNetworkImage(
                    imageUrl: _listMemories.length > 0 ? (_listMemories[index].postMediaLinks.length != 0
                        ? _listMemories[index].postMediaLinks[0].downloadlink
                        : '') : '',
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        Image.asset(MyImage.ic_preview,
                            fit: BoxFit.cover),
                    errorWidget: (context, url, error) => Image.asset(
                        MyImage.ic_preview,
                        fit: BoxFit.cover)),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  _listMemories.length > 0 ? _listMemories[index].username : '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: MyFont.Poppins_semibold,
                      color: Colors.white),
                ),
              )

            ],
          )),
    );
  }
}
