import 'package:flutter/material.dart';
import 'package:turfix_owner/model/date_booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final List<BookingDateModel> dates = [];
  int selectedIndex = -1;

  BookingProvider() {
    generateDates();
  }

  void generateDates() {
    final now = DateTime.now();

    for (int i = 0; i < 15; i++) {
      dates.add(
        BookingDateModel(
          date: now.add(Duration(days: i)),
          selected: i == 0,
        ),
      );
    }
  }

  void selectDate(int index) {
    for (final item in dates) {
      item.selected = false;
    }

    dates[index].selected = true;

    notifyListeners();
  }

  void selectSlot(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  bool isSelected(int index) {
    return selectedIndex == index;
  }
}
