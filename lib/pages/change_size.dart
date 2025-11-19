import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:volga_it_hm_2025/widgets/back.dart';

class ChangeSize extends StatefulWidget {
  const ChangeSize({super.key, required this.path});
  final String path;

  @override
  State<ChangeSize> createState() => _ChangeSizeState();
}

class _ChangeSizeState extends State<ChangeSize> {
  // ignore: prefer_typing_uninitialized_variables
  late var bytes;
  final _controller = CropController();

  @override
  void initState() {
    super.initState();
    final file = File(widget.path);

    bytes = file.readAsBytesSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Crop(
                baseColor: Colors.black,
                controller: _controller,
                image: bytes,
                onCropped: (result) async {
                  switch (result) {
                    case CropSuccess(:final croppedImage):
                      var croppedData = croppedImage;
                      File file = File(widget.path);
                      File originalFile = File(widget.path);
                      // var metadata =
                      // await MetadataGod.readMetadata(file: widget.path);

                      DateTime lastModified = await originalFile.lastModified();
                      DateTime lastAccessed = await originalFile.lastAccessed();
                      var bytes = await File(widget.path).readAsBytes();
                      // img.Image? image = img.decodeImage(bytes);
                      final metadata = await readExifFromBytes(bytes);
                      if (metadata.isNotEmpty) {
                        IfdTag? latTag;
                        IfdTag? lngTag;
                        for (final entry in metadata.entries) {
                          if (entry.key == 'GPS GPSLatitude') {
                            latTag = entry.value;
                          } else if (entry.key == 'GPS GPSLongitude') {
                            lngTag = entry.value;
                          }
                        }
                        if (latTag != null && lngTag != null) {}
                      }

                      await showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.white,
                            surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Сохранить обрезанное изображение',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Выберите способ сохранения:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),

                                  // Кнопка нового файла
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final originalFile = File(widget.path);
                                        final path = originalFile.path;
                                        final timestamp = DateTime.now()
                                            .millisecondsSinceEpoch;
                                        final newPath = path.replaceAllMapped(
                                          RegExp(r'(\.[^./\\]+)$'),
                                          (match) =>
                                              '_new_$timestamp${match.group(1)}',
                                        );
                                        final newFile = File(newPath == path
                                            ? '${path}_new_$timestamp'
                                            : newPath);

                                        await newFile.writeAsBytes(croppedData);
                                        await newFile
                                            .setLastModified(lastModified);
                                        await newFile
                                            .setLastAccessed(lastAccessed);

                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue[600],
                                        side: BorderSide(
                                          color: Colors.blue[600]!,
                                          width: 1.5,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        alignment: Alignment.centerLeft,
                                      ),
                                      icon: const Icon(
                                          Icons.add_photo_alternate_rounded,
                                          size: 22),
                                      label: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Создать новый файл',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Безопасно, сохранит оригинал',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Кнопка замены оригинала
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await file.writeAsBytes(croppedData);
                                        await file
                                            .setLastModified(lastModified);
                                        await file
                                            .setLastAccessed(lastAccessed);

                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[600],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        alignment: Alignment.centerLeft,
                                        elevation: 0,
                                      ),
                                      icon: const Icon(Icons.edit_rounded,
                                          size: 22),
                                      label: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Заменить оригинал',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Обновит текущий файл',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  // ignore: deprecated_member_use
                                                  Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    case CropFailure(:final cause):
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text('Failed to crop image: $cause'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK')),
                          ],
                        ),
                      );
                  }
                },
              ),
            ),
            const Positioned(top: 10, left: 10, child: Back()),
            Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                    child: const Icon(Icons.crop),
                  ),
                  onTap: () {
                    _controller.crop();
                  },
                )),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   print('AAAAAAAAAAA');
      //   _controller.crop();
      // }),
    );
  }
}
