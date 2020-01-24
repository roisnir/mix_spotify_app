import 'package:spotify_manager/flutter_spotify/model/artist.dart';
import 'package:spotify_manager/flutter_spotify/model/base.dart';
import 'package:spotify_manager/flutter_spotify/model/image.dart';


class SimpleAlbum extends SpotifyItem{
  String name;
  String albumType;
  List<SimpleArtist> artists;
  int totalTracks;
  List<Image> images;

  SimpleAlbum.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    name = json["name"];
    albumType = json["album_type"];
    artists = json["artists"].map<SimpleArtist>((aJson) => SimpleArtist.fromJson(aJson)).toList();
    totalTracks = json["total_tracks"];
    images = json['images'].map<Image>((iJson)=> Image.fromJson(iJson)).toList();
  }

}