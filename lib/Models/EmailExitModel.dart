

class EmailExitModel{
  String data;
  EmailMetaModel meta;

  EmailExitModel({this.data, this.meta});

  EmailExitModel.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    meta = json['meta'] != null ? new EmailMetaModel.fromJson(json['meta']) : null;
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

class EmailMetaModel {
  bool status;
  String message;

  EmailMetaModel({this.status, this.message});

  EmailMetaModel.fromJson(Map<String, dynamic> json) {
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