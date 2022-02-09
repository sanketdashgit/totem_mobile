import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/FeedListDataModel.dart';
import 'package:get/get.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/WebService/RequestManager.dart';
import 'package:totem_app/Utility/Impl/global.dart';

class ProfilePostPage extends StatefulWidget {
  const ProfilePostPage(this.id);

  final id;

  @override
  _ProfilePostPageState createState() => _ProfilePostPageState();
}

class _ProfilePostPageState extends State<ProfilePostPage> {
  List<FeedListDataModel> _list = [];
  var widgetRefresher = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  void _loadPostData() {
    var body = {Parameters.Cid: widget.id};
    RequestManager.postRequest(
        uri: endPoints.GetUsersPost,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          var temp = List<FeedListDataModel>.from(
              response.map((x) => FeedListDataModel.fromJson(x)));
          _list.addAll(temp);
          generateSizeArray();
          widgetRefresher.value = Utilities.getRandomString();
        },
        onFailure: (error) {});
  }

  void generateSizeArray() {
    int counter = (_list.length / 6).ceil();
    for (var i = 0; i < counter; i++) {
      _sizes.addAll(_sizeSample);
    }
  }

  List<String> _sizes = [];

  final List<String> _sizeSample = ["2,1", "1,2", "1,1", "1,2", "1,1", "1,1"];

  @override
  Widget build(BuildContext context) {
    return Obx(() => widgetRefresher.value == ''
        ? SliverStaggeredGrid.count(crossAxisCount: 1)
        : SliverStaggeredGrid.countBuilder(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            staggeredTileBuilder: (int index) => StaggeredTile.count(
                int.parse(_sizes[index].split(",")[0]),
                double.parse(_sizes[index].split(",")[1])),
            itemBuilder: _getChild,
            itemCount: 6,
          ));
  }

  Widget _getChild(BuildContext context, int index) {
    return Container(
        color: Colors.green,
        child: Stack(
          children: [
            CachedNetworkImage(
                imageUrl: _list[index].postMediaLinks.length != 0
                    ? _list[index].postMediaLinks[0].downloadlink
                    : '',
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Image.asset(MyImage.ic_preview, fit: BoxFit.cover),
                errorWidget: (context, url, error) =>
                    Image.asset(MyImage.ic_preview, fit: BoxFit.cover)),
          ],
        ));
  }
}
