// To parse this JSON data, do
//
//     final createEventModel = createEventModelFromJson(jsonString);

import 'dart:convert';

CreateEventModel createEventModelFromJson(String str) => CreateEventModel.fromJson(json.decode(str));

String createEventModelToJson(CreateEventModel data) => json.encode(data.toJson());

class CreateEventModel {
  CreateEventModel({
    this.result,
    this.meta,
  });

  CreateEventresult result;
  CreateEventMeta meta;

  factory CreateEventModel.fromJson(Map<String, dynamic> json) => CreateEventModel(
    result: CreateEventresult.fromJson(json["result"]),
    meta: CreateEventMeta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "result": result.toJson(),
    "meta": meta.toJson(),
  };
}

class CreateEventMeta {
  CreateEventMeta({
    this.status,
    this.message,
  });

  bool status;
  String message;

  factory CreateEventMeta.fromJson(Map<String, dynamic> json) => CreateEventMeta(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}

class CreateEventresult {
  CreateEventresult({
    this.id,
    this.eventId,
    this.eventName,
    this.startDate,
    this.endDate,
    this.address,
    this.city,
    this.state,
    this.details,
    this.longitude,
    this.latitude,
  });

  int id;
  int eventId;
  String eventName;
  DateTime startDate;
  DateTime endDate;
  String address;
  String city;
  String state;
  String details;
  String longitude;
  String latitude;

  factory CreateEventresult.fromJson(Map<String, dynamic> json) => CreateEventresult(
    id: json["id"] == null ? null : json["id"],
    eventId: json["eventId"] == null ? null : json["eventId"],
    eventName: json["eventName"] == null ? null : json["eventName"],
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    address: json["address"] == null ? null : json["address"],
    city: json["city"] == null ? null : json["city"],
    state: json["state"] == null ? null : json["state"],
    details: json["details"] == null ? null : json["details"],
    longitude: json["longitude"] == null ? null : json["longitude"],
    latitude: json["latitude"] == null ? null : json["latitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "eventId": eventId == null ? null : eventId,
    "eventName": eventName == null ? null : eventName,
    "startDate": startDate == null ? null : startDate.toIso8601String(),
    "endDate": endDate == null ? null : endDate.toIso8601String(),
    "address": address == null ? null : address,
    "city": city == null ? null : city,
    "state": state == null ? null : state,
    "details": details == null ? null : details,
    "longitude": longitude == null ? null : longitude,
    "latitude": latitude == null ? null : latitude,
  };
}
