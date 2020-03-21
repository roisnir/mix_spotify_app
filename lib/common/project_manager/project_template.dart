import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';

class ProjectTemplate {
  final String title;
  final String description;
  final IconData icon;
  final Widget Function(List<PlaylistSimple>) builder;

  ProjectTemplate(this.title, this.description, this.icon, {this.builder});
}
