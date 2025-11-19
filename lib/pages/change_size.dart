import 'dart:io';
import 'package:exif/exif.dart';

import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
// import 'package:path_provider/path_provider.dart';

class ChangeSize extends StatefulWidget {
  const ChangeSize({super.key, required this.path});
  final String path;

  @override
  State<ChangeSize> createState() => _ChangeSizeState();
}

class _ChangeSizeState extends State<ChangeSize> {
  double width = 100;
  double height = 100;
  Offset position = Offset(100, 100);
  final GlobalKey _imageKey = GlobalKey();

  // Создание маркера для изменения размера
  Widget _buildResizeHandle(Alignment alignment, Function(Offset) onPanUpdate) {
    return Positioned(
      left: alignment.x == -1 ? 0 : null,
      right: alignment.x == 1 ? 0 : null,
      top: alignment.y == -1 ? 0 : null,
      bottom: alignment.y == 1 ? 0 : null,
      child: GestureDetector(
        onPanUpdate: (details) => onPanUpdate(details.delta),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.open_with, size: 12, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    try {
      // Получаем размеры оригинального изображения
      final originalImage =
          img.decodeImage(File(widget.path).readAsBytesSync())!;
      final double imageWidth = originalImage.width.toDouble();
      final double imageHeight = originalImage.height.toDouble();

      // Получаем размеры отображаемого изображения
      final RenderBox renderBox =
          _imageKey.currentContext!.findRenderObject() as RenderBox;
      final double displayedWidth = renderBox.size.width;
      final double displayedHeight = renderBox.size.height;

      // Вычисляем соотношение между оригинальным и отображаемым изображением
      final double scaleX = imageWidth / displayedWidth;
      final double scaleY = imageHeight / displayedHeight;

      // Преобразуем координаты и размеры выделенной области
      final double cropX = position.dx * scaleX;
      final double cropY = position.dy * scaleY;
      final double cropWidth = width * scaleX;
      final double cropHeight = height * scaleY;

      // Проверяем, чтобы область обрезки не выходила за границы изображения
      final double safeCropX = cropX.clamp(0, imageWidth - 1);
      final double safeCropY = cropY.clamp(0, imageHeight - 1);
      final double safeCropWidth = cropWidth.clamp(1, imageWidth - safeCropX);
      final double safeCropHeight =
          cropHeight.clamp(1, imageHeight - safeCropY);

      // Обрезаем изображение
      final croppedImage = img.copyCrop(
        originalImage,
        x: safeCropX.round(),
        y: safeCropY.round(),
        width: safeCropWidth.round(),
        height: safeCropHeight.round(),
      );

      final bytesOld = await File(widget.path).readAsBytes();
      final exifDataOld = await readExifFromBytes(bytesOld);
      // Сохраняем обрезанное изображение ПОВЕРХ оригинального файла
      File(widget.path).writeAsBytesSync(img.encodePng(croppedImage));
      // Возвращаемся с результатом (путь к тому же файлу)
      if (mounted) {
        Navigator.pushNamed(context, '/');
      }
    } catch (e) {
      print('Ошибка при обрезке изображения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обрезке изображения: $e')),
      );
    }
  }

  Future<void> _showSaveConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Подтверждение'),
          content: Text(
              'Вы уверены, что хотите обрезать изображение? Оригинальный файл будет заменен.'),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Обрезать'),
              onPressed: () {
                Navigator.of(context).pop();
                _cropImage();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Изменение размера'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                width = 100;
                height = 100;
                position = Offset(100, 100);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.crop),
            onPressed: _showSaveConfirmationDialog,
            tooltip: 'Обрезать изображение',
          ),
        ],
      ),
      body: Center(
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Image.file(
                File(widget.path),
                key: _imageKey,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
              Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      position += details.delta;
                    });
                  },
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Угловые маркеры
                        _buildResizeHandle(Alignment.topLeft, (delta) {
                          setState(() {
                            width -= delta.dx;
                            height -= delta.dy;
                            position += delta;
                            width = width.clamp(50, 500);
                            height = height.clamp(50, 500);
                          });
                        }),
                        _buildResizeHandle(Alignment.topRight, (delta) {
                          setState(() {
                            width += delta.dx;
                            height -= delta.dy;
                            position += Offset(0, delta.dy);
                            width = width.clamp(50, 500);
                            height = height.clamp(50, 500);
                          });
                        }),
                        _buildResizeHandle(Alignment.bottomLeft, (delta) {
                          setState(() {
                            width -= delta.dx;
                            height += delta.dy;
                            position += Offset(delta.dx, 0);
                            width = width.clamp(50, 500);
                            height = height.clamp(50, 500);
                          });
                        }),
                        _buildResizeHandle(Alignment.bottomRight, (delta) {
                          setState(() {
                            width += delta.dx;
                            height += delta.dy;
                            width = width.clamp(50, 500);
                            height = height.clamp(50, 500);
                          });
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
