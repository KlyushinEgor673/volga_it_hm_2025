import 'package:flutter/material.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/map', arguments: {
                    'initialZoom': 11.0,
                    'lat': 56.326797,
                    'lng': 44.006516
                  });
                },
                icon: Icon(Icons.map_rounded))
          ],
        ),
        body: SafeArea(
          child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, i) {
                    List<Widget> imagesChildren = [];
                    for (int j = 0; j < imagesGallery.images.length; ++j) {
                      if (imagesGallery.images[j]['date']
                              .toString()
                              .split(' ')[0] ==
                          dates[i]) {
                        imagesChildren.add(GestureDetector(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Image.memory(
                                width:
                                    (MediaQuery.of(context).size.width - 35) /
                                        4,
                                height:
                                    (MediaQuery.of(context).size.width - 35) /
                                        4,
                                imagesGallery.images[j]['bytes'],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/images',
                                arguments: {'i': j});
                          },
                        ));
                      }
                    }
                    List listDate = dates[i].split('-');
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${listDate[2]} ${listDate[1]}  ${listDate[0]}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: imagesChildren,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                        ]);
                  })),
        ));
  }
}
