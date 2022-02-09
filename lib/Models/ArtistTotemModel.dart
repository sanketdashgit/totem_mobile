// To parse this JSON data, do
//
//     final artistTotemModel = artistTotemModelFromJson(jsonString);

import 'dart:convert';

ArtistTotemModel artistTotemModelFromJson(String str) =>
    ArtistTotemModel.fromJson(json.decode(str));

String artistTotemModelToJson(ArtistTotemModel data) =>
    json.encode(data.toJson());

class ArtistTotemModel {
  ArtistTotemModel({
    this.id,
    this.spotifyId,
    this.name,
    this.image,
  });

  int id;
  String spotifyId;
  String name;
  String image;

  factory ArtistTotemModel.fromJson(Map<String, dynamic> json) =>
      ArtistTotemModel(
        id: json["id"] == null ? null : json["id"],
        spotifyId: json["spotifyId"] == null ? null : json["spotifyId"],
        name: json["name"] == null ? null : json["name"],
        image: json["image"] == null ? "" : json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "spotifyId": spotifyId == null ? null : spotifyId,
        "name": name == null ? null : name,
        "image": image == null ? null : image,
      };
}
