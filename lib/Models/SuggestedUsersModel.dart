// To parse this JSON data, do
//
//     final suggestedUsersModel = suggestedUsersModelFromJson(jsonString);

import 'dart:convert';

SuggestedUsersModel suggestedUsersModelFromJson(String str) =>
    SuggestedUsersModel.fromJson(json.decode(str));

String suggestedUsersModelToJson(SuggestedUsersModel data) =>
    json.encode(data.toJson());

class SuggestedUsersModel {
  SuggestedUsersModel({
    this.pageNumber,
    this.pageSize,
    this.totalRecords,
    this.data,
  });

  int pageNumber;
  int pageSize;
  int totalRecords;
  List<SuggestedUser> data;

  factory SuggestedUsersModel.fromJson(Map<String, dynamic> json) =>
      SuggestedUsersModel(
        pageNumber: json["pageNumber"] == null ? null : json["pageNumber"],
        pageSize: json["pageSize"] == null ? null : json["pageSize"],
        totalRecords:
            json["totalRecords"] == null ? null : json["totalRecords"],
        data: json["data"] == null
            ? null
            : List<SuggestedUser>.from(
                json["data"].map((x) => SuggestedUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pageNumber": pageNumber == null ? null : pageNumber,
        "pageSize": pageSize == null ? null : pageSize,
        "totalRecords": totalRecords == null ? null : totalRecords,
        "data": data == null
            ? null
            : List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class SuggestedUser {
  SuggestedUser({
    this.id,
    this.image,
    this.firstname,
    this.lastname,
    this.username,
    this.mutualCount,
    this.isfollow,
    this.isPrivate,
    this.profileVerified,
    this.presentLiveStatus,
  });

  int id;
  String image;
  String firstname;
  String lastname;
  String username;
  int mutualCount;
  int isfollow;
  bool isPrivate;
  bool profileVerified;
  int presentLiveStatus;

  factory SuggestedUser.fromJson(Map<String, dynamic> json) => SuggestedUser(
      id: json["id"] == null ? null : json["id"],
      image: json["image"] == null ? "" : json["image"],
      firstname: json["firstname"] == null ? "" : json["firstname"],
      lastname: json["lastname"] == null ? "" : json["lastname"],
      username: json["username"] == null ? "" : json["username"],
      mutualCount: json["mutualCount"] == null ? 0 : json["mutualCount"],
      isfollow: json["isfollow"] == null ? 0 : json["isfollow"],
      isPrivate: json["isPrivate"] == null ? false : json["isPrivate"],
      profileVerified:
          json["profileVerified"] == null ? false : json["profileVerified"],
      presentLiveStatus:
          json["presentLiveStatus"] == null ? 0 : json["presentLiveStatus"]);

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "firstname": firstname == null ? "" : firstname,
        "lastname": lastname == null ? "" : lastname,
        "username": username == null ? "" : username,
        "mutualCount": mutualCount == null ? null : mutualCount,
        "isfollow": isfollow == null ? null : isfollow,
        "isPrivate": isPrivate == null ? null : isPrivate,
        "profileVerified": profileVerified == null ? false : profileVerified,
      };
}
