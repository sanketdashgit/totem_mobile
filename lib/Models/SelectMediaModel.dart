import 'dart:convert';

SelectMediaModel selectMediaModelFromJson(String str) => SelectMediaModel.fromJson(json.decode(str));

String selectMediaModelToJson(SelectMediaModel data) => json.encode(data.toJson());

class SelectMediaModel {
  SelectMediaModel(
    this.type,
    this.path,
      this.size,
      this.fileId,
      this.videoAws
  );

  String type;
  String path;
  double size;
  int fileId;
  String videoAws;


  factory SelectMediaModel.fromJson(Map<String, dynamic> json) => SelectMediaModel(
    json["type"] == null ? '' : json["type"],
    json["path"] == null ? '' : json["path"],
    json["size"] == null ? '' : json["size"],
    json["fileId"] == null ? '' : json["fileId"],
    ""
  );

  Map<String, dynamic> toJson() => {
    "type": type == null ? null : type,
    "path": path == null ? null : path,
    "size": size == null ? null : size,
    "fileId": fileId == null ? null : fileId,
    "videoAws" : ""
  };
}