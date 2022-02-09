// To parse this JSON data, do
//
//     final feedListDataModel = feedListDataModelFromJson(jsonString);

import 'dart:convert';

import 'package:totem_app/Models/PostCommentModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';

FeedListDataModel feedListDataModelFromJson(String str) => FeedListDataModel.fromJson(json.decode(str));

String feedListDataModelToJson(FeedListDataModel data) => json.encode(data.toJson());

class FeedListDataModel {
  FeedListDataModel({
    this.postId,
    this.caption,
    this.noOfLikes,
    this.noOfThumbs,
    this.noOfComments,
    this.selfLiked,
    this.selfThumbed,
    this.selfCommented,
    this.postMediaLinks,
    this.eventId,
    this.id,
    this.isActive,
    this.isDeleted,
    this.createdDate,
    this.isPrivate,
    this.firstname,
    this.lastname,
    this.username,
    this.image,
    this.userIsActive,
    this.profileVerified,
    this.eventName,
    this.startDate,
    this.endDate,
    this.address,
    this.details,
    this.eventCreatdate,
    this.eventisActive,
    this.longitude,
    this.latitude,
    this.eventImages,
    this.postComments,
    this.actionActiveTab,
    this.tagUsers
  });

  int postId;
  String caption;
  int noOfLikes;
  int noOfThumbs;
  int noOfComments;
  int selfLiked;
  bool selfThumbed;
  bool selfCommented;
  List<PostMediaLink> postMediaLinks;
  int eventId;
  int id;
  int isActive;
  bool isDeleted;
  String createdDate;
  bool isPrivate;
  String firstname;
  String lastname;
  String username;
  String image;
  bool userIsActive;
  bool profileVerified;
  String eventName;
  DateTime startDate;
  DateTime endDate;
  String address;
  String details;
  DateTime eventCreatdate;
  int eventisActive;
  String longitude;
  String latitude;
  List<EventImage> eventImages;
  List<PostCommentModel> postComments;
  List<SuggestedUser> tagUsers;
  int actionActiveTab = -1;

