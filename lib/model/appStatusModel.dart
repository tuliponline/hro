// To parse this JSON data, do
//
//     final appStatusModel = appStatusModelFromJson(jsonString);

import 'dart:convert';

AppStatusModel appStatusModelFromJson(String str) => AppStatusModel.fromJson(json.decode(str));

String appStatusModelToJson(AppStatusModel data) => json.encode(data.toJson());

class AppStatusModel {
  AppStatusModel({
    this.costDelivery,
    this.projectVersion,
    this.dateopen,
    this.customerOpen,
    this.status,
  });

  String costDelivery;
  String projectVersion;
  String dateopen;
  String customerOpen;
  String status;

  factory AppStatusModel.fromJson(Map<String, dynamic> json) => AppStatusModel(
    costDelivery: json["costDelivery"],
    projectVersion: json["projectVersion"],
    dateopen: json["dateopen"],
    customerOpen: json["customerOpen"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "costDelivery": costDelivery,
    "projectVersion": projectVersion,
    "dateopen": dateopen,
    "customerOpen": customerOpen,
    "status": status,
  };
}
