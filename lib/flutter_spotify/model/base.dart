import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class SpotifyItem {
  String href;
  String type;
  String uri;
  String id;

//  SpotifyItem(this.href, this.type, this.uri, this.id);

  SpotifyItem.fromJson(Map<String, dynamic> json){
    href = json['href'];
    type = json['type'];
    uri = json['uri'];
    id = json['id'];
  }
}

class PagingObject {
  String href;
  List<Map<String, dynamic>> items;
  int limit;
  String next;
  String previous;
  int offset;
  int total;

//  SpotifyItem(this.href, this.type, this.uri, this.id);
  PagingObject.fromJson(Map<String, dynamic> json){

    href = json['href'];
    items = json['items'].map<Map<String, dynamic>>((i)=> i as Map<String, dynamic>).toList();
    limit = json['limit'];
    next = json['next'];
    previous = json['previous'];
    offset = json['offset'];
    total = json['total'];
  }
   PagingObject.fromPagingObject(PagingObject other) {
    href = other.href;
    items = other.items;
    limit = other.limit;
    next = other.next;
    previous = other.previous;
    offset = other.offset;
    total = other.total;
   }
}