import 'package:firebase_database/firebase_database.dart';

class Content {
   String key;
   String name;
   String group;
   String soundUrl;
   String coverUrl;

  Content(this.name, this.group, this.soundUrl, this.coverUrl);

  Content.fromSnapshot(DataSnapshot snapshot)
        : key = snapshot.key,
          name = snapshot.value["name"],
          group = snapshot.value["group"],
          soundUrl = snapshot.value["soundUrl"],
          coverUrl = snapshot.value["coverUrl"];
          
  toJson() {
    return {
      "name": name,
      "group": group,
      "soundUrl": soundUrl,
      "coverUrl": coverUrl
    };
  }

}