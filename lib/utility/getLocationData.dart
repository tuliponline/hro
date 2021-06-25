import 'package:location/location.dart';

Future<LocationData> getLocationData() async {
  print('getting GPS');
  Location location;
  location = Location();

  try {
    return location.getLocation();
  } catch (e) {
    print('location Error = ' + e);
    return null;
  }
}