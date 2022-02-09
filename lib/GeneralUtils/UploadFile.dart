import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:totem_app/GeneralUtils/LabelStr.dart';

class UploadFile {
  bool success;
  String message;

  bool isUploaded;

  Future<void> call(String url, File image) async {
    try {
      Uint8List bytes = await image.readAsBytes();
      var response = await http.put(Uri.parse(url), body: bytes);
      if (response.statusCode == 200) {
        isUploaded = true;
      }
    } catch (e) {
      throw (Messages.CErrorUploadingPhoto);
    }
  }
}