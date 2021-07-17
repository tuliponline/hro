import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';

Future<String> getAddressName(double lat, double lng) async {
  final coordinates = new Coordinates(lat, lng);
  var addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  print("Address Name =${first.addressLine}");
  return (first.addressLine);
}

double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  double distance = 0;
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
  distance = 12742 * asin(sqrt(a));
  return distance;
}

Future<bool> checkLocationLimit(
    double lat1, double lng1, double lat2, double lng2, distanceLimit) async {
  double distance = 0;
  bool inService;
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
  distance = 12742 * asin(sqrt(a));

  if (distance > distanceLimit) {
    inService = false;
  } else {
    inService = true;
  }
  return inService;
}

Future<List<String>> calDistanceAndCostDelivery(
    double lat1, double lng1, double lat2, double lng2, int distanceMin,costStart,costPerKm) async {
  double distance = 0;
  int costDelivery = costStart;

  print("distanceMin = $distanceMin");
  print("costStart = $costStart");
  print("costPerKm = $costPerKm");

  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
  distance = 12742 * asin(sqrt(a));

  int distanceFinal = distance.ceil();
  int distanceLeft;
if(distance > distanceMin){
 distanceLeft =  distanceFinal - distanceMin;
 costDelivery += (costPerKm * distanceLeft);
}

print("distance true = $distance");
  print("distanceFinal = $distanceFinal");
  print("distanceLeft = $distanceLeft");
  print("costDelivery = $costDelivery");
  // if (distance > distanceLimit) {
  // //outService
  // }

  return [distance.toString(),costDelivery.toString()];
}
