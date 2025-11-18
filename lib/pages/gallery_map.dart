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
  final MapController _mapController = MapController();
  late double _currentZoom;

  void zoomIn(){
    setState(() {
      _currentZoom += 1;
      // ignore: deprecated_member_use
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

    void zoomOut(){
    setState(() {
      _currentZoom -= 1;
      // ignore: deprecated_member_use
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentZoom = widget.initialZoom;
    _mapController.mapEventStream.listen((event) {
      // ignore: deprecated_member_use
      _currentZoom = _mapController.zoom;
    },);
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];
    final ImagesGallery imagesGallery = context.watch<ImagesGallery>();
    for (final image in imagesGallery.images) {
      if (image['gps'] != null) {
        markers.add(Marker(
            point: LatLng(image['gps']['lat'], image['gps']['lng']),
            width: 40,
            height: 40,
            child: GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.memory(
                  image['bytes'],
                  fit: BoxFit.cover,
                ),
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.lat, widget.lng),
              initialZoom: _currentZoom,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: markers)
            ],
          ),
          Positioned(
            right: 10,
            bottom: 0,
            top: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: zoomIn,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Center(
                    child: Icon(Icons.add, size: 40,),
                  ),
                ),
              ),
              GestureDetector(
                onTap: zoomOut,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Center(
                    child: Icon(Icons.remove, size: 40,),
                  ),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
