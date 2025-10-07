import 'dart:io';

import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  const Menu({super.key, required this.lat, required this.lng, required this.path, required this.lastDelete});
  final double lat;
  final double lng;
  final String path;
  final Function lastDelete;
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Color _color = Colors.grey.withAlpha(200);
  Color _colorIcon = Colors.black;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      color: Colors.grey.withAlpha(200),
      itemBuilder: (context) => [
    PopupMenuItem(
      child: Row(children: [Icon(Icons.map_rounded), SizedBox(width: 15,), Text('Карта')],),
      value: "map",
    ),
    PopupMenuItem(
      child: Row(children: [Icon(Icons.delete_rounded, color: Colors.red,), SizedBox(width: 15,), Text('Удалить', style: TextStyle(color: Colors.red),)],),
      value: "delete",
      
    ),
  ], 
  icon: Container(
    width: 45,
    height: 45,
    child: Icon(Icons.more_vert, color: _colorIcon,),
    decoration: BoxDecoration(
      color: _color,
      borderRadius: BorderRadius.circular(50)
    ),
  ),
  onOpened: (){
    setState(() {
      _color = Colors.transparent;
      _colorIcon = Colors.transparent;
    });
  },
  onCanceled: (){
    setState(() {
      _color = Colors.grey.withAlpha(200);
      _colorIcon = Colors.black;
    });
  },
    onSelected: (value){
          setState(() {
      _color = Colors.grey.withAlpha(200);
      _colorIcon = Colors.black;
    });
      if (value == 'map'){
        Navigator.pushNamed(context, '/map', arguments: {
                             'initialZoom': 17.0,
                    'lat': 56.326797,
                    'lng': 44.006516
        });
      } else {
         showDialog(context: context, builder: (BuildContext context){
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text("Подтверждение"),
                      content: Text('Вы уверены что хотит уалить фотографию?'),
                      actions: [
                        TextButton(onPressed: () async {
                          await File(widget.path).delete();
                          Navigator.pop(context);
                          widget.lastDelete();
                        }, style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ), child: Text('ок')),
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                        },style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ), child: Text('отмена'))
                      ],
                    );
                  }
                  );
      }
    },
    );
  }
}