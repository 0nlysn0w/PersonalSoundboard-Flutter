import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SQFLiteConnect{

  SQFLiteConnect();
  Future<String> connectionstring() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "sounds.db");
    return path;
  }

  Future<int> insertIntoTable(String title) async {
    Database _db = await openDatabase(await connectionstring(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE DBLSounds (id INTEGER PRIMARY KEY, title TEXT, image BLOB, sound BLOB);"
        );
      }
    );
    Map<String, dynamic> maps = new Map<String, dynamic>();

    maps["title"] = title;
    final m = _db.insert("DBLSounds", maps);
    return m;
  }

  Future<List<Map<String, dynamic>>> getSounds() async {
    Database _db = await openDatabase(await connectionstring(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE DBLSounds (id INTEGER PRIMARY KEY, title TEXT, image BLOB, sound BLOB);"
        );
      }
    );
    var result = await _db.query("DBLSounds");
    return result;
  }

}