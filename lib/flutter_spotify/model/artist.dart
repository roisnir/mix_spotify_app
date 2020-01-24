import 'package:spotify_manager/flutter_spotify/model/base.dart';

class SimpleArtist extends SpotifyItem{
  String name;

  SimpleArtist.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.name = json["name"];
  }


}