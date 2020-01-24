import 'package:spotify_manager/flutter_spotify/model/base.dart';

class User extends SpotifyItem {
  String displayName;

  User.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    displayName = json['display_name'];
  }
}

class PublicUser extends User {
  PublicUser.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class PrivateUser extends User {
  String country;
  String email;

  PrivateUser.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    country = json['country'];
    email = json['email'];
  }
}
