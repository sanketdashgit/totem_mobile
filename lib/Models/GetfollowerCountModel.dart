// To parse this JSON data, do
//
//     final getfollowerCountModel = getfollowerCountModelFromJson(jsonString);

import 'dart:convert';

import 'UserModel.dart';

GetfollowerCountModel getfollowerCountModelFromJson(String str) =>
    GetfollowerCountModel.fromJson(json.decode(str));

String getfollowerCountModelToJson(GetfollowerCountModel data) =>
    json.encode(data.toJson());

class GetfollowerCountModel {
  GetfollowerCountModel({
    this.profileDetails,
    this.followers,
    this.following,
    this.isfollow,
    this.postCount
  });

  UserInfoModel profileDetails;
  int followers;
  int following;
  int isfollow;
  int postCount;

  factory GetfollowerCountModel.fromJson(Map<String, dynamic> json) =>
      GetfollowerCountModel(
        profileDetails: json["profileDetails"] == null
            ? null
            : UserInfoModel.fromJson(json["profileDetails"]),
        followers: json["followers"] == null ? 0 : json["followers"],
        following: json["following"] == null ? 0 : json["following"],
        isfollow: json["isfollow"] == null ? 0 : json["isfollow"],
        postCount: json["postCount"] == null ? 0 : json["postCount"],
      );

  Map<String, dynamic> toJson() => {
        "profileDetails":
            profileDetails == null ? null : profileDetails.toJson(),
        "followers": followers == null ? null : followers,
        "following": following == null ? null : following,
        "isfollow": isfollow == null ? null : isfollow,
        "postCount": postCount == null ? null : postCount,
      };
}
