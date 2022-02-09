// To parse this JSON data, do
//
//     final eventDetailsModel = eventDetailsModelFromJson(jsonString);

import 'dart:convert';

EventDetailsModel eventDetailsModelFromJson(String str) => EventDetailsModel.fromJson(json.decode(str));

String eventDetailsModelToJson(EventDetailsModel data) => json.encode(data.toJson());

class EventDetailsModel {
  EventDetailsModel({
    this.id,
    this.eventId,
    this.eventName,
    this.startDate,
    this.endDate,
    this.address,
    this.details,
    this.createdDate,
    this.modifiedDate,
    this.isActive,
    this.isDeleted,
    this.longitude,
    this.latitude,
    this.status,
    this.firstname,
    this.lastname,
    this.email,
    this.golive,
    this.interest,
    this.favorite,
    this.goliveCount,
    this.interestCount,
    this.favoriteCount,
    this.profileVerified,
    this.eventImages,
  });

  int id;
  int eventId;
  String eventName;
  DateTime startDate;
  DateTime endDate;
  String address;
  String details;
  DateTime createdDate;
  DateTime modifiedDate;
  int isActive;
  bool isDeleted;
  String longitude;
  String latitude;
  bool status;
  String firstname;
  String lastname;
  String email;
  bool golive;
  bool interest;
  bool favorite;
  int goliveCount;
  int interestCount;
  int favoriteCount;
  bool profileVerified;
  List<EventImage> eventImages;

  factory EventDetailsModel.fromJson(Map<String, dynamic> json) => EventDetailsModel(
    id: json["id"] == null ? null : json["id"],
    eventId: json["eventId"] == null ? null : json["eventId"],
    eventName: json["eventName"] == null ? null : json["eventName"],
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    address: json["address"] == null ? null : json["address"],
    details: json["details"] == null ? null : json["details"],
    createdDate: json["createdDate"] == null ? null : DateTime.parse(json["createdDate"]),
    modifiedDate: json["modifiedDate"] == null ? null : DateTime.parse(json["modifiedDate"]),
    isActive: json["isActive"] == null ? null : json["isActive"],
    isDeleted: json["isDeleted"] == null ? null : json["isDeleted"],
    longitude: json["longitude"] == null ? null : json["longitude"],
    latitude: json["latitude"] == null ? null : json["latitude"],
    status: json["status"] == null ? null : json["status"],
    firstname: json["firstname"] == null ? null : json["firstname"],
    lastname: json["lastname"] == null ? null : json["lastname"],
    email: json["email"] == null ? null : json["email"],
    golive: json["golive"] == null ? null : json["golive"],
    interest: json["interest"] == null ? null : json["interest"],
    favorite: json["favorite"] == null ? null : json["favorite"],
    goliveCount: json["goliveCount"] == null ? null : json["goliveCount"],
    interestCount: json["interestCount"] == null ? null : json["interestCount"],
    favoriteCount: json["favoriteCount"] == null ? null : json["favoriteCount"],
    profileVerified: json["profileVerified"] == null ? null : json["profileVerified"],
    eventImages: json["eventImages"] == null ? null : List<EventImage>.from(json["eventImages"].map((x) => EventImage.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "eventId": eventId == null ? null : eventId,
    "eventName": eventName == null ? null : eventName,
    "startDate": startDate == null ? null : startDate.toIso8601String(),
    "endDate": endDate == null ? null : endDate.toIso8601String(),
    "address": address == null ? null : address,
    "details": details == null ? null : details,
    "createdDate": createdDate == null ? null : createdDate.toIso8601String(),
    "modifiedDate": modifiedDate == null ? null : modifiedDate.toIso8601String(),
    "isActive": isActive == null ? null : isActive,
    "isDeleted": isDeleted == null ? null : isDeleted,
    "longitude": longitude == null ? null : longitude,
    "latitude": latitude == null ? null : latitude,
    "status": status == null ? null : status,
    "firstname": firstname == null ? null : firstname,
    "lastname": lastname == null ? null : lastname,
    "email": email == null ? null : email,
    "golive": golive == null ? null : golive,
    "interest": interest == null ? null : interest,
    "favorite": favorite == null ? null : favorite,
    "goliveCount": goliveCount == null ? null : goliveCount,
    "interestCount": interestCount == null ? null : interestCount,
    "favoriteCount": favoriteCount == null ? null : favoriteCount,
    "profileVerified": profileVerified == null ? null : profileVerified,
    "eventImages": eventImages == null ? null : List<dynamic>.from(eventImages.map((x) => x.toJson())),
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
