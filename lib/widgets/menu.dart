import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:image_cropper/image_cropper.dart';

class Menu extends StatefulWidget {
  const Menu(
      {super.key,
      this.lat,
      this.lng,
      required this.path,
      required this.lastDelete,
      required this.isMap});

  final double? lat;
  final double? lng;
  final String path;
  final Function lastDelete;
  final bool isMap;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Color _color = Colors.grey.withAlpha(200);
  Color _colorIcon = Colors.black;
  late String path;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      path = widget.path;
      _textEditingController.text =
          widget.path.split('/')[widget.path.split('/').length - 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      color: Colors.grey.withAlpha(200),
      itemBuilder: (context) => [
        if (widget.isMap)
          PopupMenuItem(
            value: "map",
            child: Row(
              children: [
                Icon(Icons.map_rounded),
                SizedBox(
                  width: 15,
                ),
                Text('Карта')
              ],
            ),
          ),
        PopupMenuItem(
            value: 'edit_name',
            child: Row(
              children: [
                Icon(
                  Icons.edit_rounded,
                ),
                SizedBox(
                  width: 15,
                ),
                Text('Переименовать')
              ],
            )),
        PopupMenuItem(
            value: 'change_size',
            child: Row(
              children: [
                Icon(
                  Icons.crop,
                ),
                SizedBox(
                  width: 15,
                ),
                Text('Обрезать')
              ],
            )),
        PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(
                  Icons.share,
                ),
                SizedBox(
                  width: 15,
                ),
                Text('Поделиться')
              ],
            )),
        PopupMenuItem(
          value: "delete",
          child: Row(
            children: [
              Icon(
                Icons.delete_rounded,
                color: Color.fromRGBO(190, 25, 25, 1),
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                'Удалить',
                style: TextStyle(color: Color.fromRGBO(190, 25, 25, 1)),
              )
            ],
          ),
        ),
      ],
      icon: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
            color: _color, borderRadius: BorderRadius.circular(50)),
        child: Icon(
          Icons.more_vert,
          color: _colorIcon,
        ),
      ),
      onOpened: () {
        setState(() {
          _color = Colors.transparent;
          _colorIcon = Colors.transparent;
        });
      },
      onCanceled: () {
        setState(() {
          _color = Colors.grey.withAlpha(200);
          _colorIcon = Colors.black;
        });
      },
      onSelected: (value) async {
        setState(() {
          _color = Colors.grey.withAlpha(200);
          _colorIcon = Colors.black;
        });
        if (value == 'map') {
          Navigator.pushNamed(context, '/map', arguments: {
            'initialZoom': 17.0,
            'lat': widget.lat,
            'lng': widget.lng
          });
        } else if (value == 'edit_name') {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("Изменение имени"),
                  content: TextField(
                    controller: _textEditingController,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          File file = File(path);
                          var newPathList = path.split('/');
                          newPathList[path.split('/').length - 1] =
                              _textEditingController.text;
                          var newPath = newPathList.join('/');
                          await file.rename(newPath);
                          print(newPath);
                          Navigator.pop(context);
                        },
                        child: Text('изменить')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('отмена'))
                  ],
                );
              });
        } else if (value == 'change_size') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false, // Удаляет всю историю
          );
          // final croppedFile = await ImageCropper().cropImage(
          //   sourcePath: widget.path,
          //   uiSettings: [
          //     AndroidUiSettings(
          //       toolbarTitle: 'Cropper',
          //       toolbarColor: Colors.deepOrange,
          //       toolbarWidgetColor: Colors.white,
          //       aspectRatioPresets: [
          //         CropAspectRatioPreset.original,
          //         CropAspectRatioPreset.square,
          //         // CropAspectRatioPresetCustom(),
          //       ],
          //     ),
          //     WebUiSettings(
          //       context: context,
          //     ),
          //   ],
          // );
        } else if (value == 'share') {
          final url = Uri.parse('https://auroraos.ru');
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("Подтверждение"),
                  content: Text('Вы уверены что хотит уалить фотографию?'),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await File(widget.path).delete();
                          widget.lastDelete();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color.fromRGBO(190, 25, 25, 1),
                        ),
                        child: Text('ок')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                        child: Text('отмена'))
                  ],
                );
              });
        }
      },
    );
  }
}
