import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:metadata_god/metadata_god.dart';

class ChangeSize extends StatefulWidget {
  const ChangeSize({super.key, required this.path});
  final String path;

  @override
  State<ChangeSize> createState() => _ChangeSizeState();
}

class _ChangeSizeState extends State<ChangeSize> {
  late var bytes;
  final _controller = CropController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final file = File(widget.path);

    bytes = file.readAsBytesSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Crop(
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

                await file.writeAsBytes(croppedData);
                // await MetadataGod.writeMetadata(
                //     file: widget.path, metadata: metadata);
                await file.setLastModified(lastModified);
                await file.setLastAccessed(lastAccessed);

                Navigator.pop(context);
              case CropFailure(:final cause):
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text('Failed to crop image: ${cause}'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK')),
                    ],
                  ),
                );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        print('AAAAAAAAAAA');
        _controller.crop();
      }),
    );
  }
}
