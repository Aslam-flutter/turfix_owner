import 'package:flutter/material.dart';
import 'package:turfix_owner/model/facilities_model.dart';
import 'package:turfix_owner/model/sport_model.dart';

class SportsSelectingProvider extends ChangeNotifier {
  List<SportModel> sports = [
    SportModel(name: "Football", icon: Icons.sports_soccer),
    SportModel(name: "Cricket", icon: Icons.sports_cricket),
    SportModel(name: "Badminton", icon: Icons.sports_tennis),
    SportModel(name: "Volleyball", icon: Icons.sports_volleyball),
    SportModel(name: "Tennis", icon: Icons.sports_tennis),
  ];

  List<FacilitiesModel> facilities = [
    FacilitiesModel(name: "Parking", icon: Icons.local_parking),

    FacilitiesModel(name: "Changing Room", icon: Icons.meeting_room_outlined),

    FacilitiesModel(name: "Shower", icon: Icons.shower_outlined),

    FacilitiesModel(name: "Washroom", icon: Icons.wc),

    FacilitiesModel(name: "Floodlights", icon: Icons.lightbulb_outline),

    FacilitiesModel(name: "Cafeteria", icon: Icons.local_cafe_outlined),

    FacilitiesModel(name: "Drinking Water", icon: Icons.local_drink_outlined),

    FacilitiesModel(name: "Wi-Fi", icon: Icons.wifi),

    FacilitiesModel(name: "CCTV", icon: Icons.videocam_outlined),

    FacilitiesModel(name: "First Aid", icon: Icons.medical_services_outlined),

    FacilitiesModel(name: "Locker", icon: Icons.lock_outline),

    FacilitiesModel(name: "Equipment Rental", icon: Icons.sports),

    FacilitiesModel(name: "Seating", icon: Icons.event_seat_outlined),

    FacilitiesModel(name: "Gallery", icon: Icons.groups_outlined),

    FacilitiesModel(name: "Refreshments", icon: Icons.fastfood_outlined),
  ];

  List<SportModel> gameFormats = [
    SportModel(name: "3s", icon: Icons.group),
    SportModel(name: "5s", icon: Icons.group),
    SportModel(name: "7s", icon: Icons.group),
    SportModel(name: "9s", icon: Icons.group),
    SportModel(name: "11s", icon: Icons.group),
  ];

  void toggleSport(int index) {
    sports[index].selected = !sports[index].selected;

    notifyListeners();
  }

  void toggleFacilities(int index) {
    facilities[index].selected = !facilities[index].selected;
    notifyListeners();
  }

  void toggleGameFormats(int index) {
    gameFormats[index].selected = !gameFormats[index].selected;
    notifyListeners();
  }

  List<String> get selectedSports =>
      sports.where((e) => e.selected).map((e) => e.name).toList();

  List<String> get selectedFacilities =>
      facilities.where((e) => e.selected).map((e) => e.name).toList();

  List<String> get selectedGameFormats =>
      gameFormats.where((e) => e.selected).map((e) => e.name).toList();
}
