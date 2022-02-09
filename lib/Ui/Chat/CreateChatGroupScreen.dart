import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_app/GeneralUtils/Alertview.dart';
import 'package:totem_app/GeneralUtils/ColorExtension.dart';
import 'package:totem_app/GeneralUtils/CommonStuff.dart';
import 'package:totem_app/GeneralUtils/Constant.dart';
import 'package:totem_app/GeneralUtils/FirestoreService.dart';
import 'package:totem_app/GeneralUtils/LabelStr.dart';
import 'package:totem_app/Models/ConversationListModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Models/UserModel.dart';
import 'package:totem_app/Utility/Impl/global.dart';
import 'package:totem_app/Utility/Impl/sessionImpl.dart';
import 'package:totem_app/Utility/Impl/utilitiesimpl.dart';
import 'package:totem_app/Utility/UI/ColorPallete.dart';
import 'package:totem_app/Utility/UI/Widgets.dart';
import 'package:totem_app/WebService/RequestManager.dart';

import 'ChatDetailScreen.dart';

class CreateChatGroupScreen extends StatefulWidget {
  List<SuggestedUser> groupMemberList;
  Map<String, dynamic> groupInfo;
  List<int> groupMembersIds;

  CreateChatGroupScreen(
      {this.groupMemberList, this.groupInfo, this.groupMembersIds});

  @override
  _CreateChatGroupScreenState createState() => _CreateChatGroupScreenState();
}

class _CreateChatGroupScreenState extends State<CreateChatGroupScreen> {
  RxString pickedGroupPic = ''.obs;
  var txtGroupName = TextEditingController();
  var listRefresher = "".obs;
  var isButtonLoaderEnabled = false.obs;

  @override
  initState() {
    super.initState();

    if (widget.groupInfo != null) {
      txtGroupName.text = widget.groupInfo[Parameters.CGroupName];
      pickedGroupPic.value = widget.groupInfo[Parameters.CGroupProfile];
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: screenBgColor, body: createGroupView());
  }

  Widget createGroupView() {
    return Obx(() => AbsorbPointer(
          absorbing: (isButtonLoaderEnabled.value == false) ? false : true,
          child: Container(
            margin: EdgeInsets.only(top: ScreenUtil().setWidth(50)),
            child: Column(
              children: [
                appBarView(),
                groupProfileImgView(),
                groupNameTextView(),
                groupMemberListHeaderView(),
                groupMemberList()
              ],
            ),
          ),
        ));
  }

