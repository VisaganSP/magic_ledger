import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<File?> captureReceipt() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('Error capturing receipt: $e');
      return null;
    }
  }

  Future<File?> pickReceiptFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking receipt: $e');
      return null;
    }
  }

  Future<String?> saveReceiptImage(File imageFile, String expenseId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${directory.path}/receipts');

      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final fileName =
          'receipt_${expenseId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${receiptsDir.path}/$fileName');

      return savedImage.path;
    } catch (e) {
      print('Error saving receipt: $e');
      return null;
    }
  }

  Future<bool> deleteReceiptImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting receipt: $e');
      return false;
    }
  }

  Future<void> cleanupOrphanedReceipts(List<String> validPaths) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${directory.path}/receipts');

      if (await receiptsDir.exists()) {
        final files = receiptsDir.listSync();
        for (final file in files) {
          if (file is File && !validPaths.contains(file.path)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Error cleaning up receipts: $e');
    }
  }
}
