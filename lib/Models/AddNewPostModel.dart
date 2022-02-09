import 'dart:convert';

AddNewPostModel addNewPostModelFromJson(String str) => AddNewPostModel.fromJson(json.decode(str));

String addNewPostModelToJson(AddNewPostModel data) => json.encode(data.toJson());

class AddNewPostModel {
  AddNewPostModel({
    this.postId,
    this.caption,
    this.eventId,
    this.id,
  });

  int postId;
  String caption;
  int eventId;
  int id;

  factory AddNewPostModel.fromJson(Map<String, dynamic> json) => AddNewPostModel(
    postId: json["postId"] == null ? null : json["postId"],
    caption: json["caption"] == null ? null : json["caption"],
    eventId: json["eventId"] == null ? null : json["eventId"],
    id: json["id"] == null ? null : json["id"],
  );

  Map<String, dynamic> toJson() => {
    "postId": postId == null ? null : postId,
    "caption": caption == null ? null : caption,
    "eventId": eventId == null ? null : eventId,
    "id": id == null ? null : id,
  };
}