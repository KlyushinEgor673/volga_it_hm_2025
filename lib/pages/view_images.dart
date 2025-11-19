import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:volga_it_hm_2025/images_gallery.dart';
import 'package:volga_it_hm_2025/widgets/back.dart';
import 'package:volga_it_hm_2025/widgets/menu.dart';

class ViewImages extends StatefulWidget {
  const ViewImages({super.key, required this.i});

  final int i;

  @override
  State<ViewImages> createState() => _ViewImagesState();
}

class _ViewImagesState extends State<ViewImages> {
  late PageController _controller;
  late Orientation? _orientation;

  @override
  void initState() {
    super.initState();
    setState(() {
      _controller = PageController(initialPage: widget.i);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orientation = MediaQuery.orientationOf(context);
  }

  @override
  Widget build(BuildContext context) {
    ImagesGallery imagesGallery = context.watch<ImagesGallery>();
    return SafeArea(
      child: PageView.builder(
          controller: _controller,
          itemCount: imagesGallery.images.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                      minScale: 0.1,
                      maxScale: 4.0,
                      child: Image.memory(
                        width: double.infinity,
                        imagesGallery.images[index]['bytes'],
                        fit: _orientation == Orientation.portrait
                            ? BoxFit.fitWidth
                            : BoxFit.contain,
                      )),
                ),
                const Positioned(top: 10, left: 10, child: Back()),
                Positioned(
                    right: 10,
                    top: 10,
                    child: (imagesGallery.images[index]['gps'] != null)
                        ? Menu(
                            lat: imagesGallery.images[index]['gps']['lat'],
                            lng: imagesGallery.images[index]['gps']['lng'],
                            path: imagesGallery.images[index]['path'],
                            lastDelete: () {
                              if (_controller.page ==
                                  imagesGallery.images.length) {
                                _controller
                                    .jumpToPage(_controller.page!.round() - 1);
                              }
                            },
                            isMap: true,
                          )
                        : Menu(
                            path: imagesGallery.images[index]['path'],
                            lastDelete: () {
                              if (_controller.page ==
                                  imagesGallery.images.length) {
                                _controller
                                    .jumpToPage(_controller.page!.round() - 1);
                              }
                            },
                            isMap: false)),
                if (imagesGallery.images[index]['gps'] == null)
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        color: Colors.grey.withAlpha(200),
                        child: const Center(
                          child: Text(
                            'У фотографии нет метаданных с местоположением',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.none),
                          ),
                        ),
                      ))
              ],
            );
          }),
    );
  }
}
