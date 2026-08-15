import 'package:flutter/material.dart';

class SportModel {
  final String name;
  final IconData icon;
  bool selected;

  SportModel({required this.name, required this.icon, this.selected = false});
}
