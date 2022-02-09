// To parse this JSON data, do
//
//     final artistModel = artistModelFromJson(jsonString);

import 'dart:convert';

class Artists {
  Artists({this.items});

  List<ArtistItem> items;

  factory Artists.fromJson(Map<String, dynamic> json) => Artists(
      items: json["items"] == null
          ? null
          : List<ArtistItem>.from(
              json["items"].map((x) => ArtistItem.fromJson(x))));

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? null
            : List<dynamic>.from(items.map((x) => x.toJson()))
      };
}

class ArtistItem {
  ArtistItem({
    this.href,
    this.id,
    this.images,
    this.name,
    this.popularity,
    this.type,
    this.uri,
  });

  String href;
  String id;
  List<Image> images;
  String name;
  int popularity;
  String type;
  String uri;

  factory ArtistItem.fromJson(Map<String, dynamic> json) => ArtistItem(
        href: json["href"] == null ? null : json["href"],
        id: json["id"] == null ? null : json["id"],
        images: json["images"] == null
            ? null
            : List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
        name: json["name"] == null ? null : json["name"],
        popularity: json["popularity"] == null ? null : json["popularity"],
        type: json["type"] == null ? null : json["type"],
        uri: json["uri"] == null ? null : json["uri"],
      );

  Map<String, dynamic> toJson() => {
        "href": href == null ? null : href,
        "id": id == null ? null : id,
        "images": images == null
            ? null
            : List<dynamic>.from(images.map((x) => x.toJson())),
        "name": name == null ? null : name,
        "popularity": popularity == null ? null : popularity,
        "type": type == null ? null : type,
        "uri": uri == null ? null : uri,
      };
}

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
