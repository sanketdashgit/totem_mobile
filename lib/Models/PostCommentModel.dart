// To parse this JSON data, do
//
//     final postCommentModel = postCommentModelFromJson(jsonString);

import 'dart:convert';

import 'package:totem_app/Models/EventCommentModel.dart';

PostCommentModel postCommentModelFromJson(String str) => PostCommentModel.fromJson(json.decode(str));

String postCommentModelToJson(PostCommentModel data) => json.encode(data.toJson());

class PostCommentModel {
  PostCommentModel({
    this.postCommentId,
    this.postId,
    this.id,
    this.comment,
    this.firstname,
    this.lastname,
    this.username,
    this.image,
    this.likeStatus,
    this.profileVerified,
    this.totalLike,
    this.replyBody,
  });

  int postCommentId;
  int postId;
  int id;
  String comment;
  String firstname;
  String lastname;
  String username;
  String image;
  bool likeStatus;
  bool profileVerified;
  int totalLike;
  List<ReplyBody> replyBody;

  factory PostCommentModel.fromJson(Map<String, dynamic> json) => PostCommentModel(
    postCommentId: json["postCommentId"] == null ? null : json["postCommentId"],
    postId: json["postId"] == null ? null : json["postId"],
    id: json["id"] == null ? null : json["id"],
    comment: json["comment"] == null ? null : json["comment"],
    firstname: json["firstname"] == null ? "" : json["firstname"],
    lastname: json["lastname"] == null ? "" : json["lastname"],
    username: json["username"] == null ? "" : json["username"],
    image: json["image"] == null ? null : json["image"],
    likeStatus: json["likeStatus"] == null ? false : json["likeStatus"],
    profileVerified: json["profileVerified"] == null ? false : json["profileVerified"],
    totalLike: json["totalLike"] == null ? null : json["totalLike"],
    replyBody: json["replyBody"] == null ? null : List<ReplyBody>.from(json["replyBody"].map((x) => ReplyBody.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "postCommentId": postCommentId == null ? null : postCommentId,
    "postId": postId == null ? null : postId,
    "id": id == null ? null : id,
    "comment": comment == null ? null : comment,
    "firstname": firstname == null ? "" : firstname,
    "lastname": lastname == null ? "" : lastname,
    "username": username == null ? "" : username,
    "image": image == null ? null : image,
    "likeStatus": likeStatus == null ? false : likeStatus,
    "profileVerified": profileVerified == null ? false : profileVerified,
    "totalLike": totalLike == null ? null : totalLike,
    "replyBody": replyBody == null ? null : List<dynamic>.from(replyBody.map((x) => x.toJson())),
  };
}

