// To parse this JSON data, do
//
//     final songTotemModel = songTotemModelFromJson(jsonString);

import 'dart:convert';

SongTotemModel songTotemModelFromJson(String str) => SongTotemModel.fromJson(json.decode(str));

String songTotemModelToJson(SongTotemModel data) => json.encode(data.toJson());

class SongTotemModel {
    SongTotemModel({
        this.id,
        this.spotifyId,
        this.trackName,
        this.albumName,
        this.artistName,
        this.image,
        this.songlink,
        this.albumId,
    });

    int id;
    String spotifyId;
    String trackName;
    String albumName;
    String artistName;
    String image;
    String songlink;
    String albumId;

    factory SongTotemModel.fromJson(Map<String, dynamic> json) => SongTotemModel(
        id: json["id"],
        spotifyId: json["spotifyId"],
        trackName: json["trackName"],
        albumName: json["albumName"],
        artistName: json["artistName"],
        image: json["image"],
        songlink: json["songlink"],
        albumId: json["albumId"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "spotifyId": spotifyId,
        "trackName": trackName,
        "albumName": albumName,
        "artistName": artistName,
        "image": image,
        "songlink": songlink,
        "albumId": albumId,
    };
}
