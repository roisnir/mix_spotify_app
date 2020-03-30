import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_manager/common/project_manager/model/spotify_items.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/widgets/search.dart';
import 'config_page.dart';

const maxSeeds = 5;

nullFunc(v) {}

class SearchConfigPage extends ConfigPage {
  final Function(SpotifyItems) onSaved;
  SearchConfigPage({GlobalKey<FormState> key, @required this.onSaved})
      : super(key);

  @override
  Widget buildPage(BuildContext context) => SearchFormField(
        onSaved: onSaved,
        validator: (items) => items.length > 0 && items.length <= maxSeeds
            ? null
            : "Select at least one item",
      );
}

class SearchFormField extends StatefulWidget {
  final Function(SpotifyItems) onSaved;
  final Function(SpotifyItems) onChanged;
  final String Function(SpotifyItems) validator;

  SearchFormField(
      {this.onSaved, Function(SpotifyItems) onChanged, this.validator})
      : this.onChanged = onChanged ?? nullFunc;

  @override
  _SearchFormFieldState createState() => _SearchFormFieldState();
}

class _SearchFormFieldState extends State<SearchFormField> with AutomaticKeepAliveClientMixin<SearchFormField>{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FormField<SpotifyItems>(
      initialValue: SpotifyItems(),
      onSaved: widget.onSaved,
      validator: (items){
        final errorStr = widget.validator(items);
        if (errorStr != null)
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Select at least one item"),));
        return errorStr;
      },
      builder: (state) {
        final selectedItems = state.value;
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          floatingActionButton: FloatingActionButton(
            child: Text(selectedItems.length.toString()),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (c) => StatefulBuilder(
                        builder: (cc, sheetSetState) => Container(
                          child: buildBottomSheet(
                              selectedItems, sheetSetState, state),
                        ),
                      ));
            },
          ),
          body: Search(
            api: SpotifyContainer.of(context).client,
            onTrackTap: (track) => setItems(context, state, ()=>selectedItems..tracks.add(track)),
            onArtistTap: (artist) => setItems(context, state, ()=>selectedItems..artists.add(artist)),
          ),
        );
      },
    );
  }

  setItems(BuildContext context, FormFieldState<SpotifyItems> state, SpotifyItems Function() changeState){
    FocusScope.of(context).requestFocus(FocusNode());
    if (state.value.length >= maxSeeds){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Select up to 5 items"),));
      return;
    }
    final newState = changeState();
    state.didChange(newState);
    widget.onChanged(newState);
  }

  Column buildBottomSheet(SpotifyItems selectedItems, StateSetter sheetSetState,
      FormFieldState<SpotifyItems> state) {
    return Column(
      children: selectedItems.tracks
              .map<Widget>((track) => TrackTile(track,
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      sheetSetState(() {
                        selectedItems.tracks.remove(track);
                        state.didChange(selectedItems);
                        if (selectedItems.length == 0)
                          Navigator.of(context).pop();
                      });
                    },
                  )))
              .toList() +
          selectedItems.artists
              .map<Widget>((artist) => ArtistTile(artist,
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      sheetSetState(() {
                        selectedItems.artists.remove(artist);
                        state.didChange(selectedItems);
                      });
                    },
                  )))
              .toList(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
