// To parse this JSON data, do
//
//     final eventUserModel = eventUserModelFromJson(jsonString);

import 'dart:convert';

EventUserModel eventUserModelFromJson(String str) => EventUserModel.fromJson(json.decode(str));

String eventUserModelToJson(EventUserModel data) => json.encode(data.toJson());

class EventUserModel {
  EventUserModel({
    this.eventId,
    this.eventName,
    this.id,
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.phone,
    this.golive,
    this.interest,
    this.favorite,
    this.image,
    this.selfLiked,
    this.profileVerified
  });

  int eventId;
  String eventName;
  int id;
  String firstname;
  String lastname;
  String username;
  String email;
  String phone;
  String image;
  bool golive;
  bool interest;
  bool favorite;
  int selfLiked;
  bool profileVerified;

  factory EventUserModel.fromJson(Map<String, dynamic> json) => EventUserModel(
    eventId: json["eventId"] == null ? null : json["eventId"],
    eventName: json["eventName"] == null ? null : json["eventName"],
    id: json["id"] == null ? null : json["id"],
    firstname: json["firstname"] == null ? "" : json["firstname"],
    lastname: json["lastname"] == null ? "" : json["lastname"],
    username: json["username"] == null ? "" : json["username"],
    email: json["email"] == null ? null : json["email"],
    phone: json["phone"] == null ? null : json["phone"],
    image: json["image"] == null ? '' : json["image"],
    golive: json["golive"] == null ? null : json["golive"],
    interest: json["interest"] == null ? null : json["interest"],
    favorite: json["favorite"] == null ? null : json["favorite"],
    selfLiked: json["selfLiked"] == null ? 0 : json["selfLiked"],
    profileVerified: json["profileVerified"] == null ? false : json["profileVerified"],
  );

  Map<String, dynamic> toJson() => {
    "eventId": eventId == null ? null : eventId,
    "eventName": eventName == null ? null : eventName,
    "id": id == null ? null : id,
    "firstname": firstname == null ? "" : firstname,
    "lastname": lastname == null ? "" : lastname,
    "username": username == null ? "" : username,
    "email": email == null ? null : email,
    "phone": phone == null ? null : phone,
    "image": image == null ? null : image,
    "golive": golive == null ? null : golive,
    "interest": interest == null ? null : interest,
    "favorite": favorite == null ? null : favorite,
    "selfLiked": selfLiked == null ? null : selfLiked,
    "profileVerified": profileVerified == null ? false : profileVerified,
  };
}
