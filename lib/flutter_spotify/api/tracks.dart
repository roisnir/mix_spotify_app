import 'package:spotify_manager/flutter_spotify/api/pagination.dart';
import 'package:spotify_manager/flutter_spotify/api/spotify_client.dart';
import 'package:spotify_manager/flutter_spotify/model/base.dart';
import 'package:spotify_manager/flutter_spotify/model/track.dart';

class SavedTracksPagination extends Pagination<SavedTrack>{
  SavedTracksPagination(SpotifyClient client, PagingObject paging) : super(client, paging);

  @override
  parseItem(Map<String, dynamic> item) {
    return SavedTrack.fromJson(item);
  }

}

class TracksPagination extends Pagination<Track>{
  TracksPagination(SpotifyClient client, PagingObject paging) : super(client, paging);

  @override
  parseItem(Map<String, dynamic> item) {
    return Track.fromJson(item['track']);
  }

}