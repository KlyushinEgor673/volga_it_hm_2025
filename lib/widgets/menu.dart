import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:image_cropper/image_cropper.dart';

class Menu extends StatefulWidget {
  const Menu({
    super.key,
    this.lat,
    this.lng,
    required this.path,
    required this.lastDelete,
    required this.isMap,
  });

  final double? lat;
  final double? lng;
  final String path;
  final Function lastDelete;
  final bool isMap;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Color _colorIcon = Colors.black87;
  late String path;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
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
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 4,
      // ignore: deprecated_member_use
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => [
        if (widget.isMap)
          PopupMenuItem(
            value: "map",
            height: 48,
            child: Row(
              children: [
                Icon(
                  Icons.map_rounded,
                  color: Colors.blue[600],
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  'Открыть на карте',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'edit_name',
          height: 48,
          child: Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: Colors.blue[600],
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                'Переименовать',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'change_size',
          height: 48,
          child: Row(
            children: [
              Icon(
                Icons.crop_rounded,
                color: Colors.blue[600],
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                'Обрезать',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // const PopupMenuDivider(height: 8),
        PopupMenuItem(
          value: "delete",
          height: 48,
          child: Row(
            children: [
              Icon(
                Icons.delete_rounded,
                color: Colors.red[600],
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                'Удалить',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      icon: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: _colorIcon,
          size: 22,
        ),
      ),
      onOpened: () {
        setState(() {
          _colorIcon = Colors.blue[600]!;
        });
      },
      onCanceled: () {
        setState(() {
          _colorIcon = Colors.black87;
        });
      },
      onSelected: (value) async {
        setState(() {
          _colorIcon = Colors.black87;
        });

        if (value == 'map') {
          Navigator.pushNamed(context, '/map', arguments: {
            'initialZoom': 17.0,
            'lat': widget.lat,
            'lng': widget.lng,
          });
        } else if (value == 'edit_name') {
          _showRenameDialog();
        } else if (value == 'change_size') {
          Navigator.pushNamed(
            context,
            '/change_size',
            arguments: {'path': path},
          );
        } else {
          _showDeleteConfirmationDialog();
        }
      },
    );
  }

  void _showRenameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Переименовать файл",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _textEditingController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Отмена'),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue[600],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          File file = File(path);
                          var newPathList = path.split('/');
                          newPathList[path.split('/').length - 1] =
                              _textEditingController.text;
                          var newPath = newPathList.join('/');
                          await file.rename(newPath);
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Сохранить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: Colors.red[600],
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Удалить фотографию?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Это действие нельзя отменить',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(
                            // ignore: deprecated_member_use
                            color: Colors.grey.withOpacity(0.4),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await File(widget.path).delete();
                          widget.lastDelete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Удалить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
