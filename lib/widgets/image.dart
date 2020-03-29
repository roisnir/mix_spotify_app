import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart' as spotify;

class SpotifyImage extends StatelessWidget {
  final double height;
  final double width;
  final List<spotify.Image> images;
SpotifyImage({@required this.images, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    if (images.length < 1)
      return SizedBox(width: width, height: height);
    final image = images[0];
    var _height = height ?? image.height;
    var _width = width ?? image.width;
    return Image.network(image.url, width: _width, height: _height,);
  }
}
