import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SQFLiteConnect{

  SQFLiteConnect() {
    // connectDatabase();
  }

  // void connectDatabase() async {
  //   _db = await openDatabase(await connectionstring(), version: 1,
  //     onCreate: (Database db, int version) async {
  //       await db.execute(
  //         onCreateDb
  //       );
  //     }
  //   );
  //   deletedatabase();    
  // }

  void deletedatabase() async {
    Database _db = await openDatabase(await connectionstring(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateDb
        );
      }
    );
    _db.execute("DROP TABLE DBLSounds; " + onCreateDb);
  }

  Future<String> connectionstring() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "sounds.db");
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

  void deleteSound(String id) async {
    Database _db = await openDatabase(await connectionstring(), version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          onCreateDb
        );
      }
    );
    _db.delete("DBLSounds", where: "id == + '" + id + "'");
  }
  get onCreateDb {
    return "CREATE TABLE DBLSounds (id VARCHAR PRIMARY KEY, title TEXT, image TEXT, sound TEXT);";
  }
}