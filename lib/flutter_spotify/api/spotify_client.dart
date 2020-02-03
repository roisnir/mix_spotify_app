import 'package:spotify_manager/flutter_spotify/api/playlists.dart';
import 'package:spotify_manager/flutter_spotify/api/tracks.dart';
import 'package:spotify_manager/flutter_spotify/model/base.dart';
import 'package:spotify_manager/flutter_spotify/model/playlist.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:spotify_manager/flutter_spotify/model/track.dart';
import 'dart:convert';

import 'package:spotify_manager/flutter_spotify/model/user.dart';

class ApiUrls{
  static const String apiUrl = "https://api.spotify.com";
  static String getFullPath(String endpointUrl) =>
      "$apiUrl/$endpointUrl";
  static String get myPlaylistsUrl =>
      getFullPath("v1/me/playlists");
  static String get myDetailsUrl =>
      getFullPath("v1/me");
  static String playlistCoverImagesUrl(String playlistId) =>
      getFullPath("v1/playlists/$playlistId/images");
  static String addTrackToPlaylistUrl(String playlistId) =>
      getFullPath("v1/playlists/$playlistId/tracks");
  static String removeTrackFromPlaylistUrl(String playlistId) =>
      getFullPath("v1/playlists/$playlistId/tracks");
  static String createPlaylist(String userId) =>
      getFullPath("v1/users/$userId/playlists");
  static String get savedTracksUrl =>
      getFullPath("v1/me/tracks");
}

class SpotifyClient {
  final oauth2.Client client;

  SpotifyClient(this.client);

  Stream<Playlist> get myPlaylists async* {
    final paging = await getPaging(ApiUrls.myPlaylistsUrl);
    yield* PlaylistsPagination(this, paging).stream;
  }

  Future<SavedTracksPagination> get savedTracksPagination async {
    return SavedTracksPagination(this, await getPaging(ApiUrls.savedTracksUrl));
  }

  Stream<SavedTrack> get savedTracks async* {
    final paging = await getPaging(ApiUrls.savedTracksUrl);
    yield* SavedTracksPagination(this, paging).stream;
  }

  Future<PrivateUser> get myDetails async {
    return PrivateUser.fromJson(await get(ApiUrls.myDetailsUrl));
  }

  Future<Map<String, dynamic>> get(String url) async{
    var response = await client.get(url);
    return json.decode(response.body);
  }

  Future<PagingObject> getPaging(String url) async {
    return PagingObject.fromJson(await get(url));
  }

  Future<void> addTrackToPlaylist(String trackUri, String playlistId) async {
    final token = client.credentials.accessToken;
    final headers = <String, String>{
      'Authorization':'Bearer $token',
      "Accept": "application/json"
    };
    final url = Uri.parse(ApiUrls.addTrackToPlaylistUrl(playlistId));
    final response = await client.post(
        url,
        headers: headers,
        body: jsonEncode({'uris': [trackUri]}));
    if (response.statusCode != 200 && response.statusCode != 201)
      return Future.error("error: status code ${response.statusCode}");
  }

  Future<void> removeTrackFromPlaylist(String trackUri, String playlistId) async {
    final token = client.credentials.accessToken;

    final headers = <String, String>{
      'Authorization':'Bearer $token',
      "Accept": "application/json"
    };
    final url = Uri.parse(ApiUrls.addTrackToPlaylistUrl(playlistId));
    final request = http.Request("DELETE", url);
    request.headers.addAll(headers);
    request.body = jsonEncode({"tracks":[{"uri":trackUri}]});
    final response = await request.send();
    if (response.statusCode != 200)
      return Future.error("error: status code ${response.statusCode}");
  }

  Future<Playlist> createPlaylist(String userID, String playlistName) async {
    final token = client.credentials.accessToken;
    final headers = <String, String>{
      'Authorization':'Bearer $token',
      "Accept": "application/json"
    };
    final url = Uri.parse(ApiUrls.createPlaylist(userID));
    final response = await client.post(url, headers: headers, body: jsonEncode({"name":playlistName}));
    if (response.statusCode == 200 || response.statusCode == 201)
      return Playlist.fromJson(jsonDecode(response.body));
    return Future.error("error: status code ${response.statusCode}");
  }
}



Uri getAuthorizationCode(String clientId, String authorizationUrl, String redirectUri, String tokenUrl, String clientSecret, Iterable<String> scopes)
{
  var grant = new oauth2.AuthorizationCodeGrant(
      clientId, Uri.parse(authorizationUrl), Uri.parse(tokenUrl), secret: clientSecret);
  return grant.getAuthorizationUrl(Uri.parse(redirectUri), scopes: scopes);
}
