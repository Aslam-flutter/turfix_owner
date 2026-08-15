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
}
