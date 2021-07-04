// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.uid,
    this.name,
    this.phone,
    this.email,
    this.photoUrl,
    this.location,
    this.status,
    this.token,
  });

  String uid;
  String name;
  String phone;
  String email;
  String photoUrl;
  String location;
  String status;
  String token;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json["uid"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    photoUrl: json["photo_url"],
    location: json["location"],
    status: json["status"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "phone": phone,
    "email": email,
    "photo_url": photoUrl,
    "location": location,
    "status": status,
    "token": token,
  };
}

// To parse this JSON data, do
//
//     final allUserModel = allUserModelFromJson(jsonString);


List<AllUserModel> allUserModelFromJson(String str) => List<AllUserModel>.from(json.decode(str).map((x) => AllUserModel.fromJson(x)));

String allUserModelToJson(List<AllUserModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllUserModel {
  AllUserModel({
    this.uid,
    this.phone,
    this.name,
    this.location,
    this.photoUrl,
    this.email,
    this.token,
    this.status,
  });

  String uid;
  dynamic phone;
  String name;
  String location;
  String photoUrl;
  String email;
  String token;
  String status;

  factory AllUserModel.fromJson(Map<String, dynamic> json) => AllUserModel(
    uid: json["uid"],
    phone: json["phone"],
    name: json["name"],
    location: json["location"],
    photoUrl: json["photo_url"],
    email: json["email"],
    token: json["token"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "phone": phone,
    "name": name,
    "location": location,
    "photo_url": photoUrl,
    "email": email,
    "token": token,
    "status": status,
  };
}

