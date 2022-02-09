// To parse this JSON data, do
//
//     final trackModel = trackModelFromJson(jsonString);

import 'dart:convert';

class Tracks {
  Tracks({
    this.href,
    this.items,
    this.limit,
    this.next,
    this.offset,
    this.previous,
    this.total,
  });

  String href;
  List<TrackItem> items;
  int limit;
  String next;
  int offset;
  dynamic previous;
  int total;

  factory Tracks.fromJson(Map<String, dynamic> json) => Tracks(
        href: json["href"] == null ? null : json["href"],
        items: json["items"] == null
            ? null
            : List<TrackItem>.from(
                json["items"].map((x) => TrackItem.fromJson(x))),
        limit: json["limit"] == null ? null : json["limit"],
        next: json["next"] == null ? null : json["next"],
        offset: json["offset"] == null ? null : json["offset"],
        previous: json["previous"],
        total: json["total"] == null ? null : json["total"],
      );

  Map<String, dynamic> toJson() => {
        "href": href == null ? null : href,
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson())),
        "limit": limit == null ? null : limit,
        "next": next == null ? null : next,
        "offset": offset == null ? null : offset,
        "previous": previous,
        "total": total == null ? null : total,
      };
}

class TrackItem {
  TrackItem(
      {this.album,
      this.artists,
      this.externalUrls,
      this.href,
      this.id,
      this.name});

  Album album;
  List<Artist> artists;
  ExternalUrls externalUrls;
  String href;
  String id;
  String name;

  factory TrackItem.fromJson(Map<String, dynamic> json) => TrackItem(
      album: json["album"] == null ? null : Album.fromJson(json["album"]),
      artists: json["artists"] == null
          ? null
          : List<Artist>.from(json["artists"].map((x) => Artist.fromJson(x))),
      externalUrls: json["external_urls"] == null
          ? null
          : ExternalUrls.fromJson(json["external_urls"]),
      href: json["href"] == null ? null : json["href"],
      id: json["id"] == null ? null : json["id"],
      name: json["name"] == null ? null : json["name"]);

  Map<String, dynamic> toJson() => {
        "album": album == null ? null : album.toJson(),
        "artists": artists == null
            ? null
            : List<dynamic>.from(artists.map((x) => x.toJson())),
        "external_urls": externalUrls == null ? null : externalUrls.toJson(),
        "href": href == null ? null : href,
        "id": id == null ? null : id,
        "name": name == null ? null : name
      };
}

class Album {
  Album({this.images, this.name, this.id});

  List<Image> images;
  String name;
  String id;

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        images: json["images"] == null
            ? null
            : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        name: json["name"] == null ? null : json["name"],
    id: json["id"] == null ? null : json["id"],
      );

  Map<String, dynamic> toJson() => {
        "images": images == null
            ? null
            : List<dynamic>.from(images.map((x) => x.toJson())),
        "name": name == null ? null : name,
        "id": id == null ? null : id,
      };
}

class Artist {
  Artist({
    this.id,
    this.name,
  });

  String id;
  String name;

  factory Artist.fromJson(Map<String, dynamic> json) => Artist(
      id: json["id"] == null ? null : json["id"],
      name: json["name"] == null ? null : json["name"]);

  Map<String, dynamic> toJson() =>
      {"id": id == null ? null : id, "name": name == null ? null : name};
}

class ExternalUrls {
  ExternalUrls({
    this.spotify,
  });

  String spotify;

  factory ExternalUrls.fromJson(Map<String, dynamic> json) => ExternalUrls(
        spotify: json["spotify"] == null ? null : json["spotify"],
      );

  Map<String, dynamic> toJson() => {
        "spotify": spotify == null ? null : spotify,
      };
}

enum ArtistType { ARTIST }

final artistTypeValues = EnumValues({"artist": ArtistType.ARTIST});

class Image {
  Image({
    this.height,
    this.url,
    this.width,
  });

  int height;
  String url;
  int width;

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        height: json["height"] == null ? null : json["height"],
        url: json["url"] == null ? null : json["url"],
        width: json["width"] == null ? null : json["width"],
      );

  Map<String, dynamic> toJson() => {
        "height": height == null ? null : height,
        "url": url == null ? null : url,
        "width": width == null ? null : width,
      };
}

enum ReleaseDatePrecision { DAY }

final releaseDatePrecisionValues =
    EnumValues({"day": ReleaseDatePrecision.DAY});

enum AlbumTypeEnum { ALBUM }

final albumTypeEnumValues = EnumValues({"album": AlbumTypeEnum.ALBUM});

class ExternalIds {
  ExternalIds({
    this.isrc,
  });

  String isrc;

  factory ExternalIds.fromJson(Map<String, dynamic> json) => ExternalIds(
        isrc: json["isrc"] == null ? null : json["isrc"],
      );

  Map<String, dynamic> toJson() => {
        "isrc": isrc == null ? null : isrc,
      };
}

enum ItemType { TRACK }

final itemTypeValues = EnumValues({"track": ItemType.TRACK});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
