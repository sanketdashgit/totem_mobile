// To parse this JSON data, do
//
//     final interestSaveModel = interestSaveModelFromJson(jsonString);

import 'dart:convert';

import 'package:totem_app/Models/ArtistTotemModel.dart';
import 'package:totem_app/Models/EventHomeModel.dart';
import 'package:totem_app/Models/SearchEventModel.dart';

InterestSaveModel interestSaveModelFromJson(String str) =>
    InterestSaveModel.fromJson(json.decode(str));

String interestSaveModelToJson(InterestSaveModel data) =>
    json.encode(data.toJson());

class InterestSaveModel {
  InterestSaveModel({
    this.id,
    this.artists,
    this.genres,
    this.favouriteEvents,
    this.nextEvents,
  });

  int id;
  List<ArtistTotemModel> artists;
  List<ArtistTotemModel> genres;
  List<FavouriteEvent> favouriteEvents;
  List<FavouriteEvent> nextEvents;

  factory InterestSaveModel.fromJson(Map<String, dynamic> json) =>
      InterestSaveModel(
        id: json["id"] == null ? null : json["id"],
        artists: json["artists"] == null
            ? null
            : List<ArtistTotemModel>.from(
                json["artists"].map((x) => ArtistTotemModel.fromJson(x))),
        genres: json["genres"] == null
            ? null
            : List<ArtistTotemModel>.from(
                json["genres"].map((x) => ArtistTotemModel.fromJson(x))),
        favouriteEvents: json["favouriteEvents"] == null
            ? null
            : List<FavouriteEvent>.from(
                json["favouriteEvents"].map((x) => FavouriteEvent.fromJson(x))),
        nextEvents: json["nextEvents"] == null
            ? null
            : List<FavouriteEvent>.from(
            json["nextEvents"].map((x) => FavouriteEvent.fromJson(x))),

      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "artists": artists == null
            ? null
            : List<dynamic>.from(artists.map((x) => x.toJson())),
        "genres": genres == null
            ? null
            : List<dynamic>.from(genres.map((x) => x.toJson())),
        "favouriteEvents": favouriteEvents == null
            ? null
            : List<dynamic>.from(favouriteEvents.map((x) => x.toJson())),
    "nextEvents": nextEvents == null
        ? null
        : List<dynamic>.from(nextEvents.map((x) => x.toJson())),
      };
}

class FavouriteEvent {
  FavouriteEvent({
    this.id,
    this.eventId,
  });

  int id;
  int eventId;

  factory FavouriteEvent.fromJson(Map<String, dynamic> json) => FavouriteEvent(
        id: json["id"] == null ? null : json["id"],
        eventId: json["eventId"] == null ? null : json["eventId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "eventId": eventId == null ? null : eventId,
      };
}


InterestGetModel interestGetModelFromJson(String str) =>
    InterestGetModel.fromJson(json.decode(str));

String interestGetModelToJson(InterestGetModel data) =>
    json.encode(data.toJson());

class InterestGetModel {
  InterestGetModel({
    this.id,
    this.artists,
    this.genres,
    this.favouriteEvents,
  });

  int id;
  List<ArtistTotemModel> artists;
  List<ArtistTotemModel> genres;
  List<EventHomeModel> favouriteEvents;

  factory InterestGetModel.fromJson(Map<String, dynamic> json) =>
      InterestGetModel(
        id: json["id"] == null ? null : json["id"],
        artists: json["artists"] == null
            ? null
            : List<ArtistTotemModel>.from(
            json["artists"].map((x) => ArtistTotemModel.fromJson(x))),
        genres: json["genres"] == null
            ? null
            : List<ArtistTotemModel>.from(
            json["genres"].map((x) => ArtistTotemModel.fromJson(x))),
        favouriteEvents: json["favouriteEvents"] == null
            ? null
            : List<EventHomeModel>.from(
            json["favouriteEvents"].map((x) => EventHomeModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "artists": artists == null
        ? null
        : List<dynamic>.from(artists.map((x) => x.toJson())),
    "genres": genres == null
        ? null
        : List<dynamic>.from(genres.map((x) => x.toJson())),
    "favouriteEvents": favouriteEvents == null
        ? null
        : List<dynamic>.from(favouriteEvents.map((x) => x.toJson())),
  };
}
