// To parse this JSON data, do
//
//     final genreTotemModel = genreTotemModelFromJson(jsonString);

import 'dart:convert';

GenreTotemModel genreTotemModelFromJson(String str) =>
    GenreTotemModel.fromJson(json.decode(str));

String genreTotemModelToJson(GenreTotemModel data) =>
    json.encode(data.toJson());

class GenreTotemModel {
  GenreTotemModel({
    this.id,
    this.spotifyId,
    this.name,
  });

  int id;
  String spotifyId;
  String name;

  factory GenreTotemModel.fromJson(Map<String, dynamic> json) =>
      GenreTotemModel(
        id: json["id"] == null ? null : json["id"],
        spotifyId: json["spotifyId"] == null ? null : json["spotifyId"],
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "spotifyId": spotifyId == null ? null : spotifyId,
        "name": name == null ? null : name,
      };
}
