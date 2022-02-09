class UpdateUserModel {
  String firstName;
  String lastName;
  String email;
  String phone;
  String birthDate;
  String username;
  String password;
  int role;
  int id;
  String city;
  String state;
  String bio;
  String image;

  UpdateUserModel(
      {this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.birthDate,
        this.username,
        this.password,
        this.role,
        this.id,
        this.city,
        this.state,
        this.bio,
        this.image});

  UpdateUserModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    phone = json['phone'];
    birthDate = json['birthDate'];
    username = json['username'];
    password = json['password'];
    role = json['role'];
    id = json['id'];
    city = json['city'];
    state = json['state'];
    bio = json['bio'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['birthDate'] = this.birthDate;
    data['username'] = this.username;
    data['password'] = this.password;
    data['role'] = this.role;
    data['id'] = this.id;
    data['city'] = this.city;
    data['state'] = this.state;
    data['bio'] = this.bio;
    data['image'] = this.image;
    return data;
  }
}

class UpdateUserData{
  UpdateUserData({
    this.result,
    this.meta,
  });

  String result;
  Meta meta;

  factory UpdateUserData.fromJson(Map<String, dynamic> json) => UpdateUserData(
    result: json["result"] == null ? null : json["result"],
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "result": result == null ? null : result,
    "meta": meta == null ? null : meta.toJson(),
  };
}

class Meta {
  Meta({
    this.status,
    this.message,
  });

  bool status;
  String message;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    status: json["status"] == null ? null : json["status"],
    message: json["message"] == null ? null : json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status == null ? null : status,
    "message": message == null ? null : message,
  };
}
