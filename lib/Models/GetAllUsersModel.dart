class GetAllUsersModel{
  List<Data> data;
  Meta meta;

  GetAllUsersModel({this.data, this.meta});

  GetAllUsersModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    if (this.meta != null) {
      data['meta'] = this.meta.toJson();
    }
    return data;
  }
}

class Data {
  int id;
  String image;
  String firstname;
  String lastname;
  int mutualCount;

  Data({this.id, this.image, this.firstname, this.lastname, this.mutualCount});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    mutualCount = json['mutualCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['mutualCount'] = this.mutualCount;
    return data;
  }
}

class Meta {
  bool status;
  String message;

  Meta({this.status, this.message});

  Meta.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}