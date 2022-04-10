import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularImageContainer extends StatelessWidget {
  final String imagePath;
  //width percentage must be more than 0.15 to height percentage
  final double width;
  final double height;
  const CircularImageContainer({Key? key, required this.height, required this.imagePath, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        radius: height,
        backgroundImage: CachedNetworkImageProvider(
          imagePath,
        ),
      ),
    );
  }
}
