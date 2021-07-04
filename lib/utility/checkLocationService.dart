
import 'package:geolocator/geolocator.dart';
Future<bool> checkLocationService() async {
  bool locationService;
  locationService = await Geolocator.isLocationServiceEnabled();
  if (locationService){
    print("LocationService Open");
  }else{
    print("LocationService Close");
  }
  return locationService;
}