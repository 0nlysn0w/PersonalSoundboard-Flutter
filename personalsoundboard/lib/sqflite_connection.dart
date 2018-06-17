import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'utils/group.dart';

class SQFLiteConnect{

  SQFLiteConnect();

  Future<String> connectionstring() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "sounds.db");
    return path;
  }

  Future<String> connectionstringGroup() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "groups.db");
    return path;
  }

  Future<String> insertIntoTable(String id, String audioPath) async {
    Database _db = await openDatabase(await connectionstring(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateDb
        );
      }
    );

    Map<String, dynamic> maps = new Map<String, dynamic>();

    maps["id"] = generateId();
    maps["sound"] = audioPath;
    _db.insert("DBLSounds", maps);
    return maps["id"];
  }

  Future<List<Map<String, dynamic>>> getSounds() async {
    Database _db = await openDatabase(await connectionstring(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateDb
        );
      }
    );
    var result = await _db.query("DBLSounds");

    return result;
  }

  Future<bool> insertTitleAndImage(String id, String title, [String path]) async {
    Database _db = await openDatabase(await connectionstring(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateDb
        );
      }
    );
    Map<String, dynamic> maps = new Map<String, dynamic>();
    maps["title"] = title;  
    if (path != null) {
      maps["image"] = path;
    }  
    _db.update("DBLSounds", maps, where: "id == '" + id + "'");

    return true;
  }

  static String generateId() {
    int length = 10;
    Random random = new Random();
      String characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      String result = "";
      for (int i = 0; i < length; i++)
      {
          result = result + characters[random.nextInt(characters.length)];
      }
      return result;
  }

  Future<bool> deleteSound(String id) async {
    Database _db = await openDatabase(await connectionstring(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateDb,
          
        );
      }
    );
    _db.delete("DBLSounds", where: "id == + '" + id + "'");

    return true;
  }

  Future<Map<String, dynamic>> getSound(String id) async {
    Database _db = await openDatabase(await connectionstring(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateDb
        );
      }
    );
    var m = await _db.query("DBLSounds", where: "id == '" + id + "'");
    return m.first;
  }

  Future<bool> addGroup(Group group) async{
    Database _db = await openDatabase(await connectionstringGroup(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateGroup
        );
      }
    );

    Map<String, dynamic> values = new Map<String, dynamic>();
    values["id"] = group.key;
    values["name"] = group.name;
    _db.insert("DBLGroups", values);

    return true;
  }

  Future<List<Group>> groups() async{
    Database _db = await openDatabase(await connectionstringGroup(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateGroup
        );
      }
    );

    var m = await _db.query("DBLGroups");
    var groups = new List<Group>();
    for (var item in m) {
      Group group = new Group(item["name"]);
      group.key = item["id"];
      groups.add(group);
    }

    return groups;
  }

  Future<bool> groupExists(String id) async {
    Database _db = await openDatabase(await connectionstringGroup(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateGroup
        );
      }
    );

    var m = await _db.query("DBLGroups", where: "id == '" + id + "'");
    return m.length != 0;
  }

  Future<bool> deleteGroup(String id) async {
    Database _db = await openDatabase(await connectionstringGroup(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateGroup
        );
      }
    );
    var m = await _db.delete("DBLGroups", where: "id == '" + id + "'");

    return true;
  }
  
  get onCreateDb {
    return "CREATE TABLE DBLSounds (id VARCHAR PRIMARY KEY, title TEXT, image TEXT, sound TEXT);";
  }

  get onCreateGroup {
    return "CREATE TABLE DBLGroups (id VARCHAR PRIMARY KEY, name TEXT); ";
  }
}