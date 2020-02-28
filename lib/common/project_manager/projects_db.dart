import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:sqflite/sqflite.dart';


class ProjectsDB {
  static const dbName = "projects_db.sql";
  static const projectsTable = "projects";
  static const tracksTable = "tracks";
  Future<Database> _db;

  ProjectsDB(){
    _db = () async {
//        await deleteDatabase(dbName);
        return await openDatabase(dbName, version: 1, onCreate: (db, v){
          print("creating DB...");
          db.execute('CREATE TABLE $projectsTable('
              'uuid TEXT PRIMARY KEY,'
              'name TEXT,'
              'curIndex INTEGER,'
              'playlistIds Text,' // TODO: open an issue of , bug
              'isActive INTEGER'
              ')');
          db.execute('CREATE TABLE $tracksTable('
              'trackId TEXT,'
              'projectUuid TEXT'
              ')');
        });
  }();
  }

  Future<void> insertProject(ProjectConfiguration project) async {
    final batch = (await _db).batch();
    final projectJson = project.toJson();
    List<String> trackIds = projectJson.remove('trackIds');
    batch.insert(projectsTable, projectJson);
    for (var trackId in trackIds)
      batch.insert(tracksTable, {
        'trackId': trackId,
        'projectUuid': project.uuid
      });
    await batch.commit(noResult: true);
    print("inserted new project: ${project.name}");
    print(await (await _db).query(projectsTable));
  }

  Future<void> updateIndex(String projectUuid, int index) async {
    await (await _db).update(projectsTable, {'curIndex': index}, where: "uuid = ?", whereArgs: [projectUuid]);
  }

  removeProject(String projectUuid) async {
    final batch = (await _db).batch();
    batch.delete(projectsTable, where:'uuid = ?', whereArgs: [projectUuid]);
    batch.delete(tracksTable, where:'projectUuid = ?', whereArgs: [projectUuid]);
    await batch.commit();
  }

  Future<List<ProjectConfiguration>> getProjectsConf() async {
    final db = (await _db);
    final futures = (await db.query(projectsTable)).map(
        (projectJson) async {
          final uuid = projectJson['uuid'];
          final tracks = (await db.query(
              tracksTable,
              where: 'projectUuid = ?',
              whereArgs: [uuid],
              columns: ['trackId'])).map<String>((tJson)=>tJson['trackId']).toList();
          return ProjectConfiguration.fromJson(projectJson, tracks);
        }
    );
    return Future.wait(futures);
  }

  close() async {
    (await _db).close();
  }
}