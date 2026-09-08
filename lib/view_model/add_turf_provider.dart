import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddTurfProvider extends ChangeNotifier {
  String openigTime = 'Select opening time';
  String closingTime = 'Select closing time';
  List<String> imageUrls = [];

  Future<void> selectOpeningTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      openigTime = pickedTime.format(context);
      notifyListeners();
    }
  }

  Future<void> selectClosingTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      closingTime = pickedTime.format(context);
      notifyListeners();
    }
  }

  Future<void> pickAndUploadImages() async {
    // if (turfImages.length >= 3) {
    //   log('You can select only 3 images');
    //   return;
    // }

    final List<XFile> images = await ImagePicker().pickMultiImage(
      imageQuality: 80,
    );

    if (images.isEmpty) return;

    // for (final image in images) {
    //   final fileName = '${DateTime.now().microsecondsSinceEpoch}_${image.name}';

    //   final ref = FirebaseStorage.instance.ref().child('turfs').child(fileName);

    //   await ref.putData(await image.readAsBytes());

    //   final url = await ref.getDownloadURL();

    //   imageUrls.add(url);
    // }
    // log(imageUrls.toString());
  }

  // Future<void> createTurfSlots({
  //   required String turfId,
  //   required String openingTime,
  //   required String closingTime,
  //   required double pricePerHour,
  // }) async {
  //   final firestore = FirebaseFirestore.instance;

  //   final opening = parseTime(openingTime);
  //   final closing = parseTime(closingTime);

  //   final List<Map<String, dynamic>> slots = [];

  //   final today = DateTime.now();

  //   for (int day = 0; day < 14; day++) {
  //     final currentDate = DateTime(
  //       today.year,
  //       today.month,
  //       today.day,
  //     ).add(Duration(days: day));

  //     DateTime start = DateTime(
  //       currentDate.year,
  //       currentDate.month,
  //       currentDate.day,
  //       opening.hour,
  //       opening.minute,
  //     );

  //     final DateTime closingDateTime = DateTime(
  //       currentDate.year,
  //       currentDate.month,
  //       currentDate.day,
  //       closing.hour,
  //       closing.minute,
  //     );

  //     while (start.isBefore(closingDateTime)) {
  //       final end = start.add(const Duration(hours: 1));

  //       // Don't create a slot that goes beyond closing time
  //       if (end.isAfter(closingDateTime)) {
  //         break;
  //       }

  //       slots.add({
  //         'startAt': Timestamp.fromDate(start),
  //         'endAt': Timestamp.fromDate(end),
  //         'price': pricePerHour,
  //         'status': 'available',
  //         'bookingId': null,
  //       });

  //       start = end;
  //     }
  //   }

  //   // Save slots
  //   WriteBatch batch = firestore.batch();

  //   for (final slot in slots) {
  //     final startAt = (slot['startAt'] as Timestamp).toDate();

  //     final slotId =
  //         '${startAt.year}-'
  //         '${startAt.month.toString().padLeft(2, '0')}-'
  //         '${startAt.day.toString().padLeft(2, '0')}_'
  //         '${startAt.hour.toString().padLeft(2, '0')}-'
  //         '${startAt.minute.toString().padLeft(2, '0')}';

  //     final slotRef = firestore
  //         .collection('turfs')
  //         .doc(turfId)
  //         .collection('slots')
  //         .doc(slotId);

  //     batch.set(slotRef, slot);
  //   }

  //   await batch.commit();
  // }

  Future<void> createTurfSlots({
    required String turfId,
    required String openingTime,
    required String closingTime,
    required double pricePerHour,
    int numberOfDays = 7,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final opening = parseTime(openingTime);
    final closing = parseTime(closingTime);

    final today = DateTime.now();

    WriteBatch batch = firestore.batch();
    int batchCount = 0;

    for (int day = 0; day < numberOfDays; day++) {
      final currentDate = DateTime(
        today.year,
        today.month,
        today.day,
      ).add(Duration(days: day));

      // --------------------------------------------
      // DATE DOCUMENT
      // --------------------------------------------

      final dateId =
          '${currentDate.year}-'
          '${currentDate.month.toString().padLeft(2, '0')}-'
          '${currentDate.day.toString().padLeft(2, '0')}';

      final dateRef = firestore
          .collection('turfs')
          .doc(turfId)
          .collection('slots')
          .doc(dateId);

      // Create date document
      batch.set(dateRef, {
        'date': Timestamp.fromDate(currentDate),
      }, SetOptions(merge: true));

      batchCount++;

      if (batchCount == 500) {
        await batch.commit();

        batch = firestore.batch();
        batchCount = 0;
      }

      // --------------------------------------------
      // TIME SLOTS
      // --------------------------------------------

      DateTime start = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        opening.hour,
        opening.minute,
      );

      final closingDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        closing.hour,
        closing.minute,
      );

      while (start.isBefore(closingDateTime)) {
        final end = start.add(const Duration(hours: 1));

        // Don't create slot beyond closing time
        if (end.isAfter(closingDateTime)) {
          break;
        }

        // Example: 10-00
        final timeSlotId =
            '${start.hour.toString().padLeft(2, '0')}-'
            '${start.minute.toString().padLeft(2, '0')}';

        final timeSlotRef = dateRef.collection('times').doc(timeSlotId);

        batch.set(timeSlotRef, {
          'startAt': Timestamp.fromDate(start),
          'endAt': Timestamp.fromDate(end),
          'price': pricePerHour,
          'status': 'available',
          'bookingId': null,
        }, SetOptions(merge: true));

        batchCount++;

        // Firestore batch limit
        if (batchCount == 500) {
          await batch.commit();

          batch = firestore.batch();
          batchCount = 0;
        }

        start = end;
      }
    }

    // Commit remaining writes
    if (batchCount > 0) {
      await batch.commit();
    }
  }

  /// automatic adding and removing of slots
}
