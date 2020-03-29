import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart' hide Image;
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/widgets/image.dart';
import 'config_page.dart';

const maxSeeds = 5;

class SearchConfigPage extends ConfigPage {
  final Function (List<Artist>) onArtistsChange;
  final Function (List<Track>) onTracksChange;

  SearchConfigPage({GlobalKey<FormState> key, @required this.onArtistsChange, @required this.onTracksChange}) : super(key);

  @override
  Widget buildPage(BuildContext context) => Search(onArtistsChange, onTracksChange);
}

class Search extends StatefulWidget {
  final Function (List<Artist>) onArtistsChange;
  final Function (List<Track>) onTracksChange;

  Search(this.onArtistsChange, this.onTracksChange);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<SearchResult> searchResultsFuture;
  List<Artist> selectedArtists = [];
  List<Track> selectedTracks = [];

  get seedsNum => selectedArtists.length + selectedTracks.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      floatingActionButton: FloatingActionButton(
        child: Text(seedsNum.toString()),
        onPressed: (){
          showModalBottomSheet(context: context, builder: (c) =>
          StatefulBuilder(
            builder: (cc, sheetSetState) => Container(child: Column(
              children: selectedTracks.map<Widget>((track) =>
                  buildTrackTile(track, trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: (){
                      setState((){
                        selectedTracks.remove(track);
                      });
                      widget.onTracksChange(selectedTracks);
                      sheetSetState((){selectedTracks = selectedTracks;});
                    },))).toList() +
                  selectedArtists.map<Widget>((artist) =>
                      buildArtistTile(artist, trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: (){
                          setState((){
                          selectedArtists.remove(artist);
                          });
                          widget.onArtistsChange(selectedArtists);
                          sheetSetState((){selectedArtists=selectedArtists;});
                        },))).toList()
              ,),),
          ));
        },),
      body: Column(children: <Widget>[
        TextFormField(
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.bottomAppBarColor,
            hintText: "Search tracks or artists",
            helperText: "Select music you like"
          ),
          onChanged: (value)=>setState((){
            searchResultsFuture = search(context, value);
          })),
        Padding(padding: EdgeInsets.only(top: 20),),
        Expanded(
          child: FutureBuilder(
            future: searchResultsFuture,
            initialData: 'null',
            builder: (context, snapshot){
              if (snapshot.hasData)
                return snapshot.data == 'null' ? Container():
                buildSearchResults(context, snapshot.data);
              if (snapshot.hasError)
                return Column(children: <Widget>[Icon(Icons.error),
                  Text("an error occured, try again later")],);
              return Center(child: CircularProgressIndicator());
            },
          ),
        )
      ],),
    );
  }

  Future<SearchResult> search(BuildContext context, String searchQuery) async {
    final api = SpotifyContainer.of(context).client;
    return await api.search.get(
        searchQuery, [SearchType.artist, SearchType.track]).first(5);
  }

  buildSearchResults(BuildContext context, SearchResult searchResult) {
    return ListView(children: searchResultsItems(context, searchResult),);
  }

  List<Widget> searchResultsItems(BuildContext context, SearchResult searchResult) {
    addItem<T>(List<T> list, T item, Function(List<T>) onChange){
      FocusScope.of(context).unfocus();
      if (seedsNum >= maxSeeds){
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Select up to 5 items"),));
        return;
      }
      setState(() {
        list.add(item);
      });
      onChange(list);
    }
    final theme = Theme.of(context);
    final listItems = <Widget>[];
    listItems.add(ListTile(title: Text("Tracks", style: theme.textTheme.headline6,),));
    listItems.add(Divider());
    listItems.addAll(ListTile.divideTiles(
      context: context,
        tiles:
      searchResult.tracks.items.map((track) => buildTrackTile(track, onTap: ()=>addItem<Track>(selectedTracks, track, widget.onTracksChange)))
    ));
    listItems.add(ListTile(title: Text("Artists", style: theme.textTheme.headline6,),));
    listItems.add(Divider());
    listItems.addAll(ListTile.divideTiles(
        context: context,
        tiles:
    searchResult.artists.items.map((artist)=>buildArtistTile(artist, onTap: ()=>addItem<Artist>(selectedArtists, artist, widget.onArtistsChange)))
    ));
    return listItems;
  }

  ListTile buildTrackTile(Track track, {Widget trailing, Function onTap}) => ListTile(
    leading: SpotifyImage(images: track.album.images, width: 50, height: 50),
    title: Text(track.name, softWrap: false),
    subtitle: Text("Song | ${track.artists.map((artist) => artist.name).join(', ')}", softWrap: false,),
    trailing: trailing,
    onTap: onTap
  );
  ListTile buildArtistTile(Artist artist, {Widget trailing, Function onTap}) => ListTile(
    leading: SpotifyImage(images: artist.images, width: 50, height: 50),
    title: Text(artist.name, softWrap: false),
    subtitle: Text("Artist", softWrap: false),
    trailing: trailing,
    onTap: onTap,
    );

}
