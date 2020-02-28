import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/common/project_manager/project.dart';
import 'package:spotify_manager/screens/create_project/create_project.dart';
import 'project_screen.dart';

const projectsFileName = 'projects.json';

class ProjectsScreenState extends State<ProjectsScreen> {
  List<ProjectConfiguration>_projects;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProjects().then((projects)=>setState(() {
      _projects = projects;
      isLoading = false;
    }));
  }

  Future<List<ProjectConfiguration>> loadProjects() async {
    final db = ProjectsDB();
    final projects = List<ProjectConfiguration>.from(await db.getProjectsConf());
    db.close();
    return projects;

  }

  Widget _buildRow(ProjectConfiguration project) {
    return ListTile(
      title: Text(project.name),
      leading: Icon(Icons.album),
      //          SizedBox(
//            width: 150,
//            child: LinearPercentIndicator(
//              lineHeight: 20.0,
//              center: Text("${(project.curIndex / project.trackIds.length * 100).toStringAsFixed(1)}%"),
//              percent: project.curIndex / project.trackIds.length,
//              backgroundColor: Colors.grey,
//              progressColor: Colors.green,
//            ),
//          ),
      trailing: PopupMenuButton(itemBuilder: (c) => [PopupMenuItem(value: 1, child: Text('Delete'),)],onSelected: (v) async {
        setState(() {
          _projects.remove(project);
        });
        final db = ProjectsDB();
        await db.removeProject(project.uuid);
        db.close();
      }, )
      ,
      onTap: () async {
        int index = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext subContext) {
          return ProjectScreen(
            projectConfig: project,
            client: SpotifyContainer.of(context).client,
            me: SpotifyContainer.of(context).myDetails,
          );
        }));
        setState(() {
          project.curIndex = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 50, height: 50,
              child: CircularProgressIndicator()),
          Padding(padding: EdgeInsets.all(8.0),
          child: Text("loading..."),)
        ],
      );
    final spotifyClient = SpotifyContainer.of(context).client;
    final myDetails = SpotifyContainer.of(context).myDetails;
    var projectsWidgets = (_projects.map<Widget>((p) => _buildRow(p))).toList();
    projectsWidgets.insert(
      0,
      ListTile(
        title: Text("Start a New Project"),
        leading: Icon(Icons.add),
        onTap: () async {
          ProjectConfiguration newProject = await
          Navigator.of(context)
              .push(MaterialPageRoute(builder:
              (BuildContext context) => CreateProject(spotifyClient, myDetails)));
          if (newProject != null)
            setState(() {
              _projects.add(newProject);
            });
        },
      ),
    );
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: ListTile.divideTiles(context: context, tiles: projectsWidgets)
          .toList(),
    );
  }
}

class ProjectsScreen extends StatefulWidget {
  @override
  ProjectsScreenState createState() => ProjectsScreenState();
}
