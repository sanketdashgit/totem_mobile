class CreateAccountModel {
  String firstName;
  String lastName;
  String email;
  String phone;
  String birthDate;
  String username;
  String password;
  int role;

  CreateAccountModel(
      {this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.birthDate,
      this.username,
      this.password,
      this.role});

  CreateAccountModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    phone = json['phone'];
    birthDate = json['birthDate'];
    username = json['username'];
    password = json['password'];
    role = json['role'];
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
    return data;
  }
}
