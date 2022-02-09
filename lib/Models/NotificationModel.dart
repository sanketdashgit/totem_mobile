import 'dart:convert';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
  NotificationModel({
    this.pageNumber,
    this.pageSize,
    this.totalRecords,
    this.data,
  });

  int pageNumber;
  int pageSize;
  int totalRecords;
  List<NotificationData> data;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    pageNumber: json["pageNumber"] == null ? null : json["pageNumber"],
    pageSize: json["pageSize"] == null ? null : json["pageSize"],
    totalRecords: json["totalRecords"] == null ? null : json["totalRecords"],
    data: json["data"] == null ? null : List<NotificationData>.from(json["data"].map((x) => NotificationData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "pageNumber": pageNumber == null ? null : pageNumber,
    "pageSize": pageSize == null ? null : pageSize,
    "totalRecords": totalRecords == null ? null : totalRecords,
    "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class NotificationData {
  NotificationData({
    this.ssrno,
    this.id,
    this.date,
    this.image,
    this.title,
    this.descp,
    this.nuserName,
    this.readflag,
    this.requestAccepted,
    this.notificationType,
    this.notificationTypeId,
  });

  int ssrno;
  String id;
  int notificationTypeId;
  String date;
  String image;
  String title;
  String descp;
  String nuserName;
  int requestAccepted;
  String readflag;
  String notificationType;

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
    ssrno: json["ssrno"] == null ? null : json["ssrno"],
    id: json["id"] == null ? null : json["id"],
    date: json["date"] == null ? null : json["date"],
    image: json["image"] == null ? null : json["image"],
    title: json["title"] == null ? '' : json["title"],
    descp: json["descp"] == null ? '' : json["descp"],
    nuserName: json["nuserName"] == null ? '' : json["nuserName"],
    readflag: json["readflag"] == null ? null : json["readflag"],
    requestAccepted: json["requestAccepted"] == null ? null : json["requestAccepted"],
    notificationType: json["notificationType"] == null ? '' : json["notificationType"],
    notificationTypeId: json["notificationTypeId"] == null ? 0 : json["notificationTypeId"],
  );

  Map<String, dynamic> toJson() => {
    "ssrno": ssrno == null ? null : ssrno,
    "id": id == null ? null : id,
    "date": date == null ? null : date,
    "image": image == null ? null : image,
    "title": title == null ? '' : title.trim(),
    "descp": descp == null ? '' : descp.trim(),
    "nuserName": nuserName == null ? '' : nuserName.trim(),
    "readflag": readflag == null ? null : readflag,
    "requestAccepted": requestAccepted == null ? null : requestAccepted,
    "notificationType": notificationType == null ? null : notificationType,
    "notificationTypeId": notificationTypeId == null ? null : notificationTypeId,
  };
}
