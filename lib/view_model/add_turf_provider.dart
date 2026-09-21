import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turfix_owner/core/services/cloudinary_services.dart';

class AddTurfProvider extends ChangeNotifier {
  String openigTime = 'Select opening time';
  String closingTime = 'Select closing time';

  final ImagePicker _imagePicker = ImagePicker();

  // Selected images for showing preview in UI
  final List<XFile?> selectedImages = List.filled(3, null);

  // Cloudinary URLs
  final List<String?> imageUrls = List.filled(3, null);

  // --------------------------------------------------
  // IMAGE PICK + UPLOAD
  // --------------------------------------------------

  Future<void> pickAndUploadImage(int index) async {
    if (index < 0 || index >= 3) return;

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) return;

      // Show selected image immediately
      selectedImages[index] = pickedImage;
      notifyListeners();

      // Upload to Cloudinary
      final url = await CloudinaryService.uploadImage(pickedImage);

      if (url != null) {
        imageUrls[index] = url;

        log('Image ${index + 1} uploaded: $url');
      } else {
        log('Image ${index + 1} upload failed');
      }

      notifyListeners();
    } catch (e) {
      log('Image upload error: $e');
    }
  }

  // --------------------------------------------------
  // CHECK 3 IMAGES
  // --------------------------------------------------

  bool get hasThreeImages {
    return imageUrls.every((url) => url != null && url.isNotEmpty);
  }

  // --------------------------------------------------
  // GET ONLY VALID URLS
  // --------------------------------------------------

  List<String> get uploadedImageUrls {
    return imageUrls
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
  }

  // --------------------------------------------------
  // REMOVE IMAGE
  // --------------------------------------------------

  void removeImage(int index) {
    if (index < 0 || index >= 3) return;

    selectedImages[index] = null;
    imageUrls[index] = null;

    notifyListeners();
  }

  // --------------------------------------------------
  // OPENING TIME
  // --------------------------------------------------

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

  // --------------------------------------------------
  // CLOSING TIME
  // --------------------------------------------------

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

  // --------------------------------------------------
  // PARSE TIME
  // --------------------------------------------------

  TimeOfDay parseTime(String time) {
    final parts = time.trim().split(' ');

    final timePart = parts[0];
    final period = parts[1].toUpperCase();

    final timeParts = timePart.split(':');

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  // --------------------------------------------------
  // CREATE TURF SLOTS
  // --------------------------------------------------

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

      final dateId =
          '${currentDate.year}-'
          '${currentDate.month.toString().padLeft(2, '0')}-'
          '${currentDate.day.toString().padLeft(2, '0')}';

      final dateRef = firestore
          .collection('turfs')
          .doc(turfId)
          .collection('slots')
          .doc(dateId);

      batch.set(dateRef, {
        'date': Timestamp.fromDate(currentDate),
      }, SetOptions(merge: true));

      batchCount++;

      if (batchCount == 500) {
        await batch.commit();

        batch = firestore.batch();
        batchCount = 0;
      }

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

        if (end.isAfter(closingDateTime)) {
          break;
        }

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

        if (batchCount == 500) {
          await batch.commit();

          batch = firestore.batch();
          batchCount = 0;
        }

        start = end;
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }
  }
}
