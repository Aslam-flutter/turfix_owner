import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turfix_owner/core/services/cloudinary_services.dart';

class AddTurfProvider extends ChangeNotifier {
  String openigTime = '06:00 AM';
  String closingTime = '11:00 PM';

  final ImagePicker _imagePicker = ImagePicker();

  // Selected images for showing preview in UI
  final List<XFile?> selectedImages = List.filled(3, null);

  // Cloudinary URLs
  final List<String?> imageUrls = List.filled(3, null);

  // Uploading state for each image
  final List<bool> isUploading = List.filled(3, false);

  // --------------------------------------------------
  // IMAGE PICK + UPLOAD
  // --------------------------------------------------

  Future<void> pickAndUploadImage(int index, {ImageSource source = ImageSource.gallery}) async {
    if (index < 0 || index >= 3) return;

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedImage == null) return;

      // Show selected local preview immediately
      selectedImages[index] = pickedImage;
      isUploading[index] = true;
      notifyListeners();

      // Upload to Cloudinary
      final url = await CloudinaryService.uploadImage(pickedImage);

      if (url != null && url.isNotEmpty) {
        imageUrls[index] = url;
        log('Image ${index + 1} uploaded successfully: $url');
      } else {
        log('Image ${index + 1} upload failed');
      }
    } catch (e) {
      log('Image upload error: $e');
    } finally {
      isUploading[index] = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------
  // CHECK 3 IMAGES
  // --------------------------------------------------

  bool get hasThreeImages {
    return imageUrls.every((url) => url != null && url.isNotEmpty);
  }

  int get uploadedCount {
    return imageUrls.where((url) => url != null && url.isNotEmpty).length;
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
    isUploading[index] = false;

    notifyListeners();
  }

  // --------------------------------------------------
  // OPENING TIME
  // --------------------------------------------------

  Future<void> selectOpeningTime(BuildContext context) async {
    final TimeOfDay initial = openigTime.contains(':')
        ? parseTime(openigTime)
        : const TimeOfDay(hour: 6, minute: 0);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initial,
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
    final TimeOfDay initial = closingTime.contains(':')
        ? parseTime(closingTime)
        : const TimeOfDay(hour: 23, minute: 0);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initial,
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
    try {
      final parts = time.trim().split(' ');
      final timePart = parts[0];
      final period = parts.length > 1 ? parts[1].toUpperCase() : 'AM';

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
    } catch (_) {
      return const TimeOfDay(hour: 6, minute: 0);
    }
  }

  bool isClosingAfterOpening() {
    final opening = parseTime(openigTime);
    final closing = parseTime(closingTime);

    final openMinutes = opening.hour * 60 + opening.minute;
    final closeMinutes = closing.hour * 60 + closing.minute;

    return closeMinutes > openMinutes;
  }

  int getEstimatedDailySlots() {
    final opening = parseTime(openigTime);
    final closing = parseTime(closingTime);

    final openMinutes = opening.hour * 60 + opening.minute;
    final closeMinutes = closing.hour * 60 + closing.minute;

    if (closeMinutes <= openMinutes) return 0;
    return ((closeMinutes - openMinutes) / 60).floor();
  }

  void resetMedia() {
    for (int i = 0; i < 3; i++) {
      selectedImages[i] = null;
      imageUrls[i] = null;
      isUploading[i] = false;
    }
    openigTime = '06:00 AM';
    closingTime = '11:00 PM';
    notifyListeners();
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
