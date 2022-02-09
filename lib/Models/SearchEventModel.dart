// To parse this JSON data, do
//
//     final searchEventModel = searchEventModelFromJson(jsonString);

import 'dart:convert';

List<SearchEventModel> searchEventModelFromJson(String str) =>
    List<SearchEventModel>.from(
        json.decode(str).map((x) => SearchEventModel.fromJson(x)));

String searchEventModelToJson(List<SearchEventModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchEventModel {
  SearchEventModel({
    this.id,
    this.eventId,
    this.eventName,
    this.address,
    this.city,
    this.state,
    this.details,
    this.longitude,
    this.latitude,
    this.eventImages,
    this.isActive,
  });

  int id;
  int eventId;
  String eventName;
  String address;
  String city;
  String state;
  String details;
  String longitude;
  String latitude;
  List<EventImage> eventImages;
  int isActive;

  factory SearchEventModel.fromJson(Map<String, dynamic> json) =>
      SearchEventModel(
        id: json["id"] == null ? null : json["id"],
        eventId: json["eventId"] == null ? null : json["eventId"],
        eventName: json["eventName"] == null ? null : json["eventName"],
        address: json["address"] == null ? "" : json["address"],
        city: json["city"] == null ? null : json["city"],
        state: json["state"] == null ? null : json["state"],
        details: json["details"] == null ? null : json["details"],
        longitude: json["longitude"] == null ? null : json["longitude"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        eventImages: json["eventImages"] == null
            ? null
            : List<EventImage>.from(
                json["eventImages"].map((x) => EventImage.fromJson(x))),
        isActive: json["isActive"] == null ? null : json["isActive"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "eventId": eventId == null ? null : eventId,
        "eventName": eventName == null ? null : eventName,
        "address": address == null ? "" : address,
        "city": city == null ? null : city,
        "state": state == null ? null : state,
        "details": details == null ? null : details,
        "longitude": longitude == null ? null : longitude,
        "latitude": latitude == null ? null : latitude,
        "eventImages": eventImages == null
            ? null
            : List<dynamic>.from(eventImages.map((x) => x.toJson())),
        "isActive": isActive == null ? null : isActive,
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
        downloadlink:
            json["downloadlink"] == null ? null : json["downloadlink"],
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
