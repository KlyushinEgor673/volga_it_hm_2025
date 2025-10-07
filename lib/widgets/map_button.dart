import 'package:flutter/material.dart';

class MapButton extends StatelessWidget {
  const MapButton({super.key, required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
                child: Container(
                  width: 45,
                  height: 45,
                  child: Icon(Icons.map_rounded),
                                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(200),
                    borderRadius: BorderRadius.circular(50)
                  ),
                ),
              onTap: (){
                Navigator.pushNamed(context, '/map', arguments: {'initialZoom': 17.0, 'lat': lat, 'lng': lng});
              },
            );
  }
}