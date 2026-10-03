import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:turfix_owner/widgets/scaffold_messanger.dart';

class GeoLocatorProvider extends ChangeNotifier {
  String address = 'Get turf location.';

  double? latitude;
  double? longitude;

  bool isLoading = false;

  Future<void> getCurrentLocation(BuildContext context) async {
    isLoading = true;
    address = 'Getting your location...';
    notifyListeners();

    try {
      // 1. Check location service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        address = 'Your location is not found';

        AppMessenger.customScaffoldMessenger(
          context,
          message: 'Please enable location services.',
        );

        return;
      }

      // 2. Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      // 3. Request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        address = 'Your location is not found';

        AppMessenger.customScaffoldMessenger(
          context,
          message: 'Location permission denied.',
        );

        return;
      }

      // 4. Permanently denied
      if (permission == LocationPermission.deniedForever) {
        address = 'Your location is not found';

        AppMessenger.customScaffoldMessenger(
          context,
          message:
              'Location permission permanently denied. '
              'Please enable it from settings.',
        );

        return;
      }

      // 5. Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Save coordinates
      latitude = position.latitude;
      longitude = position.longitude;

      debugPrint('LATITUDE: $latitude');

      debugPrint('LONGITUDE: $longitude');

      // 6. Reverse geocoding
      try {
        final geocoding = Geocoding();

        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final result = [
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');

          address = result.isNotEmpty ? result : 'Address not found';
        } else {
          address = 'Address not found';
        }
      } catch (e) {
        // Address lookup failed,
        // but GPS coordinates are still valid.
        debugPrint('Geocoding error: $e');

        address = 'Address not found';
      }
    } catch (e) {
      address = 'Unable to get location.';

      debugPrint('Location error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
