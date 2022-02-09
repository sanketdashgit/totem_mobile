// To parse this JSON data, do
//
//     final eventTicketMaster = eventTicketMasterFromJson(jsonString);

import 'dart:convert';

EventTicketMaster eventTicketMasterFromJson(String str) => EventTicketMaster.fromJson(json.decode(str));

String eventTicketMasterToJson(EventTicketMaster data) => json.encode(data.toJson());

class EventTicketMaster {
  EventTicketMaster({
    this.name,
    this.id,
    this.url,
    this.images,
    this.dates,
    this.embedded,
  });

  String name;
  String id;
  String url;
  List<ImageTicket> images;
  DatesTicket dates;
  Embedded embedded;

  factory EventTicketMaster.fromJson(Map<String, dynamic> json) => EventTicketMaster(
    name: json["name"] == null ? null : json["name"],
    id: json["id"] == null ? null : json["id"],
    url: json["url"] == null ? null : json["url"],
    images: json["images"] == null ? null : List<ImageTicket>.from(json["images"].map((x) => ImageTicket.fromJson(x))),
    dates: json["dates"] == null ? null : DatesTicket.fromJson(json["dates"]),
    embedded: json["_embedded"] == null ? null : Embedded.fromJson(json["_embedded"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : name,
    "id": id == null ? null : id,
    "url": url == null ? null : url,
    "images": images == null ? null : List<dynamic>.from(images.map((x) => x.toJson())),
    "dates": dates == null ? null : dates.toJson(),
    "_embedded": embedded == null ? null : embedded.toJson(),
  };
}

class DatesTicket {
  DatesTicket({
    this.start,
  });

  Start start;

  factory DatesTicket.fromJson(Map<String, dynamic> json) => DatesTicket(
    start: json["start"] == null ? null : Start.fromJson(json["start"]),
  );

  Map<String, dynamic> toJson() => {
    "start": start == null ? null : start.toJson(),
  };
}

class Start {
  Start({
    this.dateTime,
  });

  DateTime dateTime;

  factory Start.fromJson(Map<String, dynamic> json) => Start(
    dateTime: json["dateTime"] == null ? null : DateTime.parse(json["dateTime"]),
  );

  Map<String, dynamic> toJson() => {
    "dateTime": dateTime == null ? null : dateTime.toIso8601String(),
  };
}

class Embedded {
  Embedded({
    this.venues,
  });

  List<Venue> venues;

  factory Embedded.fromJson(Map<String, dynamic> json) => Embedded(
    venues: json["venues"] == null ? null : List<Venue>.from(json["venues"].map((x) => Venue.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "venues": venues == null ? null : List<dynamic>.from(venues.map((x) => x.toJson())),
  };
}

class Venue {
  Venue({
    this.name,
    this.type,
    this.id,
    this.city,
    this.state,
    this.country,
    this.address,
    this.location,
  });

  String name;
  String type;
  String id;
  CityTicket city;
  StateTicket state;
  CountryTicket country;
  AddressTicket address;
  LocationTicket location;

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
    name: json["name"] == null ? '' : json["name"],
    type: json["type"] == null ? null : json["type"],
    id: json["id"] == null ? null : json["id"],
    city: json["city"] == null ? null : CityTicket.fromJson(json["city"]),
    state: json["state"] == null ? null : StateTicket.fromJson(json["state"]),
    country: json["country"] == null ? null : CountryTicket.fromJson(json["country"]),
    address: json["address"] == null ? null : AddressTicket.fromJson(json["address"]),
    location: json["location"] == null ? null : LocationTicket.fromJson(json["location"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : name,
    "type": type == null ? null : type,
    "id": id == null ? null : id,
    "city": city == null ? null : city.toJson(),
    "state": state == null ? null : state.toJson(),
    "country": country == null ? null : country.toJson(),
    "address": address == null ? null : address.toJson(),
    "location": location == null ? null : location.toJson(),
  };
}

class AddressTicket {
  AddressTicket({
    this.line1,
  });

  String line1;

  factory AddressTicket.fromJson(Map<String, dynamic> json) => AddressTicket(
    line1: json["line1"] == null ? null : json["line1"],
  );

  Map<String, dynamic> toJson() => {
    "line1": line1 == null ? null : line1,
  };
}

class CityTicket {
  CityTicket({
    this.name,
  });

  String name;

  factory CityTicket.fromJson(Map<String, dynamic> json) => CityTicket(
    name: json["name"] == null ? '' : json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : name,
  };
}

class CountryTicket {
  CountryTicket({
    this.name,
    this.countryCode,
  });

  String name;
  String countryCode;

  factory CountryTicket.fromJson(Map<String, dynamic> json) => CountryTicket(
    name: json["name"] == null ? '' : json["name"],
    countryCode: json["countryCode"] == null ? '' : json["countryCode"],
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : name,
    "countryCode": countryCode == null ? null : countryCode,
  };
}

class LocationTicket {
  LocationTicket({
    this.longitude,
    this.latitude,
  });

  String longitude;
  String latitude;

  factory LocationTicket.fromJson(Map<String, dynamic> json) => LocationTicket(
    longitude: json["longitude"] == null ? null : json["longitude"],
    latitude: json["latitude"] == null ? null : json["latitude"],
  );

  Map<String, dynamic> toJson() => {
    "longitude": longitude == null ? null : longitude,
    "latitude": latitude == null ? null : latitude,
  };
}

class StateTicket {
  StateTicket({
    this.name,
    this.stateCode,
  });

  String name;
  String stateCode;

  factory StateTicket.fromJson(Map<String, dynamic> json) => StateTicket(
    name: json["name"] == null ? '' : json["name"],
    stateCode: json["stateCode"] == null ? null : json["stateCode"],
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : name,
    "stateCode": stateCode == null ? null : stateCode,
  };
}

class ImageTicket {
  ImageTicket({
    this.url,
  });

  String url;

  factory ImageTicket.fromJson(Map<String, dynamic> json) => ImageTicket(
    url: json["url"] == null ? null : json["url"],
  );

  Map<String, dynamic> toJson() => {
    "url": url == null ? null : url,
  };
}
