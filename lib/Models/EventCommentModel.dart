// To parse this JSON data, do
//
//     final eventCommentModel = eventCommentModelFromJson(jsonString);

import 'dart:convert';

EventCommentModel eventCommentModelFromJson(String str) => EventCommentModel.fromJson(json.decode(str));

String eventCommentModelToJson(EventCommentModel data) => json.encode(data.toJson());

class EventCommentModel {
  EventCommentModel({
    this.pageNumber,
    this.pageSize,
    this.totalRecords,
    this.data,
  });

  int pageNumber;
  int pageSize;
  int totalRecords;
  List<Datum> data;

  factory EventCommentModel.fromJson(Map<String, dynamic> json) => EventCommentModel(
    pageNumber: json["pageNumber"] == null ? null : json["pageNumber"],
    pageSize: json["pageSize"] == null ? null : json["pageSize"],
    totalRecords: json["totalRecords"] == null ? null : json["totalRecords"],
    data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "pageNumber": pageNumber == null ? null : pageNumber,
    "pageSize": pageSize == null ? null : pageSize,
    "totalRecords": totalRecords == null ? null : totalRecords,
    "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.eventId,
    this.eventName,
    this.usersEventsComments,
  });

  int eventId;
  String eventName;
  List<UsersEventsComment> usersEventsComments;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    eventId: json["eventId"] == null ? null : json["eventId"],
    eventName: json["eventName"] == null ? null : json["eventName"],
    usersEventsComments: json["usersEventsComments"] == null ? null : List<UsersEventsComment>.from(json["usersEventsComments"].map((x) => UsersEventsComment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "eventId": eventId == null ? null : eventId,
    "eventName": eventName == null ? null : eventName,
    "usersEventsComments": usersEventsComments == null ? null : List<dynamic>.from(usersEventsComments.map((x) => x.toJson())),
  };
}

class UsersEventsComment {
  UsersEventsComment({
    this.commentId,
    this.commentBody,
    this.userId,
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.phone,
    this.likeStatus,
    this.profileVerified,
    this.totalLike,
    this.replyBody,
    this.image,
  });

  int commentId;
  String commentBody;
  int userId;
  String firstname;
  String lastname;
  String username;
  String email;
  String phone;
  String image;
  bool likeStatus;
  bool profileVerified;
  int totalLike;
  List<ReplyBody> replyBody;

  factory UsersEventsComment.fromJson(Map<String, dynamic> json) => UsersEventsComment(
    commentId: json["commentID"] == null ? null : json["commentID"],
    commentBody: json["commentBody"] == null ? null : json["commentBody"],
    userId: json["userId"] == null ? null : json["userId"],
    firstname: json["firstname"] == null ? "" : json["firstname"],
    image: json["image"] == null ? null : json["image"],
    lastname: json["lastname"] == null ? "" : json["lastname"],
    username: json["username"] == null ? "" : json["username"],
    email: json["email"] == null ? null : json["email"],
    phone: json["phone"] == null ? null : json["phone"],
    likeStatus: json["likeStatus"] == null ? false : json["likeStatus"],
    profileVerified: json["profileVerified"] == null ? false : json["profileVerified"],
    totalLike: json["totalLike"] == null ? null : json["totalLike"],
    replyBody: json["replyBody"] == null ? null : List<ReplyBody>.from(json["replyBody"].map((x) => ReplyBody.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "commentID": commentId == null ? null : commentId,
    "commentBody": commentBody == null ? null : commentBody,
    "userId": userId == null ? null : userId,
    "firstname": firstname == null ? "" : firstname,
    "lastname": lastname == null ? "" : lastname,
    "username": username == null ? "" : username,
    "image": image == null ? null : image,
    "email": email == null ? null : email,
    "phone": phone == null ? null : phone,
    "likeStatus": likeStatus == null ? false : likeStatus,
    "profileVerified": profileVerified == null ? false : profileVerified,
    "totalLike": totalLike == null ? null : totalLike,
    "replyBody": replyBody == null ? null : List<dynamic>.from(replyBody.map((x) => x.toJson())),
  };
}

class ReplyBody {
  ReplyBody({
    this.replyID,
    this.replyBody,
    this.userId,
    this.firstname,
    this.lastname,
    this.username,
    this.image,
    this.email,
    this.phone,
    this.profileVerified,
  });

  int replyID;
  String replyBody;
  int userId;
  String firstname;
  String lastname;
  String username;
  String image;
  String email;
  String phone;
  bool profileVerified;

  factory ReplyBody.fromJson(Map<String, dynamic> json) => ReplyBody(
    replyBody: json["replyBody"] == null ? '' : json["replyBody"],
    replyID: json["replyID"] == null ? null : json["replyID"],
    userId: json["userId"] == null ? null : json["userId"],
    firstname: json["firstname"] == null ? "" : json["firstname"],
    lastname: json["lastname"] == null ? "" : json["lastname"],
    username: json["username"] == null ? "" : json["username"],
    image: json["image"] == null ? null : json["image"],
    email: json["email"] == null ? null : json["email"],
    phone: json["phone"] == null ? null : json["phone"],
    profileVerified: json["profileVerified"] == null ? false : json["profileVerified"],
  );

  Map<String, dynamic> toJson() => {
    "replyBody": replyBody == null ? null : replyBody,
    "replyID": replyID == null ? null : replyID,
    "userId": userId == null ? null : userId,
    "firstname": firstname == null ? "" : firstname,
    "lastname": lastname == null ? "" : lastname,
    "username": username == null ? "" : username,
    "image": image == null ? null : image,
    "email": email == null ? null : email,
    "phone": phone == null ? null : phone,
    "profileVerified": profileVerified == null ? false : profileVerified,
  };
}
