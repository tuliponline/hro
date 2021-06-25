// To parse this JSON data, do
//
//     final driversModel = driversModelFromJson(jsonString);

import 'dart:convert';

List<DriversListModel> driversListModelFromJson(String str) =>
    List<DriversListModel>.from(
        json.decode(str).map((x) => DriversListModel.fromJson(x)));

String driversListModelToJson(List<DriversListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DriversListModel {
  DriversListModel({
    this.driverLocation,
    this.driverId,
    this.onlineTime,
    this.driverPhotoUrl,
    this.driverPhone,
    this.driverName,
    this.driverAddress,
    this.driverStatus,
    this.token,
  });

  String driverLocation;
  String driverId;
  String onlineTime;
  String driverPhotoUrl;
  String driverPhone;
  String driverName;
  String driverAddress;
  String driverStatus;
  String token;

  factory DriversListModel.fromJson(Map<String, dynamic> json) =>
      DriversListModel(
        driverLocation: json["driverLocation"],
        driverId: json["driverId"],
        onlineTime: json["onlineTime"],
        driverPhotoUrl: json["driverPhotoUrl"],
        driverPhone: json["driverPhone"],
        driverName: json["driverName"],
        driverAddress: json["driverAddress"],
        driverStatus: json["driverStatus"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "driverLocation": driverLocation,
        "driverId": driverId,
        "onlineTime": onlineTime,
        "driverPhotoUrl": driverPhotoUrl,
        "driverPhone": driverPhone,
        "driverName": driverName,
        "driverAddress": driverAddress,
        "driverStatus": driverStatus,
        "token": token,
      };
}

DriversModel driversModelFromJson(String str) =>
    DriversModel.fromJson(json.decode(str));

String driversModelToJson(DriversModel data) => json.encode(data.toJson());

class DriversModel {
  DriversModel({
    this.driverLocation,
    this.driverId,
    this.onlineTime,
    this.driverPhotoUrl,
    this.driverName,
    this.driverPhone,
    this.driverAddress,
    this.driverStatus,
    this.token,
  });

  String driverLocation;
  String driverId;
  String onlineTime;
  String driverPhotoUrl;
  String driverName;
  String driverPhone;
  String driverAddress;
  String driverStatus;
  String token;

  factory DriversModel.fromJson(Map<String, dynamic> json) => DriversModel(
        driverLocation: json["driverLocation"],
        driverId: json["driverId"],
        onlineTime: json["onlineTime"],
        driverPhotoUrl: json["driverPhotoUrl"],
        driverName: json["driverName"],
        driverPhone: json["driverPhone"],
        driverAddress: json["driverAddress"],
        driverStatus: json["driverStatus"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "driverLocation": driverLocation,
        "driverId": driverId,
        "onlineTime": onlineTime,
        "driverPhotoUrl": driverPhotoUrl,
        "driverName": driverName,
        "driverPhone": driverPhone,
        "driverAddress": driverAddress,
        "driverStatus": driverStatus,
        "token": token,
      };
}
