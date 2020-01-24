import 'package:spotify_manager/flutter_spotify/model/album.dart';
import 'package:spotify_manager/flutter_spotify/model/artist.dart';
import 'package:spotify_manager/flutter_spotify/model/base.dart';


class SavedTrack {
  String timestamp;
  Track track;

  SavedTrack.fromJson(Map<String, dynamic> json){
    timestamp = json['timestamp'];
    track = Track.fromJson(json['track']);
  }
}


class Track extends SpotifyItem {
  String name;
  SimpleAlbum album;
  List<SimpleArtist> artists;
  String previewUrl;
  int discNumber;
  num durationMs;
  int popularity;
  int trackNumber;


  Track.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    name = json['name'];
    album = SimpleAlbum.fromJson(json['album']);
    artists = json["artists"].map<SimpleArtist>((artistJson) =>
        SimpleArtist.fromJson(artistJson)).toList();
    previewUrl = json["preview_url"];
    discNumber = json["disc_number"];
    durationMs = json["duration_ms"];
    popularity = json["popularity"];
    trackNumber = json["track_number"];
  }


}