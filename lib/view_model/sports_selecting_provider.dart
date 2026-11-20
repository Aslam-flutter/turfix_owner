import 'package:flutter/material.dart';
import 'package:turfix_owner/model/facilities_model.dart';

class SportSetting {
  final String name;
  final IconData icon;
  final bool isCustom;
  bool isSelected;
  List<String> availableFormats;
  Set<String> selectedFormats;
  final TextEditingController priceController;

  SportSetting({
    required this.name,
    required this.icon,
    this.isCustom = false,
    this.isSelected = false,
    required this.availableFormats,
    required Set<String> selectedFormats,
    String initialPrice = '1000',
  })  : selectedFormats = selectedFormats,
        priceController = TextEditingController(text: initialPrice);

  double? get price => double.tryParse(priceController.text.trim());

  void dispose() {
    priceController.dispose();
  }
}

class SportsSelectingProvider extends ChangeNotifier {
  late List<SportSetting> _sports;

  List<FacilitiesModel> facilities = [
    FacilitiesModel(name: "Parking", icon: Icons.local_parking, selected: true),
    FacilitiesModel(
      name: "Changing Room",
      icon: Icons.meeting_room_outlined,
      selected: true,
    ),
    FacilitiesModel(name: "Shower", icon: Icons.shower_outlined),
    FacilitiesModel(name: "Washroom", icon: Icons.wc, selected: true),
    FacilitiesModel(
      name: "Floodlights",
      icon: Icons.lightbulb_outline,
      selected: true,
    ),
    FacilitiesModel(name: "Cafeteria", icon: Icons.local_cafe_outlined),
    FacilitiesModel(
      name: "Drinking Water",
      icon: Icons.local_drink_outlined,
      selected: true,
    ),
    FacilitiesModel(name: "Wi-Fi", icon: Icons.wifi),
    FacilitiesModel(name: "CCTV", icon: Icons.videocam_outlined),
    FacilitiesModel(name: "First Aid", icon: Icons.medical_services_outlined),
    FacilitiesModel(name: "Locker", icon: Icons.lock_outline),
    FacilitiesModel(name: "Equipment Rental", icon: Icons.sports),
    FacilitiesModel(name: "Seating", icon: Icons.event_seat_outlined),
    FacilitiesModel(name: "Gallery", icon: Icons.groups_outlined),
    FacilitiesModel(name: "Refreshments", icon: Icons.fastfood_outlined),
  ];

  SportsSelectingProvider() {
    _initDefaultSports();
  }

  void _initDefaultSports() {
    _sports = [
      SportSetting(
        name: "Football",
        icon: Icons.sports_soccer,
        isSelected: true,
        initialPrice: "1200",
        availableFormats: ["5s", "6s", "7s", "9s", "11s", "Futsal"],
        selectedFormats: {"5s", "7s"},
      ),
      SportSetting(
        name: "Cricket",
        icon: Icons.sports_cricket,
        isSelected: false,
        initialPrice: "1500",
        availableFormats: ["Box Cricket", "Net Practice", "Overarm Turf (8v8)"],
        selectedFormats: {"Box Cricket"},
      ),
      SportSetting(
        name: "Badminton",
        icon: Icons.sports_tennis,
        isSelected: false,
        initialPrice: "500",
        availableFormats: ["Singles", "Doubles", "Wooden Court", "Synthetic"],
        selectedFormats: {"Singles", "Doubles"},
      ),
      SportSetting(
        name: "Volleyball",
        icon: Icons.sports_volleyball,
        isSelected: false,
        initialPrice: "800",
        availableFormats: ["Standard (6v6)", "Beach / Mud Volleyball"],
        selectedFormats: {"Standard (6v6)"},
      ),
      SportSetting(
        name: "Tennis",
        icon: Icons.sports_tennis,
        isSelected: false,
        initialPrice: "1000",
        availableFormats: ["Singles", "Doubles", "Clay Court", "Synthetic"],
        selectedFormats: {"Singles", "Doubles"},
      ),
      SportSetting(
        name: "Basketball",
        icon: Icons.sports_basketball,
        isSelected: false,
        initialPrice: "900",
        availableFormats: ["3v3 Half Court", "5v5 Full Court"],
        selectedFormats: {"5v5 Full Court"},
      ),
    ];
  }

  List<SportSetting> get sports => _sports;

  List<SportSetting> get selectedSportsList =>
      _sports.where((s) => s.isSelected).toList();

  List<String> get selectedSports =>
      selectedSportsList.map((s) => s.name).toList();

  List<String> get selectedFacilities =>
      facilities.where((e) => e.selected).map((e) => e.name).toList();

