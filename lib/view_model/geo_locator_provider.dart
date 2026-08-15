import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:turfix_owner/widgets/scaffold_messanger.dart';

class GeoLocatorProvider extends ChangeNotifier {
  // GeoLocatorProvider() {
  //   getCurrentLocation();
  // }
  String address = 'Get turf location.';

  double? latitude;
  double? longitude;

  bool isLoading = false;
  BuildContext? context;

  Future<void> getCurrentLocation() async {
    isLoading = true;
    address = 'Getting your location...';
    notifyListeners();

    try {
      // 1. Check whether location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        address = 'Your location is not found';
        AppMessenger.customScaffoldMessenger(
          context!,
          message: 'Please enable location services.',
        );
        isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      // 3. Request permission if not granted
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          // address = 'Location permission denied.';
          address = 'Your location is not found';
          AppMessenger.customScaffoldMessenger(
            context!,
            message: 'Location permission denied.',
          );
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      // 4. Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        // address =
        //     'Location permission permanently denied. '
        //     'Please enable it from settings.';
        address = 'Your location is not found';
        AppMessenger.customScaffoldMessenger(
          context!,
          message:
              'Location permission permanently denied. '
              'Please enable it from settings.',
        );
        isLoading = false;
        notifyListeners();
        return;
      }

      // 5. Get current position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      latitude = position.latitude;
      longitude = position.longitude;

      // 6. Convert coordinates to address
      final Geocoding geocoding = Geocoding();
      final List<Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final String result = [
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        address = result;
        isLoading = false;
        notifyListeners();
      } else {
        address = 'Address not found';
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      address = 'Unable to get location.';
      isLoading = false;
      notifyListeners();

      debugPrint('Location error: $e');
    }
  }
}
