import 'dart:async';
import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';

class ImagesGallery extends ChangeNotifier {
  List images = [];
  Timer? _debounceTimer;

  Future<void> initImages() async {
    images = [];
    Directory directory = Directory('Pictures');
    for (var file in directory.listSync()) {
      if (file is File) {
        var bytes = await file.readAsBytes();
        final data = await readExifFromBytes(bytes);
        if (data.isEmpty) {
          images.add({
            'bytes': bytes,
            'gps': null,
            'date': file.lastModifiedSync(),
            'path': file.path
          });
        } else {
          IfdTag? latTag;
          IfdTag? lngTag;
          for (final entry in data.entries) {
            if (entry.key == 'GPS GPSLatitude') {
              latTag = entry.value;
            } else if (entry.key == 'GPS GPSLongitude') {
              lngTag = entry.value;
            }
          }
          if (latTag != null && lngTag != null) {
            double lat = latTag.values.toList()[0].toDouble() +
                (latTag.values.toList()[1].toDouble() / 60) +
                (latTag.values.toList()[2].toDouble() / 3600);
            double lng = lngTag.values.toList()[0].toDouble() +
                (lngTag.values.toList()[1].toDouble() / 60) +
                (lngTag.values.toList()[2].toDouble() / 3600);
            images.add({
              'bytes': bytes,
              'gps': {'lat': lat, 'lng': lng},
              'date': file.lastModifiedSync(),
              'path': file.path
            });
          } else {
            images.add({
              'bytes': bytes,
              'gps': null,
              'date': file.lastModifiedSync(),
              'path': file.path
            });
          }
          for (int i = 0; i < images.length; ++i) {
            for (int j = 0; j < images.length - i - 1; ++j) {
              if (images[j]['date'].isBefore(images[j + 1]['date'])) {
                var t = images[j];
                images[j] = images[j + 1];
                images[j + 1] = t;
              }
            }
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> startListen() async {
    Directory directory = Directory('Pictures');
    directory.watch().listen(
      (event) async {
        _debounceTimer?.cancel();
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
          initImages();
        });
      },
    );
  }
}
