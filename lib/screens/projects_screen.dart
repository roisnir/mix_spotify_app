import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/common/project_manager/projects_endpoint.dart';
import 'package:spotify_manager/common/utils.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/screens/create_project/select_template.dart';
import 'package:spotify_manager/screens/edit_project.dart';
import 'package:spotify_manager/screens/project_list_view.dart';
import 'project_screen.dart';

const projectsFileName = 'projects.json';

class ProjectsScreenState extends State<ProjectsScreen> {
  List<ProjectConfiguration>_projects;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProjects(widget.user.id).then((projects)=>setState(() {
      _projects = projects;
      isLoading = false;
    }));
  }

  Widget projectIcon(String projectType, [Color accentColor=Colors.green]){
    var subIcon;
    switch (projectType){
      case "SavedSongs":
        subIcon = Icons.favorite;
        break;
      case "Discover":
        subIcon = Icons.explore;
        break;
      case "Extend":
        subIcon = Icons.all_out;
        break;
      case "Maintain":
        subIcon = Icons.build;
        break;
    }
    return SizedBox(
      width: 32, height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(Icons.sort, size: 28,),
          Align(alignment: Alignment.bottomRight, child: Icon(subIcon, size: 16, color: accentColor,))
        ],
      ),
    );
  }

  Widget projectMenuItem(int index, String title, IconData icon) =>
      PopupMenuItem(
          value: index,
          child: Row(
            children: <Widget>[
              Icon(icon),
              Padding(padding: EdgeInsets.only(left: 10),),
              Text(title)],));

  Widget _buildRow(BuildContext context, ProjectConfiguration project) {
    return ListTile(
      title: Text(project.name),
      leading: projectIcon(project.type),
      trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
              LinearPercentIndicator(
                width: 80,
                padding: EdgeInsets.symmetric(horizontal: 3),
                lineHeight: 15.0,
                center: Text(
                    "${((project.curIndex + 1) / project.trackIds.length * 100).toStringAsFixed(1)}%", style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.bold),),
                percent: (project.curIndex + 1) / project.trackIds.length,
                backgroundColor: Colors.green[200],
                progressColor: Colors.green[600],
              ),
            PopupMenuButton(itemBuilder: (c) => (project.isArchived ? <PopupMenuItem>[] : <PopupMenuItem>[
              projectMenuItem(0, "Player View", Icons.subscriptions),
              projectMenuItem(1, "List View", Icons.queue_music),
              projectMenuItem(2, "Edit", Icons.edit),
            ]) + <PopupMenuItem>[
              projectMenuItem(
                  3,
                  project.isArchived ? "Unarchive": "Archive",
                  project.isArchived ? Icons.unarchive : Icons.archive),
              projectMenuItem(4, "Delete", Icons.delete),
            ],onSelected: (v) {
              <Function()>[
                ()=>launchProject(context, project),
                ()=>launchProjectListView(context, project),
                ()=>launchEditProject(context, project),
                ()=>archiveProject(project),
                ()=>deleteProject(context, project)
              ][v]();
            }, )
          ]),
      onTap: () async {
        if (!project.isArchived)
          return launchProjectListView(context, project);
        DialogResult dialogRes = await showDialog(context: context, child: AlertDialog(
          title: Text("Unarchive"),
          content: Text("Do you want to unarchive this project?"),
          actions: <Widget>[
            FlatButton(child: Text("Yes"), onPressed: ()=>Navigator.of(context).pop(DialogResult.Yes),),
            FlatButton(child: Text("No"), onPressed: ()=>Navigator.of(context).pop(DialogResult.No))],
        ));
        if (dialogRes == DialogResult.No)
          return;
        archiveProject(project);
      },
    );
  }

  Future deleteProject(BuildContext context, ProjectConfiguration project) async {
    DialogResult dialogRes = await showDialog(context: context, child: AlertDialog(
      title: Text("Delete"),
      content: Text("Are you sure?"),
      actions: <Widget>[
        FlatButton(child: Text("Yes"), onPressed: ()=>Navigator.of(context).pop(DialogResult.Yes),),
        FlatButton(child: Text("No"), onPressed: ()=>Navigator.of(context).pop(DialogResult.No))],
    ));
    if (dialogRes == DialogResult.No)
        return;
    final db = ProjectsDB();
    await db.removeProject(project.uuid);
    db.close();
    setState(() {
      _projects.remove(project);
    });
  }

  Future archiveProject(ProjectConfiguration project, [ProjectsDB db]) async {
    db ??= ProjectsDB();
    DateTime mtime = await db.setIsArchived(project.uuid, !project.isArchived);
    db.close();
    setState(() {
      project.isArchived = !project.isArchived;
      project.lastModified = mtime;
    });
  }

  launchProject(BuildContext context, ProjectConfiguration project) async {
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
    final db = ProjectsDB();
    await db.updateIndex(project.uuid, index);
    if (project.curIndex + 1 == project.trackIds.length)
      await launchProjectDoneDialog(context, project, db);
    db.close();
  }

  launchEditProject(BuildContext context, ProjectConfiguration project) {
    final global = SpotifyContainer.of(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (c)=>EditProject(
        global.client, global.myDetails, project,)));
  }

  launchProjectListView(BuildContext context, ProjectConfiguration project) async {
    int index = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext subContext) {
      return ProjectListView(
        projectConfig: project,
        api: SpotifyContainer.of(context).client,
        me: SpotifyContainer.of(context).myDetails,
      );
    }));
    setState(() {
      project.curIndex = index;
    });
    final db = ProjectsDB();
    await db.updateIndex(project.uuid, index);
    if (project.curIndex + 1 == project.trackIds.length)
      await launchProjectDoneDialog(context, project, db);
    db.close();
  }

  Future<void> launchProjectDoneDialog(BuildContext context, ProjectConfiguration project, ProjectsDB db) async {
    DialogResult dialogRes = await showDialog(context: context, child: AlertDialog(
      title: Text("All Done!"),
      content: Text("Nice work!\r\nDo you want to archive this project?"),
      actions: <Widget>[
        FlatButton(child: Text("Yes"), onPressed: ()=>Navigator.of(context).pop(DialogResult.Yes),),
        FlatButton(child: Text("No"), onPressed: ()=>Navigator.of(context).pop(DialogResult.No))],
    ));
    if (dialogRes == DialogResult.No)
      return;
    await archiveProject(project, db);
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
    var projectsWidgets = ((_projects.where((project) => !project.isArchived).toList()..sort(
            (a, b)=>-a.lastModified.compareTo(b.lastModified))).map<Widget>(
            (p) => _buildRow(context, p))).toList();
    var archivedProjects = ((_projects.where((project) => project.isArchived).toList()..sort(
            (a, b)=>-a.lastModified.compareTo(b.lastModified))).map<Widget>(
            (p) => _buildRow(context, p))).toList();
    projectsWidgets.insert(
      0,
      ListTile(
        title: Text("Start a New Project"),
        leading: Icon(Icons.add),
        onTap: () async {
          ProjectConfiguration newProject = await
          Navigator.of(context)
              .push(MaterialPageRoute(builder:
              (BuildContext context) => SelectTemplate(spotifyClient, myDetails)));
          if (newProject != null) {
            setState(() {
              _projects.add(newProject);
            });
            await launchProjectListView(context, newProject);
          }
        },
      ),
    );
    projectsWidgets.add(ExpansionTile(
      title: Text("Archived"),
      children: archivedProjects,
    ));
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: ListTile.divideTiles(context: context, tiles: projectsWidgets)
          .toList(),
    );
  }
}

class ProjectsScreen extends StatefulWidget {
  final User user;

  ProjectsScreen(this.user);

  @override
  ProjectsScreenState createState() => ProjectsScreenState();
}
