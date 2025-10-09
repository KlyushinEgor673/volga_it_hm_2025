import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volga_it_hm_2025/images_gallery.dart';
import 'package:volga_it_hm_2025/pages/gallery.dart';
import 'package:volga_it_hm_2025/pages/gallery_map.dart';
import 'package:volga_it_hm_2025/pages/view_image.dart';
import 'package:volga_it_hm_2025/pages/view_images.dart';

Future<void> main() async {
  ImagesGallery imagesGallery = ImagesGallery();
  await imagesGallery.initImages();
  await imagesGallery.startListen();
  runApp(
    ChangeNotifierProvider(
      create: (context) => imagesGallery,
      child: MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return PageRouteBuilder(pageBuilder: (_, __, ___) => Gallery());
          } else if (settings.name == '/map') {
            final args = settings.arguments as Map;
            return PageRouteBuilder(
                pageBuilder: (_, __, ___) => GalleryMap(
                      initialZoom: args['initialZoom'],
                      lat: args['lat'],
                      lng: args['lng'],
                    ));
          } else if (settings.name == '/images') {
            final args = settings.arguments as Map;
            return PageRouteBuilder(
                pageBuilder: (_, __, ___) => ViewImages(i: args['i']));
          } else if (settings.name == '/image') {
            final args = settings.arguments as Map;
            return PageRouteBuilder(
                pageBuilder: (_, __, ___) => ViewImage(
                      bytes: args['bytes'],
                      lat: args['lat'],
                      lng: args['lng'],
                      path: args['path'],
                    ));
          }
          return null;
        },
      ),
    ),
  );
}
