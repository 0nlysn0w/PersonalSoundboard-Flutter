import 'package:firebase_database/firebase_database.dart';

class Content {
   String key;
   String name;
   String group;
   String type;
   String downloadUrl;

  Content(this.name, this.group, this.type, this.downloadUrl);

  Content.fromSnapshot(DataSnapshot snapshot)
        : key = snapshot.key,
          name = snapshot.value["name"],
          group = snapshot.value["group"],
          type = snapshot.value["type"],
          downloadUrl = snapshot.value["downloadUrl"];
          
  toJson() {
    return {
      "name": name,
      "group": group,
      "type": type,
      "downloadUrl": downloadUrl
    };
  }

}