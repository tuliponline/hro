// To parse this JSON data, do
//
//     final locationSetupModel = locationSetupModelFromJson(jsonString);

import 'dart:convert';

LocationSetupModel locationSetupModelFromJson(String str) => LocationSetupModel.fromJson(json.decode(str));

String locationSetupModelToJson(LocationSetupModel data) => json.encode(data.toJson());

class LocationSetupModel {
  LocationSetupModel({
    this.distanceMax,
    this.centerLocation,
    this.distanceStart,
    this.costDeliveryPerKm,
    this.costDeliveryMin,
    this.distanceFromShop,
    this.costDeliveryPerPcs,
  });

  String distanceMax;
  String centerLocation;
  String distanceStart;
  String costDeliveryPerKm;
  String costDeliveryMin;
  String distanceFromShop;
  String costDeliveryPerPcs;

  factory LocationSetupModel.fromJson(Map<String, dynamic> json) => LocationSetupModel(
    distanceMax: json["distanceMax"],
    centerLocation: json["centerLocation"],
    distanceStart: json["distanceStart"],
    costDeliveryPerKm: json["costDeliveryPerKm"],
    costDeliveryMin: json["costDeliveryMin"],
    distanceFromShop: json["distanceFromShop"],
    costDeliveryPerPcs: json["costDeliveryPerPcs"],
  );

  Map<String, dynamic> toJson() => {
    "distanceMax": distanceMax,
    "centerLocation": centerLocation,
    "distanceStart": distanceStart,
    "costDeliveryPerKm": costDeliveryPerKm,
    "costDeliveryMin": costDeliveryMin,
    "distanceFromShop": distanceFromShop,
    "costDeliveryPerPcs": costDeliveryPerPcs,
  };
}
