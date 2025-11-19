import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:volga_it_hm_2025/images_gallery.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    final imagesGallery = context.watch<ImagesGallery>();
    List dates = [];
    for (final image in imagesGallery.images) {
      String date = image['date'].toString().split(' ')[0];
      if (!dates.contains(date)) {
        dates.add(date);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Галерея',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/map', arguments: {
                'initialZoom': 11.0,
                'lat': 54.3282,
                'lng': 48.3866
              });
            },
            icon: Icon(Icons.map_rounded, color: Colors.blue[700]),
            tooltip: 'Показать на карте',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (imagesGallery.images.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет фотографий',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Добавьте фотографии в галерею',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: dates.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, i) {
                      List<Widget> imagesChildren = [];
                      for (int j = 0; j < imagesGallery.images.length; ++j) {
                        if (imagesGallery.images[j]['date']
                                .toString()
                                .split(' ')[0] ==
                            dates[i]) {
                          imagesChildren.add(
                            _buildImageItem(imagesGallery, j, context),
                          );
                        }
                      }

                      List listDate = dates[i].split('-');
                      return _buildDateSection(listDate, imagesChildren);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(
      ImagesGallery imagesGallery, int j, BuildContext context) {
    final filename = imagesGallery.images[j]['filename'];
    final displayName =
        filename.length > 12 ? '${filename.substring(0, 12)}...' : filename;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/images', arguments: {'i': j});
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Column(
          children: [
            // Контейнер для изображения с тенями и скруглением
            Container(
              width: (MediaQuery.of(context).size.width - 60) / 3,
              height: (MediaQuery.of(context).size.width - 60) / 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.memory(
                      imagesGallery.images[j]['bytes'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    // Градиент для названия файла
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              // ignore: deprecated_member_use
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Название файла
            const SizedBox(height: 6),
            SizedBox(
              width: (MediaQuery.of(context).size.width - 60) / 3,
              child: Text(
                displayName,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(List listDate, List<Widget> imagesChildren) {
    final monthNames = {
      '01': 'Января',
      '02': 'Февраля',
      '03': 'Марта',
      '04': 'Апреля',
      '05': 'Мая',
      '06': 'Июня',
      '07': 'Июля',
      '08': 'Августа',
      '09': 'Сентября',
      '10': 'Октября',
      '11': 'Ноября',
      '12': 'Декабря'
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок даты
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${listDate[2]} ${monthNames[listDate[1]]} ${listDate[0]}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${imagesChildren.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Сетка изображений
        Wrap(
          spacing: 4,
          runSpacing: 12,
          alignment: WrapAlignment.start,
          children: imagesChildren,
        ),
        const SizedBox(height: 8),
        // Разделитель
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                // ignore: deprecated_member_use
                Colors.grey[300]!.withOpacity(0.5),
                Colors.grey[300]!,
                // ignore: deprecated_member_use
                Colors.grey[300]!.withOpacity(0.5),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
