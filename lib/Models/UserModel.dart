class UserInfoModel {
  UserInfoModel({
    this.id,
    this.firstname,
    this.messageNotification,
    this.eventNotification,
    this.followNotification,
    this.lastname,
    this.username,
    this.email,
    this.phone,
    this.birthDate,
    this.role,
    this.isActive,
    this.bussinessUser,
    this.profileVerified,
    this.isBusinessRequestSend,
    this.isProfileVarificationRequestSend,
    this.isEmailVerified,
    this.city,
    this.state,
    this.bio,
    this.image,
    this.gender,
    this.isMobileVerified,
    this.token,
    this.signInType,
    this.address,
    this.longitude,
    this.latitude,
    this.isPrivate,
  });

  int id;
  String firstname;
  bool messageNotification;
  bool eventNotification;
  bool followNotification;
  String lastname;
  String username;
  String email;
  String phone;
  String birthDate;
  int role;
  bool isActive;
  bool bussinessUser;
  bool profileVerified;
  bool isBusinessRequestSend;
  bool isProfileVarificationRequestSend;
  bool isEmailVerified;
  dynamic city;
  dynamic state;
  dynamic bio;
  dynamic image;
  int gender;
  bool isMobileVerified;
  String token;
  String address;
  String longitude;
  String latitude;
  int signInType;
  bool isPrivate;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) => UserInfoModel(
        id: json["id"] == null ? null : json["id"],
        firstname: json["firstname"] == null ? null : json["firstname"],
        messageNotification: json["messageNotification"] == null
            ? false
            : json["messageNotification"],
        eventNotification: json["eventNotification"] == null
            ? false
            : json["eventNotification"],
        followNotification: json["followNotification"] == null
            ? false
            : json["followNotification"],
        lastname: json["lastname"] == null ? null : json["lastname"],
        username: json["username"] == null ? null : json["username"],
        email: json["email"] == null ? null : json["email"],
        phone: json["phone"] == null ? null : json["phone"],
        birthDate: json["birthDate"] == null ? null : json["birthDate"],
        role: json["role"] == null ? null : json["role"],
        isActive: json["isActive"] == null ? null : json["isActive"],
        bussinessUser:
            json["bussinessUser"] == null ? null : json["bussinessUser"],
        profileVerified:
            json["profileVerified"] == null ? null : json["profileVerified"],
        isBusinessRequestSend: json["isBusinessRequestSend"] == null
            ? null
            : json["isBusinessRequestSend"],
        isProfileVarificationRequestSend:
            json["isProfileVarificationRequestSend"] == null
                ? null
                : json["isProfileVarificationRequestSend"],
        isEmailVerified:
            json["isEmailVerified"] == null ? null : json["isEmailVerified"],
        city: json["city"] == null ? '' : json["city"],
        state: json["state"] == null ? '' : json["state"],
        bio: json["bio"] == null ? '' : json["bio"],
        image: json["image"] == null ? '' : json["image"],
        gender: json["gender"] == null ? '' : json["gender"],
        isMobileVerified:
            json["isMobileVerified"] == null ? null : json["isMobileVerified"],
        token: json["token"] == null ? null : json["token"],
        address: json["address"] == null ? '' : json["address"],
        longitude: json["longitude"] == null ? '0.0' : json["longitude"],
        latitude: json["latitude"] == null ? '0.0' : json["latitude"],
        signInType: json["signInType"] == null ? null : json["signInType"],
        isPrivate: json["isPrivate"] == null ? false : json["isPrivate"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "firstname": firstname == null ? null : firstname,
        "messageNotification":
            messageNotification == null ? false : messageNotification,
        "eventNotification":
            eventNotification == null ? false : eventNotification,
        "followNotification":
            followNotification == null ? false : followNotification,
        "lastname": lastname == null ? null : lastname,
        "username": username == null ? null : username,
        "email": email == null ? null : email,
        "phone": phone == null ? null : phone,
        "birthDate": birthDate == null ? null : birthDate,
        "role": role == null ? null : role,
        "isActive": isActive == null ? null : isActive,
        "bussinessUser": bussinessUser == null ? null : bussinessUser,
        "profileVerified": profileVerified == null ? null : profileVerified,
        "isBusinessRequestSend":
            isBusinessRequestSend == null ? null : isBusinessRequestSend,
        "isProfileVarificationRequestSend":
            isProfileVarificationRequestSend == null
                ? null
                : isProfileVarificationRequestSend,
        "isEmailVerified": isEmailVerified == null ? null : isEmailVerified,
        "city": city,
        "state": state,
        "bio": bio,
        "image": image,
        "gender": gender == null ? null : gender,
        "isMobileVerified": isMobileVerified == null ? null : isMobileVerified,
        "token": token == null ? null : token,
        "address": address == null ? null : address,
        "longitude": longitude == null ? null : longitude,
        "latitude": latitude == null ? null : latitude,
        "signInType": signInType == null ? null : signInType,
        "isPrivate": isPrivate == null ? false : isPrivate,
      };
}

class UserMetaModel {
  bool status;
  String message;

  UserMetaModel({this.status, this.message});

  factory UserMetaModel.fromJson(Map<String, dynamic> meta) {
    return UserMetaModel(status: meta['status'], message: meta['message']);
  }
}

class UserModel {
  dynamic data;
  dynamic meta;

  UserModel({this.data, this.meta});

  factory UserModel.fromJson(dynamic json) {
    return UserModel(
        data: (json['data'] == null || json['data'] == "")
            ? null
            : UserInfoModel.fromJson(json['data']),
        meta: UserMetaModel.fromJson(json['meta']));
  }
}
