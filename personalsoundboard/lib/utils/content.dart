import 'package:firebase_database/firebase_database.dart';

class Content {
   String key;
   String name;
   String group;
   String coverUrl;
   String soundUrl;

  Content(this.name, this.group, this.coverUrl, this.soundUrl);

  Content.fromSnapshot(DataSnapshot snapshot)
        : key = snapshot.key,
          name = snapshot.value["name"],
          group = snapshot.value["group"],
          coverUrl = snapshot.value["coverUrl"],
          soundUrl = snapshot.value["soundUrl"];

  Content.fromLocalDb(dynamic localData)
        : key = localData["id"],
          name = localData["title"],
          group = null,
          coverUrl = localData["image"],
          soundUrl = localData["sound"];
          
  toJson() {
    return {
      "name": name,
      "group": group,
      "coverUrl": coverUrl,
      "soundUrl": soundUrl
    };
  }

}