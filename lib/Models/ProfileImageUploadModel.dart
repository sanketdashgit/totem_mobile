class ProfileImageUploadModel{
  String data;
  Meta meta;

  ProfileImageUploadModel({this.data, this.meta});

  ProfileImageUploadModel.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data;
    if (this.meta != null) {
      data['meta'] = this.meta.toJson();
    }
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