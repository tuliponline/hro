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
  });

  String uid;
  String name;
  String phone;
  String email;
  String photoUrl;
  String location;
  String status;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json["uid"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    photoUrl: json["photo_url"],
    location: json["location"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "name": name,
    "phone": phone,
    "email": email,
    "photo_url": photoUrl,
    "location": location,
    "status": status,
  };
}