  List<String> get selectedGameFormats {
    final Set<String> allSelected = {};
    for (final sport in selectedSportsList) {
      allSelected.addAll(sport.selectedFormats);
    }
    return allSelected.toList();
  }

  Map<String, dynamic> get sportsConfig {
    final Map<String, dynamic> config = {};
    for (final sport in selectedSportsList) {
      config[sport.name] = {
        'pricePerHour': sport.price ?? 1000.0,
        'formats': sport.selectedFormats.toList(),
      };
    }
    return config;
  }

  double get minPricePerHour {
    if (selectedSportsList.isEmpty) return 1000.0;
    double min = double.infinity;
    for (final sport in selectedSportsList) {
      final p = sport.price;
      if (p != null && p > 0 && p < min) {
        min = p;
      }
    }
    return min == double.infinity ? 1000.0 : min;
  }

  void toggleSport(int index) {
    if (index >= 0 && index < _sports.length) {
      _sports[index].isSelected = !_sports[index].isSelected;
      notifyListeners();
    }
  }

  void toggleSportByName(String name) {
    final idx = _sports.indexWhere(
        (s) => s.name.toLowerCase() == name.trim().toLowerCase());
    if (idx != null && idx != -1) {
      _sports[idx].isSelected = !_sports[idx].isSelected;
      notifyListeners();
    }
  }

  void toggleFormatForSport(String sportName, String format) {
    final sport = _sports.firstWhere(
      (s) => s.name.toLowerCase() == sportName.trim().toLowerCase(),
      orElse: () => _sports.first,
    );

    if (sport.selectedFormats.contains(format)) {
      if (sport.selectedFormats.length > 1) {
        sport.selectedFormats.remove(format);
      }
    } else {
      sport.selectedFormats.add(format);
    }
    notifyListeners();
  }

  void addCustomFormatForSport(String sportName, String newFormat) {
    final trimmed = newFormat.trim();
    if (trimmed.isEmpty) return;

    final sport = _sports.firstWhere(
      (s) => s.name.toLowerCase() == sportName.trim().toLowerCase(),
      orElse: () => _sports.first,
    );

    if (!sport.availableFormats.contains(trimmed)) {
      sport.availableFormats.add(trimmed);
    }
    sport.selectedFormats.add(trimmed);
    notifyListeners();
  }

  void addCustomSport(String customSportName, {String defaultPrice = '300'}) {
    final trimmed = customSportName.trim();
    if (trimmed.isEmpty) return;

    // Check if sport already exists
    final existingIdx = _sports.indexWhere(
        (s) => s.name.toLowerCase() == trimmed.toLowerCase());

    if (existingIdx != -1) {
      _sports[existingIdx].isSelected = true;
      notifyListeners();
      return;
    }

    // Capitalize first letter of each word
    final formattedName = trimmed
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');

    IconData customIcon = Icons.sports;
    final lower = formattedName.toLowerCase();
    if (lower.contains('carrom') ||
        lower.contains('board') ||
        lower.contains('chess')) {
      customIcon = Icons.sports_esports_outlined;
    } else if (lower.contains('pool') ||
        lower.contains('snooker') ||
        lower.contains('billiard')) {
      customIcon = Icons.sports_baseball_outlined;
    } else if (lower.contains('table') || lower.contains('ping')) {
      customIcon = Icons.sports_tennis;
    } else if (lower.contains('swim')) {
      customIcon = Icons.pool;
    }

    final newSport = SportSetting(
      name: formattedName,
      icon: customIcon,
      isCustom: true,
      isSelected: true,
      initialPrice: defaultPrice,
      availableFormats: ["Singles (1v1)", "Doubles (2v2)", "Casual Play"],
      selectedFormats: {"Singles (1v1)", "Doubles (2v2)"},
    );

    _sports.add(newSport);
    notifyListeners();
  }

  void removeCustomSport(String sportName) {
    final idx = _sports.indexWhere((s) =>
        s.isCustom && s.name.toLowerCase() == sportName.trim().toLowerCase());
    if (idx != -1) {
      _sports[idx].dispose();
      _sports.removeAt(idx);
      notifyListeners();
    }
  }

  void toggleFacilities(int index) {
    if (index >= 0 && index < facilities.length) {
      facilities[index].selected = !facilities[index].selected;
      notifyListeners();
    }
  }

  void resetAll() {
    for (final s in _sports) {
      if (s.isCustom) {
        s.dispose();
      }
    }
    _initDefaultSports();

    for (var f in facilities) {
      f.selected = [
        "Parking",
        "Changing Room",
        "Washroom",
        "Floodlights",
        "Drinking Water",
      ].contains(f.name);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _sports) {
      s.dispose();
    }
    super.dispose();
  }
}
