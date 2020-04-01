import 'package:spotify/spotify_io.dart';

class SpotifyItems {
  List<Artist> artists;
  List<Track> tracks;
  List<AlbumSimple> albums;
  List<PlaylistSimple> playlists;

  SpotifyItems(
      {List<Artist> artists,
      List<Track> tracks,
      List<AlbumSimple> albums,
      List<PlaylistSimple> playlists}) {
    this.artists = artists ?? [];
    this.tracks = tracks ?? [];
    this.albums = albums ?? [];
    this.playlists = playlists ?? [];
  }

  get length =>
      artists.length + tracks.length + playlists.length + albums.length;
}
