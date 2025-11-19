import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:volga_it_hm_2025/widgets/back.dart';
import 'package:volga_it_hm_2025/widgets/menu.dart';

class ViewImage extends StatefulWidget {
  const ViewImage(
      {super.key,
      required this.bytes,
      required this.lat,
      required this.lng,
      required this.path});

  final Uint8List bytes;
  final double lat;
  final double lng;
  final String path;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  late Orientation? _orientation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orientation = MediaQuery.orientationOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
                minScale: 0.1,
                maxScale: 4.0,
                child: Image.memory(
                  widget.bytes,
                  width: double.infinity,
                  fit: (_orientation == Orientation.portrait)
                      ? BoxFit.fitWidth
                      : BoxFit.contain,
                )),
          ),
          Positioned(top: 10, left: 10, child: Back()),
          Positioned(
              right: 10,
              top: 10,
              child: Menu(
                lat: widget.lat,
                lng: widget.lng,
                path: widget.path,
                lastDelete: () {
                  Navigator.pop(context);
                },
                isMap: true,
              ))
        ],
      ),
    );
  }
}
