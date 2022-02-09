import 'dart:convert';

AddMemories addMemoriesFromJson(String str) => AddMemories.fromJson(json.decode(str));

String addMemoriesToJson(AddMemories data) => json.encode(data.toJson());

class AddMemories {
  AddMemories({
    this.memorieId,
    this.caption,
    this.eventId,
    this.isPrivate,
    this.id,
    this.memorieFiles,
  });

  int memorieId;
  String caption;
  int eventId;
  bool isPrivate;
  int id;
  List<MemorieFile> memorieFiles;

  factory AddMemories.fromJson(Map<String, dynamic> json) => AddMemories(
    memorieId: json["memorieId"] == null ? null : json["memorieId"],
    caption: json["caption"] == null ? null : json["caption"],
    eventId: json["eventId"] == null ? null : json["eventId"],
    isPrivate: json["isPrivate"] == null ? null : json["isPrivate"],
    id: json["id"] == null ? null : json["id"],
    memorieFiles: json["memorieFiles"] == null ? null : List<MemorieFile>.from(json["memorieFiles"].map((x) => MemorieFile.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "memorieId": memorieId == null ? null : memorieId,
    "caption": caption == null ? null : caption,
    "eventId": eventId == null ? null : eventId,
    "isPrivate": isPrivate == null ? null : isPrivate,
    "id": id == null ? null : id,
    "memorieFiles": memorieFiles == null ? null : List<dynamic>.from(memorieFiles.map((x) => x.toJson())),
  };
}

class MemorieFile {
  MemorieFile({
    this.memorieFileId,
    this.memorieId,
    this.fileName,
    this.mediaType,
    this.video,
  });

  int memorieFileId;
  int memorieId;
  String fileName;
  String mediaType;
  String video;

  factory MemorieFile.fromJson(Map<String, dynamic> json) => MemorieFile(
    memorieFileId: json["memorieFileId"] == null ? null : json["memorieFileId"],
    memorieId: json["memorieId"] == null ? null : json["memorieId"],
    fileName: json["fileName"] == null ? null : json["fileName"],
    mediaType: json["mediaType"] == null ? null : json["mediaType"],
    video: json["video"] == null ? null : json["video"],
  );

  Map<String, dynamic> toJson() => {
    "memorieFileId": memorieFileId == null ? null : memorieFileId,
    "memorieId": memorieId == null ? null : memorieId,
    "fileName": fileName == null ? null : fileName,
    "mediaType": mediaType == null ? null : mediaType,
    "video": video == null ? null : video,
  };
}
