import 'dart:convert';
import 'package:spotify/spotify_io.dart';
import 'package:uuid/uuid.dart';

class ProjectConfiguration {
  String name;
  String uuid;
  int curIndex;
  List<String> trackIds;
  List<String> playlistIds;
  bool isActive;

  ProjectConfiguration(this.name, this.uuid, this.curIndex, this.trackIds, this.playlistIds, [this.isActive = true]);

  ProjectConfiguration.fromJson (Map<String, dynamic> json, [List<String> _trackIds]) {
    name = json["name"];
    uuid = json["uuid"];
    curIndex = json["curIndex"];
    trackIds = _trackIds ?? json['trackIds'].map<String>((tId)=> tId as String).toList();
    playlistIds = json["playlistIds"].split(";").toList();
    isActive =  json["isActive"] == 1 || json["isActive"] == true;
  }

  ProjectConfiguration.init(this.name, this.trackIds, this.playlistIds){
    curIndex = 0;
    uuid = Uuid().v4();
    isActive = true;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uuid': uuid,
      'curIndex': curIndex,
      'trackIds': trackIds,
//      'totalTracks': trackIds.length,
      'playlistIds': playlistIds.join(';'),
      'isActive': isActive ? 1 : 0
    };
  }
}