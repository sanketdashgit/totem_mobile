import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/FeedListDataModel.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class ProfileMemories extends StatefulWidget {
  const ProfileMemories({Key key}) : super(key: key);

  @override
  _ProfileMemoriesState createState() => _ProfileMemoriesState();
}

class _ProfileMemoriesState extends State<ProfileMemories> {
  var onLoadMore = true;
  var dataOver = false;
  int pageNumber = 0;
  int totalRecords = 0;
  var widgetRefresher = ''.obs;

  void _callMemoriesApi() {
    pageNumber++;
    var body = {
      Parameters.CpageNumber: pageNumber,
      Parameters.CpageSize: global.PAGE_SIZE,
      Parameters.Csearch: '',
      Parameters.CtotalRecords: totalRecords,
      Parameters.CeventId: 0,
      Parameters.Cid: SessionImpl.getId(),
    };
    RequestManager.postRequest(
        uri: endPoints.GetFeedList,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          onLoadMore = false;
          if ((response['data'] as List<dynamic>).isNotEmpty) {
            pageNumber = response['pageNumber'];
            totalRecords = response['totalRecords'];
            if ((pageNumber * global.PAGE_SIZE) < totalRecords) {
              dataOver = false;
            } else {
              dataOver = true;
            }
            if (pageNumber == 1) {
              rq.homeFeedList.clear();
            }
            var temp = List<FeedListDataModel>.from(
                response['data'].map((x) => FeedListDataModel.fromJson(x)));
            rq.homeFeedList.addAll(temp);
            widgetRefresher.value = Utilities.getRandomString();
          } else {
            if (pageNumber == 1) {
              dataOver = true;
              rq.homeFeedList.clear();
              widgetRefresher.value = Utilities.getRandomString();
            }
          }
        },
        onFailure: (error) {
          onLoadMore = false;
          if (pageNumber == 1) {
            dataOver = true;
            rq.homeFeedList.clear();
            widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      staggeredTileBuilder: (int index) => StaggeredTile.count(
          int.parse(_sizes[index].split(",")[0]),
          double.parse(_sizes[index].split(",")[1])),
      itemBuilder: _getChild,
      itemCount: 6,
    );
  }

  final List<String> _sizes = [
    "2,1",
    "1,2",
    "1,1",
    "1,2",
    "1,1",
    "1,1",
  ];

  Widget _getChild(BuildContext context, int index) {
    return Container(
        color: Colors.green,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: index.isEven
                      ? AssetImage(
                          "assets/bg_image/explore_img_two.png",
                        )
                      : AssetImage("assets/bg_image/explore_img_one.png"),
                  fit: BoxFit.cover)),
          child: new Center(
            child: new Text(
              '$index',
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: MyFont.Poppins_medium,
                  color: Colors.white),
            ),
          ),
        ));
  }
}
