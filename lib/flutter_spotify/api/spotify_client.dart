import 'package:spotify_manager/flutter_spotify/api/playlists.dart';
import 'package:spotify_manager/flutter_spotify/api/tracks.dart';
import 'package:spotify_manager/flutter_spotify/model/base.dart';
import 'package:spotify_manager/flutter_spotify/model/playlist.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
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
}



Uri getAuthorizationCode(String clientId, String authorizationUrl, String redirectUri, String tokenUrl, String clientSecret, Iterable<String> scopes)
{
  var grant = new oauth2.AuthorizationCodeGrant(
      clientId, Uri.parse(authorizationUrl), Uri.parse(tokenUrl), secret: clientSecret);
  return grant.getAuthorizationUrl(Uri.parse(redirectUri), scopes: scopes);
}
