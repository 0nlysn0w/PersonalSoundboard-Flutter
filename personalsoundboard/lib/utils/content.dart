import 'package:firebase_database/firebase_database.dart';

class Content {
   String key;
   String name;
   String group;
   String coverUrl;

  Content(this.name, this.group, this.coverUrl);

  Content.fromSnapshot(DataSnapshot snapshot)
        : key = snapshot.key,
          name = snapshot.value["name"],
          group = snapshot.value["group"],
          coverUrl = snapshot.value["coverUrl"];
          
  toJson() {
    return {
      "name": name,
      "group": group,
      "coverUrl": coverUrl
    };
  }

}