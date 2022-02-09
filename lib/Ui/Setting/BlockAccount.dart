import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/Product.dart';
import 'package:get/get.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Ui/Customs/CommonNetworkImage.dart';
import 'package:totem_app/Ui/Customs/ItemSkeleton.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

class BlockAccount extends StatefulWidget {
  @override
  _BlockAccountState createState() => _BlockAccountState();
}

class _BlockAccountState extends State<BlockAccount> {
  List<SuggestedUser> _list = [];
  var onLoadMore = true;
  var dataOver = false;
  var widgetRefresher = "".obs;
  static const int perPage = 10;

  @override
  void initState() {
    super.initState();
    LogicalComponents.suggestedUsersModel.pageNumber = 0;
    LogicalComponents.suggestedUsersModel.pageSize = perPage;
    LogicalComponents.suggestedUsersModel.totalRecords = 0;
    _callGetBlockuserApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBgColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(49),
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(dimen.paddingForBackArrow),
                      child: SvgPicture.asset(MyImage.ic_arrow),
                    )),
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        LabelStr.lblBlockAccount,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: MyFont.Poppins_semibold,
                            color: Colors.white),
                      ),
                    ))
              ],
            ),
          ),
          SizedBox(
            height: dimen.paddingExtraLarge,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(29),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)),
                  color: Color.fromRGBO(31, 28, 50, 1)),
              padding: EdgeInsets.all(20),
              child: Obx(() => widgetRefresher.value == ''
                  ? _skeletonList()
                  : _list.length == 0
                      ? Widgets.dataNotFound()
                      : _blocklist()),
            ),
          ),
        ],
      ),
    );
  }

  _skeletonList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return ItemSkeleton();
        });
  }

  void _callGetBlockuserApi() {
    LogicalComponents.suggestedUsersModel.pageNumber++;
    var body = {
      Parameters.CpageNumber: LogicalComponents.suggestedUsersModel.pageNumber,
      Parameters.CpageSize: LogicalComponents.suggestedUsersModel.pageSize,
      Parameters.Csearch: " ",
      Parameters.CtotalRecords:
          LogicalComponents.suggestedUsersModel.totalRecords,
      Parameters.Cid: SessionImpl.getId()
    };

    RequestManager.postRequest(
        uri: endPoints.GetBlockuser,
        body: body,
        isLoader: false,
        isSuccessMessage: false,
        isFailedMessage: false,
        onSuccess: (response) {
          onLoadMore = false;
          LogicalComponents.suggestedUsersModel =
              SuggestedUsersModel.fromJson(response);
          //check data is over
          if ((LogicalComponents.suggestedUsersModel.pageNumber *
                  LogicalComponents.suggestedUsersModel.pageSize) <
              LogicalComponents.suggestedUsersModel.totalRecords) {
            dataOver = false;
          } else {
            dataOver = true;
          }
          if (LogicalComponents.suggestedUsersModel.pageNumber == 1) {
            _list.clear();
          }
          if (LogicalComponents.suggestedUsersModel.data != null &&
              LogicalComponents.suggestedUsersModel.data.isNotEmpty) {
            _list.addAll(LogicalComponents.suggestedUsersModel.data);

            widgetRefresher.value = Utilities.getRandomString();
          }
        },
        onFailure: (error) {
          onLoadMore = false;
          if (LogicalComponents.suggestedUsersModel.pageNumber == 1) {
            dataOver = true;
            _list.clear();
            widgetRefresher.value = Utilities.getRandomString();
          }
        });
  }

  _blocklist() {
    return ListView.builder(
      shrinkWrap: true,
      restorationId: widgetRefresher.value,
      padding: EdgeInsets.all(0),
      itemCount: _list.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              top: dimen.paddingExtraLarge,
              left: dimen.paddingLarge,
              right: dimen.paddingLarge),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CommonNetworkImage(
                    radius: 20,
                    width: 40,
                    height: 40,
                    imageUrl: _list[index].image,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: dimen.paddingLarge),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _list[index].username,
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: MyFont.Poppins_semibold,
                                color: Colors.white),
                          ),
                          Text(
                            _list[index].mutualCount > 0
                                ? (_list[index].mutualCount.toString() +
                                    " ${LabelStr.lblMutualConnection}")
                                : LabelStr.lblNoMutualConnection,
                            style: TextStyle(
                                fontFamily: MyFont.poppins_regular,
                                fontSize: 10,
                                color: HexColor.textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _callBlockUser(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        shape: BoxShape.rectangle,
                        color: boxColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: dimen.paddingVerySmall,
                            bottom: dimen.paddingVerySmall,
                            left: dimen.paddingExtraLarge,
                            right: dimen.paddingExtraLarge),
                        child: Center(
                          child: Text(
                            LabelStr.lblUnblock,
                            style: TextStyle(
                                fontFamily: MyFont.Poppins_medium,
                                fontSize: 12,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: dimen.paddingExtraLarge,
              ),
              Divider(
                color: dividerLineColor,
              ),
            ],
          ),
        );
      },
    );
  }

  void _callBlockUser(int index) {
    var body = {
      Parameters.Cid: SessionImpl.getId(),
      Parameters.CblockId: _list[index].id,
    };
    RequestManager.postRequest(
        uri: endPoints.BlockUser,
        body: body,
        isLoader: true,
        isSuccessMessage: false,
        onSuccess: (response) {
          //Get.back();
          _list.removeAt(index);
          widgetRefresher.value = Utilities.getRandomString();
          RequestManager.getSnackToast(
            message: Messages.CUnblocked,
            title: "Unblocked",
            backgroundColor: Colors.black,
          );
        },
        onFailure: (error) {});
  }
}
