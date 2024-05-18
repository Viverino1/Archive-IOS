import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  final List<String> urls;
  List<Widget>? children = [];
  Carousel({super.key, required this.urls, this.children});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          items: (widget.children?? []) + List.generate(widget.urls.length, (index) => MyImage(url: widget.urls[index]) as Widget),
          options: CarouselOptions(
            autoPlay: false, // Enable auto-play
            enlargeCenterPage: true, // Increase the size of the center item
            enableInfiniteScroll: false, // Enable infinite scroll
            onPageChanged: (index, reason) {
              setState(() {
                _index = index;
              });
            },
          ),
        ),
        SizedBox(height: 12,),
        Stack(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.urls.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: widget.urls.indexOf(item) == (_index - (widget.children != null? widget.children!.length : 0))?
                        Colors.white60 :
                        Colors.white60.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                )).toList()
            ),
          ],
        ),
      ],
    );
  }
}

class MyImage extends StatelessWidget {
  final String url;
  const MyImage({super.key, required this.url});

  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CachedNetworkImage(
        key: UniqueKey(),
        imageUrl: url,
        height: 200,
        width: 300,
        fit: BoxFit.cover,
        // progressIndicatorBuailder: (context, url, downloadProgress) =>
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 55),
        //       child: CircularProgressIndicator(value: downloadProgress.progress),
        //     ),
      ),
    );
  }
}
