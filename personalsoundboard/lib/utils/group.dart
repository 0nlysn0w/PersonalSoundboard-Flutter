import 'package:firebase_database/firebase_database.dart';

class Group {
   String key;
   String name;
   String cover;

  Group(this.name, this.cover);

  Group.fromSnapshot(DataSnapshot snapshot)
        : key = snapshot.key,
          name = snapshot.value["name"],
          cover = snapshot.value["cover"];          
          
  toJson() {
    return {
      "name": name,
      "cover": cover,
    };
  }
}