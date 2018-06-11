import 'package:firebase_database/firebase_database.dart';
import 'helper.dart';

class Content {
   String key;
   String name;
   String group;
   String type;

  Content(this.name, this.group, this.type);

  Content.fromSnapshot(DataSnapshot snapshot)
        : key = snapshot.key,
          name = snapshot.value["name"],
          group = snapshot.value["group"],
          type = snapshot.value["type"];
          
  toJson(String group) {
    return {
      "name": name,
      "group": group,
      "type": type
    };
  }

}