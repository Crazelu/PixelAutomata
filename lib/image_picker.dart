import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:file_picker/file_picker.dart';

class ImagePicker {
  ImagePicker({ip.ImagePicker? imagePicker}) {
    this.imagePicker = imagePicker ?? ip.ImagePicker();
  }
  late ip.ImagePicker imagePicker;

  Future<File?> pickImage({bool camera = true}) async {
    if (Platform.isIOS && kDebugMode) return await _pickFromFiles();
    return await _pickImage(camera: camera);
  }

  Future<File?> _pickImage({bool camera = false}) async {
    final pickedImage = await imagePicker.pickImage(
      source: camera ? ip.ImageSource.camera : ip.ImageSource.gallery,
    );
    if (pickedImage != null) return File(pickedImage.path);
    return null;
  }

  Future<File?> _pickFromFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      return File(result!.paths.first!);
    } catch (e) {
      debugPrint("$e");
      return null;
    }
  }
}
