import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';

class CloudinaryService {
  static const String _cloudName = 'dkx1ijiz9';
  static const String _apiKey = '477726265167911';
  static const String _uploadPreset =
      'guardian_eye'; // Create this in Cloudinary settings

  static Future<List<String>> uploadImages(List<File> images) async {
    final List<String> imageUrls = [];

    for (final image in images) {
      try {
        final url = await _uploadImage(image);
        imageUrls.add(url);
      } catch (e) {
        print('Error uploading image: $e');
        rethrow;
      }
    }

    return imageUrls;
  }

  static Future<String> _uploadImage(File image) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    // Get mime type
    final mimeType = lookupMimeType(image.path);
    final fileType = mimeType?.split('/')[1] ?? 'jpg';

    // Create multipart request
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['api_key'] = _apiKey
      ..files.add(await http.MultipartFile.fromBytes(
        'file',
        await image.readAsBytes(),
        filename: '${DateTime.now().millisecondsSinceEpoch}.$fileType',
      ));

    // Send request
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to upload image: ${jsonResponse['error']['message']}');
    }

    return jsonResponse['secure_url'];
  }
}
