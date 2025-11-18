import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:volga_it_hm_2025/images_gallery.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
  final TextEditingController _textEditingController = TextEditingController();
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
              MarkerClusterLayerWidget(options: MarkerClusterLayerOptions(
                markers: markers,
                size: Size(40, 40),
                maxClusterRadius: 35,
                builder: (context, markers){
                return GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 175, 170, 170),
                      borderRadius: BorderRadius.circular(50)
                    ),
                    child: Center(child: Text(markers.length.toString(),)),
                  ),
                  onTap: (){
                    List<Widget> imagesMemory = [];
                    for (var marker in markers){
                      final gestureDetector = marker.child as GestureDetector;
                      final clipRRect = gestureDetector.child as ClipRRect;
                      final imageMemory = clipRRect.child as Image;
                      imagesMemory.add(GestureDetector(
                                                onTap: gestureDetector.onTap,
                        child: SizedBox(
                          height: (MediaQuery.of(context).size.width - 35) /
                                          4,
                          width: (MediaQuery.of(context).size.width - 35) /
                                          4,
                          child: ClipRRect(borderRadius: BorderRadius.circular(10), child: imageMemory),
                        ),
                      ));
                    }
                    showModalBottomSheet(context: context, builder: (context) {
                      return DraggableScrollableSheet(
                          initialChildSize: 0.95, 
                        builder: (context, scrollController) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            crossAxisCount: 4), itemCount: imagesMemory.length, itemBuilder: (context, i) {
                              return imagesMemory[i];
                            },),
                        );
                      },);
                    },);
                  },
                );
              }))
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 15,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                // margin: EdgeInsets.symmetric(horizontal: 10),
                width: 350,
                child: TextField(
                  controller: _textEditingController,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 175, 170, 170),),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color.fromARGB(255, 175, 170, 170)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color.fromARGB(255, 175, 170, 170)),
                    )
                  ),
                  onEditingComplete: () async {
                    try {
                      Uri url = Uri.parse('https://geocode-maps.yandex.ru/v1/?apikey=22613088-b9ee-491a-8ef2-e8710df62f0f&geocode=${_textEditingController.text}&format=json');
                      var res = await http.get(url);
                      String coor = jsonDecode(res.body)['response']['GeoObjectCollection']['featureMember'][0]['GeoObject']['Point']['pos'];
                      double longitude = double.parse(coor.split(' ')[0]);
                      double latitude = double.parse(coor.split(' ')[1]);
                      _mapController.move(LatLng(latitude, longitude), _currentZoom);
                    } catch (e){
                      showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text('Ошибка'),
                content: Text('Неверный аддресс'),
                actions: [
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Color.fromRGBO(190, 25, 25, 1),
                      ),
                      child: Text('ок')),
                ],
              );
            });
                    }
                    // ignore: use_build_context_synchronously
                    setState(() {
                      _textEditingController.text = '';
                    });
                    FocusScope.of(context).unfocus();
                  },
                )
                ),
            ),
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
