import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'providers.dart';

/// A picked photo: its bytes and a file name.
typedef PickedPhoto = ({Uint8List bytes, String name});

enum PhotoSource { camera, gallery }

/// Picks a photo, shrunk on the phone first (~1600 px, JPEG 80): a sharp
/// prescription in a few hundred KB. Tests swap it.
final photoPickerProvider = Provider<Future<PickedPhoto?> Function(PhotoSource)>(
  (ref) => (source) async {
    final file = await ImagePicker().pickImage(
      source: source == PhotoSource.camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (file == null) return null;
    return (bytes: await file.readAsBytes(), name: file.name);
  },
);

/// A photo the patient sent, kept in memory while the app runs.
final photoProvider = FutureProvider.family<Uint8List, String>(
  (ref, id) => ref.read(apiProvider).photo(id),
);
