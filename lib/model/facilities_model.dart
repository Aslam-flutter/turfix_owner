import 'package:flutter/material.dart';

class FacilitiesModel {
  final String name;
  final IconData icon;
  bool selected;

  FacilitiesModel({
    required this.name,
    required this.icon,
    this.selected = false,
  });
}
