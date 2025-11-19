import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:volga_it_hm_2025/images_gallery.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class GalleryMap extends StatefulWidget {
  const GalleryMap({
    super.key,
    required this.initialZoom,
    required this.lat,
    required this.lng,
  });

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

  void zoomIn() {
    setState(() {
      _currentZoom += 1;
      // ignore: deprecated_member_use
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void zoomOut() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];
    final ImagesGallery imagesGallery = context.watch<ImagesGallery>();
    for (final image in imagesGallery.images) {
      if (image['gps'] != null) {
        markers.add(Marker(
          point: LatLng(image['gps']['lat'], image['gps']['lng']),
          width: 50,
          height: 50,
          child: GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: Image.memory(
                  image['bytes'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/image', arguments: {
                'bytes': image['bytes'],
                'lat': image['gps']['lat'],
                'lng': image['gps']['lng'],
                'path': image['path'],
              });
            },
          ),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
        ),
        title: const Text(
          'Карта фотографий',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
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
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  markers: markers,
                  size: const Size(50, 50),
                  maxClusterRadius: 40,
                  builder: (context, markers) {
                    return GestureDetector(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        List<Widget> imagesMemory = [];
                        for (var marker in markers) {
                          final gestureDetector =
                              marker.child as GestureDetector;
                          final container = gestureDetector.child as Container;
                          final clipRRect = container.child as ClipRRect;
                          final imageMemory = clipRRect.child as Image;

                          imagesMemory.add(
                            GestureDetector(
                              onTap: gestureDetector.onTap,
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: imageMemory,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.85,
                              minChildSize: 0.5,
                              maxChildSize: 0.95,
                              builder: (context, scrollController) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, -2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Хендл для перетаскивания
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          '${markers.length} фотографий в этой области',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: GridView.builder(
                                            controller: scrollController,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              mainAxisSpacing: 8,
                                              crossAxisSpacing: 8,
                                              crossAxisCount: 4,
                                              childAspectRatio: 1,
                                            ),
                                            itemCount: imagesMemory.length,
                                            itemBuilder: (context, i) {
                                              return imagesMemory[i];
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Поисковая строка
          Positioned(
            left: 0,
            right: 0,
            top: 16,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textEditingController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                    hintText: 'Поиск места...',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onEditingComplete: () async {
                    if (_textEditingController.text.trim().isEmpty) return;

                    try {
                      Uri url = Uri.parse(
                        'https://geocode-maps.yandex.ru/v1/?apikey=22613088-b9ee-491a-8ef2-e8710df62f0f&geocode=${_textEditingController.text}&format=json',
                      );
                      var res = await http.get(url);
                      String coor = jsonDecode(res.body)['response']
                              ['GeoObjectCollection']['featureMember'][0]
                          ['GeoObject']['Point']['pos'];
                      double longitude = double.parse(coor.split(' ')[0]);
                      double latitude = double.parse(coor.split(' ')[1]);
                      _mapController.move(
                          LatLng(latitude, longitude), _currentZoom);
                    } catch (e) {
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              'Ошибка',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            content:
                                const Text('Не удалось найти указанный адрес'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue[600],
                                ),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    setState(() {
                      _textEditingController.text = '';
                    });
                    // ignore: use_build_context_synchronously
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ),
          ),

          // Контролы масштабирования
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                // Кнопка увеличения
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: zoomIn,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.add,
                          size: 24,
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Кнопка уменьшения
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: zoomOut,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.remove,
                          size: 24,
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