  factory FeedListDataModel.fromJson(Map<String, dynamic> json) => FeedListDataModel(
    postId: json["postId"] == null ? null : json["postId"],
    caption: json["caption"] == null ? null : json["caption"],
    noOfLikes: json["noOfLikes"] == null ? null : json["noOfLikes"],
    noOfThumbs: json["noOfThumbs"] == null ? null : json["noOfThumbs"],
    noOfComments: json["noOfComments"] == null ? null : json["noOfComments"],
    selfLiked: json["selfLiked"] == null ? null : json["selfLiked"],
    selfThumbed: json["selfThumbed"] == null ? null : json["selfThumbed"],
    selfCommented: json["selfCommented"] == null ? null : json["selfCommented"],
    postMediaLinks: json["postMediaLinks"] == null ? [] : List<PostMediaLink>.from(json["postMediaLinks"].map((x) => PostMediaLink.fromJson(x))),
    eventId: json["eventId"] == null ? null : json["eventId"],
    id: json["id"] == null ? null : json["id"],
    isActive: json["isActive"] == null ? null : json["isActive"],
    isDeleted: json["isDeleted"] == null ? null : json["isDeleted"],
    createdDate: json["createdDate"] == null ? '' : json["createdDate"],
    isPrivate: json["isPrivate"] == null ? null : json["isPrivate"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    username: json["username"] == null ? null : json["username"],
    image: json["image"] == null ? null : json["image"],
    userIsActive: json["userIsActive"] == null ? null : json["userIsActive"],
    profileVerified: json["profileVerified"] == null ? null : json["profileVerified"],
    eventName: json["eventName"] == null ? '' : json["eventName"],
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    address: json["address"] == null ? null : json["address"],
    details: json["details"] == null ? null : json["details"],
    eventCreatdate: json["eventCreatdate"] == null ? null : DateTime.parse(json["eventCreatdate"]),
    eventisActive: json["eventisActive"] == null ? null : json["eventisActive"],
    longitude: json["longitude"] == null ? null : json["longitude"],
    latitude: json["latitude"] == null ? null : json["latitude"],
    eventImages: json["eventImages"] == null ? [] : List<EventImage>.from(json["eventImages"].map((x) => EventImage.fromJson(x))),
  postComments: json["postComments"] == null ? [] : List<PostCommentModel>.from(json["postComments"].map((x) => PostCommentModel.fromJson(x))),
  tagUsers: json["tagUsers"] == null ? [] : List<SuggestedUser>.from(json["tagUsers"].map((x) => SuggestedUser.fromJson(x))),
  actionActiveTab: json["actionActiveTab"] == null ? -1 : json["actionActiveTab"],
  );

  Map<String, dynamic> toJson() => {
    "postId": postId == null ? null : postId,
    "caption": caption == null ? null : caption,
    "noOfLikes": noOfLikes == null ? null : noOfLikes,
    "noOfThumbs": noOfThumbs == null ? null : noOfThumbs,
    "noOfComments": noOfComments == null ? null : noOfComments,
    "selfLiked": selfLiked == null ? null : selfLiked,
    "selfThumbed": selfThumbed == null ? null : selfThumbed,
    "selfCommented": selfCommented == null ? null : selfCommented,
    "postMediaLinks": postMediaLinks == null ? [] : List<dynamic>.from(postMediaLinks.map((x) => x.toJson())),
    "eventId": eventId == null ? null : eventId,
    "id": id == null ? null : id,
    "isActive": isActive == null ? null : isActive,
    "isDeleted": isDeleted == null ? null : isDeleted,
    "createdDate": createdDate == null ? null : createdDate,
    "isPrivate": isPrivate == null ? null : isPrivate,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "username": username == null ? null : username,
    "image": image == null ? null : image,
    "userIsActive": userIsActive == null ? null : userIsActive,
    "profileVerified": profileVerified == null ? null : profileVerified,
    "eventName": eventName == null ? null : eventName,
    "startDate": startDate == null ? null : startDate.toIso8601String(),
    "endDate": endDate == null ? null : endDate.toIso8601String(),
    "address": address == null ? null : address,
    "details": details == null ? null : details,
    "eventCreatdate": eventCreatdate == null ? null : eventCreatdate.toIso8601String(),
    "eventisActive": eventisActive == null ? null : eventisActive,
    "longitude": longitude == null ? null : longitude,
    "latitude": latitude == null ? null : latitude,
    "eventImages": eventImages == null ? [] : List<dynamic>.from(eventImages.map((x) => x.toJson())),
    "postComments": postComments == null ? [] : List<dynamic>.from(postComments.map((x) => x.toJson())),
    "tagUsers": tagUsers == null ? [] : List<dynamic>.from(tagUsers.map((x) => x.toJson())),
  };
}


class EventImage {
  EventImage({
    this.fileId,
    this.eventId,
    this.downloadlink,
    this.title,
    this.fileType,
    this.fileName,
  });

  int fileId;
  int eventId;
  String downloadlink;
  dynamic title;
  String fileType;
  String fileName;

  factory EventImage.fromJson(Map<String, dynamic> json) => EventImage(
    fileId: json["fileId"] == null ? null : json["fileId"],
    eventId: json["eventId"] == null ? null : json["eventId"],
    downloadlink: json["downloadlink"] == null ? null : json["downloadlink"],
    title: json["title"],
    fileType: json["fileType"] == null ? null : json["fileType"],
    fileName: json["fileName"] == null ? null : json["fileName"],
  );

  Map<String, dynamic> toJson() => {
    "fileId": fileId == null ? null : fileId,
    "eventId": eventId == null ? null : eventId,
    "downloadlink": downloadlink == null ? null : downloadlink,
    "title": title,
    "fileType": fileType == null ? null : fileType,
    "fileName": fileName == null ? null : fileName,
  };
}

class PostMediaLink {
  PostMediaLink({
    this.postFileId,
    this.downloadlink,
    this.mediaType,
    this.videolink,
    this.postId,
    this.selfLiked,
  });

  int postFileId;
  String downloadlink;
  String mediaType;
  String videolink;
  int postId;
  int selfLiked;

  factory PostMediaLink.fromJson(Map<String, dynamic> json) => PostMediaLink(
    postFileId: json["postFileId"] == null ? null : json["postFileId"],
    downloadlink: json["downloadlink"] == null ? null : json["downloadlink"],
    mediaType: json["mediaType"] == null ? null : json["mediaType"],
    videolink: json["videolink"] == null ? '' : json["videolink"],
    postId : 0,
    selfLiked : 0
  );

  Map<String, dynamic> toJson() => {
    "postFileId": postFileId == null ? null : postFileId,
    "downloadlink": downloadlink == null ? null : downloadlink,
    "mediaType": mediaType == null ? null : mediaType,
    "videolink": videolink == null ? '' : videolink,
    "postId" : 0,
    "selfLiked" : 0
  };
}
