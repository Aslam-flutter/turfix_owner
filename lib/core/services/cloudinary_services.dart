import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'is37jtrz';
  static const String uploadPreset = 'turfix_images';

  static Future<String?> uploadImage(XFile image) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/'
        '$cloudName/image/upload',
      );

      final imageBytes = await image.readAsBytes();

      final request = http.MultipartRequest('POST', url);

      request.fields['upload_preset'] = uploadPreset;

      request.files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: image.name),
      );

      log('Uploading image: ${image.name}');

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      log('Cloudinary status: ${response.statusCode}');
      log('Cloudinary response: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        final secureUrl = data['secure_url'];

        log('Cloudinary URL: $secureUrl');

        return secureUrl;
      }

      log('Cloudinary upload failed');

      return null;
    } catch (e, stackTrace) {
      log('Cloudinary exception: $e', stackTrace: stackTrace);

      return null;
    }
  }
}
