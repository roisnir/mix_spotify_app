import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_manager/widgets/image.dart';

class Search extends StatefulWidget {
  final SpotifyApi api;
  final Function(Track) onTrackTap;
  final Function(Artist) onArtistTap;
  
  Search({@required this.api, this.onTrackTap, this.onArtistTap});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<SearchResult> searchResultsFuture;
  String searchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        TextFormField(
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
                filled: true,
                fillColor: theme.bottomAppBarColor,
                hintText: "Search tracks or artists",
                helperText: "Select music you like"),
            onChanged: (value) => setState(() {
                  searchQuery = value;
                  if (searchQuery.length > 0)
                    searchResultsFuture = search(widget.api, searchQuery);
                })),
        Padding(
          padding: EdgeInsets.only(top: 20),
        ),
        Expanded(
          child: FutureBuilder(
            future: searchResultsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData)
                return buildSearchResults(context, snapshot.data);
              if (searchQuery == null || searchQuery.length == 0)
                return Container();
              if (snapshot.hasError)
                return Column(
                  children: <Widget>[
                    Icon(Icons.error),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    Text("an error occured, try again later")
                  ],
                );
              return Center(
                child: SizedBox(child: CircularProgressIndicator()),
                widthFactor: 100,
              );
            },
          ),
        )
      ],
    );
  }

  Future<SearchResult> search(SpotifyApi api, String searchQuery) async {
    return await api.search
        .get(searchQuery, [SearchType.artist, SearchType.track]).first(5);
  }

  buildSearchResults(BuildContext context, SearchResult searchResult) {
    return ListView(
      children: searchResultsItems(context, searchResult),
    );
  }

  List<Widget> searchResultsItems(BuildContext context, SearchResult searchResult) {
    final theme = Theme.of(context);
    final listItems = <Widget>[];
    listItems.add(ListTile(
      title: Text(
        "Tracks",
        style: theme.textTheme.headline6,
      ),
    ));
    listItems.add(Divider());
    listItems.addAll(ListTile.divideTiles(
        context: context,
        tiles: searchResult.tracks.items
            .map((track) => TrackTile(track, onTap: widget.onTrackTap))));
    listItems.add(ListTile(
      title: Text(
        "Artists",
        style: theme.textTheme.headline6,
      ),
    ));
    listItems.add(Divider());
    listItems.addAll(ListTile.divideTiles(
        context: context,
        tiles: searchResult.artists.items
            .map((artist) => ArtistTile(artist, onTap: widget.onArtistTap))));
    return listItems;
  }
}


class TrackTile extends StatelessWidget {
  final Track track;
  final Widget trailing;
  final Function(Track) onTap;
  final String genres;

  TrackTile(this.track, {this.trailing, this.onTap, this.genres});

  @override
  Widget build(BuildContext context) {
    var subtitle = "Song | ${track.artists.map((artist) => artist.name).join(', ')}";
    if (this.genres != null && this.genres.length > 0)
      subtitle += '\r\n$genres';
    return ListTile(
      leading:
      SpotifyImage(images: track.album.images, width: 50, height: 50),
      title: Text(track.name, softWrap: false),
      subtitle: Text(
        subtitle,
        softWrap: false,
      ),
      isThreeLine: genres != null && genres.length > 0,
      trailing: trailing,
      onTap: () => onTap(track));
  }
}

class ArtistTile extends StatelessWidget {
  final Artist artist;
  final Widget trailing;
  final Function(Artist) onTap;

  ArtistTile(this.artist, {this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: SpotifyImage(images: artist.images, width: 50, height: 50),
    title: Text(artist.name, softWrap: false),
    subtitle: Text("Artist", softWrap: false),
    trailing: trailing,
    onTap: () => onTap(artist),
  );
}

