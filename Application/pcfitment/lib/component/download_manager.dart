import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pcfitment/widgets/snackbar.dart';
import 'package:http/http.dart' as http;

class DownloadManager {
  Future<void> downloadFile(
      BuildContext context, String fileUrl, String fileName) async {
    final url = Uri.parse(fileUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final directory = await getExternalStorageDirectory();
      final filePath = join(directory!.path, fileName);

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      if (context.mounted) snackBarErrorMsg(context, 'File downloaded to $filePath');

      /*await Permission.storage.request();
      if (await Permission.storage.isGranted) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        snackBarErrorMsg(context, 'File downloaded to $filePath');
      } else {
        snackBarErrorMsg(context, 'Permission denied');
      }*/
    } else {
      if (context.mounted) snackBarErrorMsg(context, 'Failed to download file');
    }
  }
}
