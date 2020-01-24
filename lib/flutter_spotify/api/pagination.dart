import 'dart:async';
import 'package:spotify_manager/flutter_spotify/api/spotify_client.dart';
import 'package:spotify_manager/flutter_spotify/model/base.dart';


abstract class Pagination<T> {
  PagingObject paging;
  final SpotifyClient client;

  Pagination(this.client, this.paging);

  T parseItem(Map<String, dynamic> item);

  Stream<T> _itemsToStream(List<Map<String, dynamic>> items){
    return Stream<T>.fromIterable(
        this.paging.items.map((item)=> parseItem(item)));
  }

  Stream<T> get stream async* {
    yield* _itemsToStream(this.paging.items);
    while (paging.next != null){
      paging = await client.getPaging(paging.next);
      yield* _itemsToStream(this.paging.items);
    }

  }
}
