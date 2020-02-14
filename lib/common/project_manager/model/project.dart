import 'dart:convert';
import 'package:spotify/spotify_io.dart';

class ProjectConfiguration {
  String name;
  String uuid;
  int curIndex;
  List<String> trackIds;
  List<PlaylistSimple> playlists;

  ProjectConfiguration(this.name, this.uuid, this.curIndex, this.trackIds, this.playlists);

  ProjectConfiguration.fromJson (Map<String, dynamic> json) {
    name = json["name"];
    uuid = json["uuid"];
    curIndex = json["curIndex"];
    trackIds = json['trackIds'].map<String>((tId)=> tId as String).toList();
    playlists = json["playlists"].map<PlaylistSimple>((pJson)=>PlaylistSimple.fromJson(pJson)).toList();
  }

  String toJson() {
    return jsonEncode({
      'name': name,
      'uuid': uuid,
      'curIndex': curIndex,
      'trackIds': trackIds,
      'playlists': playlists.map<Map<String, dynamic>>((p)=>p.toJson()).toList()
    });
  }
}