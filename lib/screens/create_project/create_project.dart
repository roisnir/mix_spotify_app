import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_manager/common/project_manager/project_playlist.dart';
import 'package:spotify_manager/flutter_spotify/api/pagination.dart';
import 'package:spotify_manager/flutter_spotify/api/tracks.dart';
import 'package:spotify_manager/flutter_spotify/model/base.dart';
import 'package:spotify_manager/flutter_spotify/model/playlist.dart';
import 'package:spotify_manager/flutter_spotify/model/user.dart';
import 'package:spotify_manager/common/project_manager/project.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/common/utils.dart';
import 'package:spotify_manager/flutter_spotify/api/spotify_client.dart';
import 'form_fields.dart';

class CreateProjectState extends State<CreateProject> {
  Future<List<Playlist>> _playlists;

  @override
  void initState() {
    super.initState();
    _playlists = getPlaylists(widget.client);
  }

  Future<List<Playlist>> getPlaylists(SpotifyClient client) async {
    var playlists = await client.myPlaylists.toList();
    return playlists.where((p) => p.owner.id == widget.myDetails.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 20),
        ),
        Row(
          children: <Widget>[
            IconButton(
              iconSize: 48,
              icon: Icon(
                Icons.keyboard_arrow_down,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
        Expanded(
          child: SimpleFutureBuilder(_playlists,
              (BuildContext context, playlists) => ProjectForm(playlists, widget.client)),
        )
      ],
    ));
  }
}

class CreateProject extends StatefulWidget {
  final SpotifyClient client;
  final PrivateUser myDetails;

  CreateProject(this.client, this.myDetails, {Key key}) : super(key: key);

  @override
  CreateProjectState createState() => CreateProjectState();
}

class ProjectFormState extends State<ProjectForm> {
  List<GlobalKey<FormState>> pagesKeys;
  final controller = PageController();
  List<bool> selectedPlaylists;
  Map<int, bool> pagesState = Map<int, bool>();
  ProjectTemplate selectedTemplate;
  bool showOnlyUnsorted = false;
  double prevPage = 0;
  String projectName;

