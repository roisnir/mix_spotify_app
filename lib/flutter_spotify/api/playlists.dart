import 'package:spotify_manager/flutter_spotify/api/pagination.dart';
import 'package:spotify_manager/flutter_spotify/api/spotify_client.dart';
import 'package:spotify_manager/flutter_spotify/model/base.dart';
import 'package:spotify_manager/flutter_spotify/model/playlist.dart';

class PlaylistsPagination extends Pagination<Playlist>{
  PlaylistsPagination(SpotifyClient client, PagingObject paging) : super(client, paging);

  @override
  parseItem(Map<String, dynamic> item) {
    return Playlist.fromJson(item);
  }

}