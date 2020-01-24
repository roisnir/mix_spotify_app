import 'package:spotify_manager/flutter_spotify/model/base.dart';
import 'package:spotify_manager/flutter_spotify/model/image.dart';
import 'package:spotify_manager/flutter_spotify/model/user.dart';

class Playlist extends SpotifyItem {
  String name;
  String description;
  bool public;
  int totalTracks;
  PublicUser owner;
  String tracksHref;
  List<Image> images;

  


  Playlist.fromJson(Map<String, dynamic> json): super.fromJson(json) {
    name = json['name'];
    description = json['description'];
    owner = PublicUser.fromJson(json['owner']);
    public = json['public'];
    totalTracks = json['tracks']["total"];
    tracksHref = json['tracks']["href"];
    images = json['images'].map<Image>((iJson)=> Image.fromJson(iJson)).toList();

  }
}