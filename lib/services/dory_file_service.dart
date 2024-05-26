import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> saveImageToLocalDirectory(File image) async {
  final documentDirectory = await getApplicationCacheDirectory();
  final forderPath = '${documentDirectory.path}/medicien/images'; // 저장될 경로
  final filePath =
      '$forderPath/${DateTime.now().millisecondsSinceEpoch}.png'; // 유니크한 파일명을 위해

  await Directory(forderPath).create(recursive: true);

  final newFile = File(filePath);
  newFile.writeAsBytesSync(image.readAsBytesSync());

  return filePath;
}

void deleteImage(String filePath) {
  File(filePath).delete(recursive: true); // 파일의 하위 파일까지 삭제할거에요
}
