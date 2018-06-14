import 'package:firebase_database/firebase_database.dart';

class Group {
   String key;
   String name;
   String image;

  Group(this.name);

  Group.fromSnapshot(DataSnapshot snapshot)
        : key = snapshot.key,
          name = snapshot.value["name"];    

  Group.fromLocalDb(dynamic localData)
        : key = localData["id"],
          name = localData["title"];     
          
  toJson() {
    return {
      "name": name,
    };
  }
}