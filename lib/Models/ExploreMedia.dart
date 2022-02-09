// To parse this JSON data, do
//
//     final exploreMedia = exploreMediaFromJson(jsonString);

import 'dart:convert';

ExploreMedia exploreMediaFromJson(String str) => ExploreMedia.fromJson(json.decode(str));

String exploreMediaToJson(ExploreMedia data) => json.encode(data.toJson());

class ExploreMedia {
  ExploreMedia({
    this.postFileId,
    this.downloadlink,
    this.mediaType,
    this.createdDate,
    this.videolink,
    this.likeCount,
    this.postId,
    this.caption,
    this.eventId,
    this.id,
    this.isActive,
    this.isPrivate,
    this.isDeleted,
    this.firstname,
    this.lastname,
    this.username,
    this.likeType,
  });

  int postFileId;
  String downloadlink;
  String mediaType;
  DateTime createdDate;
  String videolink;
  int likeCount;
  int postId;
  String caption;
  int eventId;
  int id;
  int isActive;
  bool isPrivate;
  bool isDeleted;
  String firstname;
  String lastname;
  String username;
  int likeType;

  factory ExploreMedia.fromJson(Map<String, dynamic> json) => ExploreMedia(
    postFileId: json["postFileId"] == null ? null : json["postFileId"],
    downloadlink: json["downloadlink"] == null ? null : json["downloadlink"],
    mediaType: json["mediaType"] == null ? null : json["mediaType"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    videolink: json["videolink"] == null ? null : json["videolink"],
    likeCount: json["likeCount"] == null ? null : json["likeCount"],
    postId: json["postId"] == null ? null : json["postId"],
    caption: json["caption"] == null ? null : json["caption"],
    eventId: json["eventId"],
    id: json["id"] == null ? null : json["id"],
    isActive: json["isActive"] == null ? null : json["isActive"],
    isPrivate: json["isPrivate"] == null ? null : json["isPrivate"],
    isDeleted: json["isDeleted"] == null ? null : json["isDeleted"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    username: json["username"] == null ? null : json["username"],
    likeType: json["likeType"] == null ? null : json["likeType"],
  );

  Map<String, dynamic> toJson() => {
    "postFileId": postFileId == null ? null : postFileId,
    "downloadlink": downloadlink == null ? null : downloadlink,
    "mediaType": mediaType == null ? null : mediaType,
    "createdDate": createdDate == null ? null : createdDate.toIso8601String(),
    "videolink": videolink == null ? null : videolink,
    "likeCount": likeCount == null ? null : likeCount,
    "postId": postId == null ? null : postId,
    "caption": caption == null ? null : caption,
    "eventId": eventId,
    "id": id == null ? null : id,
    "isActive": isActive == null ? null : isActive,
    "isPrivate": isPrivate == null ? null : isPrivate,
    "isDeleted": isDeleted == null ? null : isDeleted,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "username": username == null ? null : username,
    "likeType": likeType == null ? null : likeType,
  };
}
