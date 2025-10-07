import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:volga_it_hm_2025/images_gallery.dart';
import 'package:provider/provider.dart';

class GalleryMap extends StatefulWidget {
  const GalleryMap(
      {super.key,
      required this.initialZoom,
      required this.lat,
      required this.lng});

  final double initialZoom;
  final double lat;
  final double lng;

  @override
  State<GalleryMap> createState() => _GalleryMapState();
}

class _GalleryMapState extends State<GalleryMap> {

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   _init();
  // }

  @override
  Widget build(BuildContext context) {
    List<Marker> _markers = [];
    final imagesGallery = context.watch<ImagesGallery>();
    for (final image in imagesGallery.images) {
      if (image['gps'] != null) {
        _markers.add(Marker(
            point: LatLng(image['gps']['lat'], image['gps']['lng']),
            width: 40,
            height: 40,
            child: GestureDetector(
              child: ClipRRect(
                child: Image.memory(
                  image['bytes'],
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/image', arguments: {
                  'bytes': image['bytes'],
                  'lat': image['gps']['lat'],
                  'lng': image['gps']['lng'],
                  'path': image['path']
                });
              },
            )));
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
        title: Text('Карта'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(widget.lat, widget.lng),
          initialZoom: widget.initialZoom,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
            // https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(markers: _markers)
        ],
      ),
    );
  }
}