  Widget appBarView() {
    return SizedBox(
        width: screenWidth(context),
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(
                right: ScreenUtil().setWidth(20),
                left: ScreenUtil().setWidth(20)),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.back(result: widget.groupMemberList);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(dimen.paddingForBackArrow),
                    child: SvgPicture.asset(MyImage.ic_arrow),
                  ),
                ),
                Expanded(
                    child: Center(
                  child: Text(
                    LabelStr.lblCreateGroup,
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: MyFont.Poppins_semibold,
                        color: Colors.white),
                  ),
                )),
                Obx(
                  () => InkWell(
                    onTap: () {
                      pressedOnCreateGroup();
                    },
                    child: (isButtonLoaderEnabled.value == true)
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            LabelStr.lblCreate,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(14),
                                fontFamily: MyFont.poppins_regular,
                                color: Colors.white),
                          ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(16)),
            child: Container(
              height: 1,
              color: purpleDimColor,
            ),
          )
        ]));
  }

  Widget groupProfileImgView() {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
      child: Center(
        child: Stack(
          children: [
            Obx(
              () => CircleAvatar(
                radius: ScreenUtil().setWidth(50),
                backgroundImage: pickedGroupPic.value == ''
                    ? AssetImage(MyImage.ic_dummy_profile)
                    : FileImage(File(pickedGroupPic.value)),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context, builder: ((builder) => bottomSheet()));
                },
                child: Container(
                  width: ScreenUtil().setWidth(30),
                  height: ScreenUtil().setWidth(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: buttonPrimary,
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(dimen.paddingSmall),
                      child: SvgPicture.asset(MyImage.ic_camera)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget groupNameTextView() {
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          top: ScreenUtil().setHeight(30),
          right: 20,
          bottom: ScreenUtil().setHeight(20)),
      child: TextField(
        controller: txtGroupName,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
            fontSize: ScreenUtil().setSp(14),
            fontFamily: MyFont.poppins_regular,
            color: Colors.white),
        decoration: InputDecoration(
          isDense: true,
          hintText: LabelStr.lblCreateGroupName,
          hintStyle: TextStyle(
              fontSize: ScreenUtil().setSp(14),
              fontFamily: MyFont.poppins_regular,
              color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: chatTextBorderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: chatTextBorderColor, width: 1),
          ),
        ),
      ),
    );
  }

  Widget groupMemberListHeaderView() {
    return Container(
        color: chatTextBorderColor,
        width: screenWidth(context),
        height: ScreenUtil().setHeight(40),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LabelStr.CGroupMember,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(14),
                    fontFamily: MyFont.poppins_regular,
                    color: Colors.white),
              ),
              InkWell(
                onTap: () {
                  Get.back(result: {
                    LabelStr.lblGroupMemberList: widget.groupMemberList,
                    LabelStr.lblGroupInfo: {
                      Parameters.CGroupName: txtGroupName.text,
                      Parameters.CGroupProfile: pickedGroupPic.value
                    },
                    LabelStr.lblGroupMemberIds: widget.groupMembersIds
                  });
                },
                child: SvgPicture.asset(MyImage.ic_group),
              ),
            ],
          ),
        ));
  }

  Widget groupMemberList() {
    return Expanded(
        child: Obx(
      () => ListView.builder(
          padding: EdgeInsets.zero,
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.groupMemberList.length,
          restorationId: listRefresher.value,
          itemBuilder: (context, index) {
            return groupMemberInfoCardView(widget.groupMemberList[index]);
          }),
    ));
  }

  Widget groupMemberInfoCardView(SuggestedUser userInfo) {
    return Padding(
      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(40) / 2),
                  child: CachedNetworkImage(
                      imageUrl: userInfo.image,
                      fit: BoxFit.fill,
                      width: ScreenUtil().setWidth(40),
                      height: ScreenUtil().setWidth(40),
                      errorWidget: (context, url, error) => Image.asset(
                          "assets/bg_image/profile-pic-dummy.png",
                          fit: BoxFit.fill))),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  userInfo.username,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(12),
                      fontFamily: MyFont.Poppins_semibold,
                      color: Colors.white),
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  pressedOnRemoveGroupMember(userInfo);
                },
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Image(
                    image: AssetImage('assets/icons/ic_remove.png'),
                    width: ScreenUtil().setWidth(20),
                    height: ScreenUtil().setWidth(20),
                  ),
                ),
                splashColor: Colors.transparent,
              ),
            ],
          ),
          Container(
            height: 1,
            color: purpleDimColor,
          ),
        ],
      ),
    );
  }

  pressedOnRemoveGroupMember(SuggestedUser userInfo) {
    widget.groupMembersIds.remove(userInfo.id);
    widget.groupMemberList.remove(userInfo);
    listRefresher.value = Utilities.getRandomString();
  }

  pressedOnCreateGroup() {
    if (txtGroupName.text.isEmpty) {
      RequestManager.getSnackToast(message: Messages.CEnterGroupName);
      return;
    } else if (pickedGroupPic.value == '') {
      RequestManager.getSnackToast(message: Messages.CChooseGroupPic);
      return;
    } else if (widget.groupMemberList.length == 0) {
      RequestManager.getSnackToast(message: Messages.CSelectGroupMember);
      return;
    }

    var users = widget.groupMemberList.map((user) {
      return {
        Parameters.CUserId: user.id,
        Parameters.CuserName: user.username,
        Parameters.CUserProfile: user.image,
        Parameters.CFirstName: user.firstname,
        Parameters.CLastName: user.lastname,
      };
    }).toList();
    users.add({
      Parameters.CUserId: SessionImpl.getId(),
      Parameters.CuserName: SessionImpl.getName(),
      Parameters.CUserProfile:
          (SessionImpl.getLoginProfileModel() as UserInfoModel).image,
      Parameters.CFirstName:
          (SessionImpl.getLoginProfileModel() as UserInfoModel).firstname,
      Parameters.CLastName:
          (SessionImpl.getLoginProfileModel() as UserInfoModel).lastname,
    });

    var unreadCounts = widget.groupMemberList.map((user) {
      return {Parameters.CUserId: user.id, Parameters.CCount: 0};
    }).toList();
    unreadCounts
        .add({Parameters.CUserId: SessionImpl.getId(), Parameters.CCount: 0});

    var usersID = widget.groupMembersIds;
    usersID.add(SessionImpl.getId());

    Map<String, dynamic> groupInfo = {
      Parameters.CGroupName: txtGroupName.text,
      Parameters.CGroupProfile: '',
      Parameters.CMessage: '',
      Parameters.CTimestamp: DateTime.now().millisecondsSinceEpoch,
      Parameters.CVideoURL: '',
      Parameters.CTypeMesage: MessageType.CText,
      Parameters.CSenderID: SessionImpl.getId(),
      Parameters.CUsers: users,
      Parameters.CUsersID: usersID,
      Parameters.CUnreadCount: unreadCounts,
      Parameters.CChatType: ChatType.CGroup,
      Parameters.CIsDeleted: false
    };

    isButtonLoaderEnabled.value = true;
    // Widgets.showLoading();
    FirestoreService().createGroupChat(groupInfo, File(pickedGroupPic.value),
        (snapshot, error) {
      isButtonLoaderEnabled.value = false;

      DocumentSnapshot documentSnapshot = snapshot;
      var conversationInfoModel =
          ConversationInfoModel.fromJson(documentSnapshot);

      Get.back();
      Get.back();

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          conversationInfoModel.conversationId,
          null,
          conversationInfoModel: conversationInfoModel,
        ),
      ));
    });
  }

  Widget bottomSheet() {
    return Container(
      height: ScreenUtil().setHeight(100),
      width: MediaQuery.of(context).size.width,
      color: screenBgColor,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Text(
            LabelStr.CChooseGroupPicture,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(16), color: whiteTextColor),
          ),
          SizedBox(
            height: 5,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera),
              onPressed: () {
                Get.back();
                getPickImage(ImageSource.camera);
              },
              label: Text(LabelStr.lblCamera),
            ),
            TextButton.icon(
              icon: Icon(Icons.image),
              onPressed: () {
                Get.back();
                getPickImage(ImageSource.gallery);
              },
              label: Text(LabelStr.lblGallery),
            ),
          ])
        ],
      ),
    );
  }

  getPickImage(ImageSource source) async {
    final image =
        await ImagePicker().getImage(source: source, imageQuality: 75);
    cropImage(image).then((imagePath) => pickedGroupPic.value = imagePath);
  }
}
