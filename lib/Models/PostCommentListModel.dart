import 'dart:convert';

PostCommentListModel postCommentListModelFromJson(String str) => PostCommentListModel.fromJson(json.decode(str));

String postCommentListModelToJson(PostCommentListModel data) => json.encode(data.toJson());

class PostCommentListModel {
  PostCommentListModel({
    this.postCommentId,
    this.postId,
    this.id,
    this.comment,
  });

  int postCommentId;
  int postId;
  int id;
  String comment;

  factory PostCommentListModel.fromJson(Map<String, dynamic> json) => PostCommentListModel(
    postCommentId: json["postCommentId"] == null ? null : json["postCommentId"],
    postId: json["postId"] == null ? null : json["postId"],
    id: json["id"] == null ? null : json["id"],
    comment: json["comment"] == null ? null : json["comment"],
  );

  Map<String, dynamic> toJson() => {
    "postCommentId": postCommentId == null ? null : postCommentId,
    "postId": postId == null ? null : postId,
    "id": id == null ? null : id,
    "comment": comment == null ? null : comment,
  };
}
