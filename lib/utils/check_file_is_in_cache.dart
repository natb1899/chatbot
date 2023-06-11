import 'dart:io';

Future<bool> isFileInCache(String filePath) async {
  final file = File(filePath);
  return file.exists();
}
