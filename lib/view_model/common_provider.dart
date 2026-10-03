import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommonProvider extends ChangeNotifier {
  bool isLoading = false;
  String bookDate = DateFormat('d MMMM yyyy').format(DateTime.now());
  bool imageErrored = false;
  bool isObscure = true;
  bool isExpanded = false;

  void pickBookDate(BuildContext context) async {
    final picker = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picker != null) {
      bookDate = DateFormat('d MMMM yyyy').format(picker);
      notifyListeners();
    }
  }

  void load(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void imageError(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void obscurePassword() {
    isObscure = !isObscure;
    notifyListeners();
  }

  void isExpand() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  String getDisplayStatus(Map<String, dynamic> booking) {
    // Cancellation is stored permanently in Firebase
    if (booking['status']?.toString().toLowerCase() == 'cancelled') {
      return 'Cancelled';
    }

    final startAt = booking['startAt'];

    final endAt = booking['endAt'];

    if (startAt is! Timestamp || endAt is! Timestamp) {
      return 'Confirmed';
    }

    final now = DateTime.now();

    final startTime = startAt.toDate();
    final endTime = endAt.toDate();

    if (now.isBefore(startTime)) {
      return 'Confirmed';
    }

    if (now.isBefore(endTime)) {
      return 'Playing';
    }

    return 'Completed';
  }

  // Future<double> getOwnerTotalAmount(String ownerId) async {
  //   try {
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('bookings')
  //         .where('turfOwnerId', isEqualTo: ownerId)
  //         .get();

  //     double totalAmount = 0;

  //     for (final doc in snapshot.docs) {
  //       final data = doc.data();

  //       final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

  //       totalAmount += amount;
  //     }

  //     if (totalAmount == 0) {
  //       return 0.00;
  //     }

  //     return totalAmount;
  //   } catch (e) {
  //     debugPrint('Error getting owner total: $e');
  //     return 0.0;
  //   }
  // }
}
