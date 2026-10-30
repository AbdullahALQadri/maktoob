import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';

/// A picked file for tests: `PlatformFile` is abstract since file_picker 13.
final class FakePlatformFile extends PlatformFile {
  FakePlatformFile({required this.name, this.size = 0, String? path})
      : uri = path == null ? Uri.parse('blob:$name') : Uri.file(path);

  @override
  final String name;
  final int size;
  @override
  final Uri uri;

  @override
  XFile get xFile => XFile(uri.toString(), name: name, length: size);
  @override
  int? lengthSync() => size;
  @override
  Future<int?> length() async => size;
  @override
  Future<Uint8List> readAsBytes() async => Uint8List(size);
  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(Uint8List(size));
}
