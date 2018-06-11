import 'package:firebase_database/firebase_database.dart';

class Content {
   String key;
   String name;
   String group;
   String type;
   String cover;

  Content(this.name, this.group, this.type, this.cover);

  Content.fromSnapshot(DataSnapshot snapshot)
        : key = snapshot.key,
          name = snapshot.value["name"],
          group = snapshot.value["group"],
          type = snapshot.value["type"],
          cover = snapshot.value["cover"];
          
  toJson(String group) {
    return {
      "name": name,
      "group": group,
      "type": type,
      "cover": cover
    };
  }

}