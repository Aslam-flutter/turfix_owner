import 'package:flutter/material.dart';

class AppFuctions {
  static IconData getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'football':
        return Icons.sports_soccer;

      case 'cricket':
        return Icons.sports_cricket;

      case 'badminton':
        return Icons.sports_tennis;

      case 'volleyball':
        return Icons.sports_volleyball;

      case 'tennis':
        return Icons.sports_tennis;

      default:
        return Icons.sports;
    }
  }

  static IconData getFacilityIcon(String facility) {
    switch (facility.toLowerCase()) {
      case 'parking':
        return Icons.local_parking;

      case 'changing room':
        return Icons.meeting_room_outlined;

      case 'shower':
        return Icons.shower_outlined;

      case 'washroom':
        return Icons.wc;

      case 'floodlights':
        return Icons.lightbulb_outline;

      case 'cafeteria':
        return Icons.local_cafe_outlined;

      case 'drinking water':
        return Icons.local_drink_outlined;

      case 'wi-fi':
        return Icons.wifi;

      case 'cctv':
        return Icons.videocam_outlined;

      case 'first aid':
        return Icons.medical_services_outlined;

      case 'locker':
        return Icons.lock_outline;

      case 'equipment rental':
        return Icons.sports;

      case 'seating':
        return Icons.event_seat_outlined;

      case 'gallery':
        return Icons.groups_outlined;

      case 'refreshments':
        return Icons.fastfood_outlined;

      default:
        return Icons.check_circle_outline;
    }
  }
}
