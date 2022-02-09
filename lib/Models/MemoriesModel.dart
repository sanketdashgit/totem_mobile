// To parse this JSON data, do
//
//     final memoriesModel = memoriesModelFromJson(jsonString);

import 'dart:convert';

MemoriesModel memoriesModelFromJson(String str) => MemoriesModel.fromJson(json.decode(str));

String memoriesModelToJson(MemoriesModel data) => json.encode(data.toJson());

class MemoriesModel {
  MemoriesModel({
    this.memorieId,
    this.id,
    this.firstname,
    this.lastname,
    this.username,
    this.image,
    this.caption,
    this.isPrivate,
    this.eventId,
    this.eventName,
    this.startDate,
    this.memorieMediaLinks,
  });

  int memorieId;
  int id;
  String firstname;
  String lastname;
  String username;
  String image;
  String caption;
  bool isPrivate;
  int eventId;
  String eventName;
  DateTime startDate;
  List<MemorieMediaLink> memorieMediaLinks;

  factory MemoriesModel.fromJson(Map<String, dynamic> json) => MemoriesModel(
    memorieId: json["memorieId"] == null ? null : json["memorieId"],
    id: json["id"] == null ? null : json["id"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    username: json["username"] == null ? null : json["username"],
    image: json["image"] == null ? null : json["image"],
    caption: json["caption"] == null ? null : json["caption"],
    isPrivate: json["isPrivate"] == null ? false : json["isPrivate"],
    eventId: json["eventId"] == null ? null : json["eventId"],
    eventName: json["eventName"] == null ? null : json["eventName"],
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    memorieMediaLinks: json["memorieMediaLinks"] == null ? null : List<MemorieMediaLink>.from(json["memorieMediaLinks"].map((x) => MemorieMediaLink.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "memorieId": memorieId == null ? null : memorieId,
    "id": id == null ? null : id,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "username": username == null ? null : username,
    "image": image == null ? null : image,
    "caption": caption == null ? null : caption,
    "isPrivate": isPrivate == null ? false : isPrivate,
    "eventId": eventId == null ? null : eventId,
    "eventName": eventName == null ? null : eventName,
    "startDate": startDate == null ? null : startDate.toIso8601String(),
    "memorieMediaLinks": memorieMediaLinks == null ? null : List<dynamic>.from(memorieMediaLinks.map((x) => x.toJson())),
  };
}

class MemorieMediaLink {
  MemorieMediaLink({
    this.memorieFileId,
    this.downloadlink,
    this.mediaType,
    this.videolink,
    this.isPrivate,
  });

  int memorieFileId;
  String downloadlink;
  String mediaType;
  String videolink;
  bool isPrivate;

  factory MemorieMediaLink.fromJson(Map<String, dynamic> json) => MemorieMediaLink(
    memorieFileId: json["memorieFileId"] == null ? null : json["memorieFileId"],
    downloadlink: json["downloadlink"] == null ? null : json["downloadlink"],
    mediaType: json["mediaType"] == null ? null : json["mediaType"],
    videolink: json["videolink"] == null ? null : json["videolink"],
    isPrivate: json["isPrivate"] == null ? false : json["isPrivate"],
  );

  Map<String, dynamic> toJson() => {
    "memorieFileId": memorieFileId == null ? null : memorieFileId,
    "downloadlink": downloadlink == null ? null : downloadlink,
    "mediaType": mediaType == null ? null : mediaType,
    "videolink": videolink == null ? null : videolink,
    "isPrivate": isPrivate == null ? false : isPrivate,
  };
}