  @override
  void initState() {
    super.initState();
    pagesKeys = List.generate(3, (i) => GlobalKey<FormState>());
    selectedPlaylists = List<bool>.generate(
        widget.playlists.length, (i) => false,
        growable: false);
    pagesState[0] = true;
    controller.addListener(() {
      if (!(prevPage.isInt() && controller.page > prevPage)) {
        prevPage = controller.page;
        return;
      }
      int page = prevPage.toInt();
      if (pagesKeys[page].currentState.validate())
        pagesKeys[page].currentState.save();
      else
        controller.goToPage(page);
      prevPage = controller.page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pagesWidgets = <Widget>[pageTemplate, pagePlaylists, pageName];
    final pages = <Widget>[];
    for (int i = 0; i < pagesWidgets.length; i++)
      pages.add(Form(key: pagesKeys[i], child: pagesWidgets[i]));
    final columnWidgets = <Widget>[
      Expanded(
        child: PageView(
          onPageChanged: (pageIndex) {
            setState(() {
              for (var i in pagesState.keys) pagesState[i] = false;
              pagesState[pageIndex] = true;
            });
          },
          controller: controller,
          children: pages,
        ),
      ),
    ];
    if (curPage != pages.length - 1)
      columnWidgets.add(Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: RaisedButton(
            padding: EdgeInsets.all(12),
            color: Theme.of(context).primaryColor,
            child: Text(
              "Next",
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () => controller.nextPageSimple(),
          ),
        ),
      ));
    columnWidgets.add(getBreadCrumbs(pages.length));
    return Column(
      children: columnWidgets,
    );
  }

  int get curPage => controller.hasClients ? controller.page.round() : null;

  Widget getBreadCrumbs(pagesNum) {
    var theme = Theme.of(context);
    return Container(
        color: theme.backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Divider(
              thickness: 2.0,
              color: Colors.white70,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(
                    pagesNum,
                    (i) => ButtonTheme(
                          minWidth: 20,
                          child: FlatButton(
                            color: !pagesState.containsKey(i)
                                ? Colors.grey[300]
                                : pagesState[i]
                                    ? theme.primaryColor
                                    : theme.secondaryHeaderColor,
                            shape: CircleBorder(
                                side: pagesState.containsKey(i) && pagesState[i]
                                    ? BorderSide(color: Colors.white, width: 2)
                                    : BorderSide(width: 0)),
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              controller.goToPage(i);
                            },
                            child: Container(
                              width: 0,
                              height: 0,
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(0),
                            ),
                          ),
                        ))),
          ],
        ));
  }

  Future<Project> createSavedSongsProject() async {

    final tracksPag = await widget.client.savedTracksPagination;
    List<ProjectPlaylist> playlists = <ProjectPlaylist>[];
    final temp = widget.playlists
        .asMap()
        .entries
        .where((e) => selectedPlaylists[e.key]);
    for (var p in temp)
      playlists.add(await getProjectPlaylist(p.value, widget.client));

    return Project(projectName, tracksPag.paging.total,(){
      final pagClone = SavedTracksPagination(widget.client, PagingObject.fromPagingObject(tracksPag.paging));
        return pagClone.stream.map((t) => t.track);
        }, playlists);
  }

  Widget get pageName {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 200),
            child: TextFormField(
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Project's Name",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: (value) => projectName = value,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 200, bottom: 40),
            child: RaisedButton(
              child: Text(
                "Let's Start!",
                style: Theme.of(context).textTheme.title,
              ),

              onPressed: () async {
                pagesKeys.last.currentState.save();
                // NOTICE: maybe method should be async and await to crateSavedSongsProject?
                Navigator.pop(context, await createSavedSongsProject());
              },
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            ),
          )
        ],
      ),
    );
  }

  Widget get pagePlaylists {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Choose Playlists", style: theme.textTheme.display1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            "You will add songs to theme playlists trough the project",
            style: theme.textTheme.caption,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 30),
            color: theme.backgroundColor,
            child: PlaylistsSelection(
              playlists: widget.playlists,
              theme: Theme.of(context),
              onSaved: (v) => selectedPlaylists = v,
              validator: (v) =>
                  v.any((e) => e) ? null : "select at least one playlist",
              initialValue: selectedPlaylists,
            ),
          ),
        ),
      ],
    );
  }

  Widget get pageTemplate {
    final theme = Theme.of(context);
    final templates = widget.templates;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Choose Template", style: theme.textTheme.display1),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 20),
          child: Text(
            "What kind of project would you like to start?",
            style: theme.textTheme.caption,
          ),
        ),
        Expanded(
          child: ProjectTemplateSelection(
            theme: theme,
            templates: templates,
            validator: (int i) => i == null ? "please select template" : null,
            onChanged: (int i) {
              setState(() {
                selectedTemplate = templates[i];
              });
              controller.nextPageSimple();
            },
          ),
        ),
//        Row(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            Checkbox(
//              activeColor: theme.primaryColor,
//              value: showOnlyUnsorted,
//              onChanged: (val){setState(() {
//              showOnlyUnsorted = val;
//            });},),
//            Text("Show only unsorted tracks"),
//            Tooltip(child: Icon(Icons.info), message: "songs that included in one of your playlists",)
//
//          ],
//        )
      ],
    );
  }
}

class ProjectForm extends StatefulWidget {
  final SpotifyClient client;
  final List<Playlist> playlists;
  final templates = <ProjectTemplate>[
    ProjectTemplate(
        "Liked Songs",
        "Iterate over every song you have ever liked and sort thme to your playlists",
        Icons.favorite),
    ProjectTemplate(
        "Discover",
        "Choose tracks you like, get recommendations based on them and sort them to your playlists",
        Icons.explore),
    ProjectTemplate(
        "Extend",
        "Choose existing playlist, get recommendations based on tracks in the playlists and sort them to your playlists",
        Icons.all_out),
    ProjectTemplate(
        "Maintain",
        "Work on tracks that not included in any of your playlists",
        Icons.build),
  ];

  ProjectForm(this.playlists, this.client, {Key key}) : super(key: key);

  @override
  ProjectFormState createState() => ProjectFormState();
}
