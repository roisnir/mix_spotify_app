import 'package:uuid/uuid.dart';

class ProjectConfiguration {
  String name;
  String uuid;
  int _curIndex;
  List<String> trackIds;
  List<String> playlistIds;
  DateTime lastModified;
  String type;
  bool isArchived;
  bool isActive;


  int get curIndex => _curIndex;

  set curIndex(int value) {
    _curIndex = value;
    lastModified = DateTime.now();
  }

  ProjectConfiguration(this.name, this.uuid, this._curIndex, this.trackIds, this.playlistIds, [this.isActive = true]);

  ProjectConfiguration.fromJson (Map<String, dynamic> json, [List<String> _trackIds]) {
    name = json["name"];
    uuid = json["uuid"];
    _curIndex = json["curIndex"];
    trackIds = _trackIds ?? json['trackIds'].map<String>((tId)=> tId as String).toList();
    playlistIds = json["playlistIds"].split(";").toList();
    type = json["type"];
    lastModified = DateTime.parse(json["lastModified"]);
    isArchived =  json["isArchived"] == 1 || json["isArchived"] == true;
    isActive =  json["isActive"] == 1 || json["isActive"] == true;
  }

  ProjectConfiguration.init(this.name, this.trackIds, this.playlistIds, this.type){
    curIndex = 0;
    uuid = Uuid().v4();
    lastModified = DateTime.now();
    isActive = true;
    isArchived = false;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uuid': uuid,
      'curIndex': curIndex,
      'trackIds': trackIds,
      'playlistIds': playlistIds.join(';'),
      'type': type,
      'lastModified': lastModified.toIso8601String(),
      'isArchived': isArchived ? 1: 0,
      'isActive': isActive ? 1 : 0
    };
  }
}