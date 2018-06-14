import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

import '../sqflite_connection.dart';
import './content_page.dart';
import './addgroup_page.dart';
import './addcontent_page.dart';
import '../utils/group.dart';
import '../utils/content.dart';
import '../utils/helper.dart';
import '../utils/drawer.dart';
import 'dart:async';

import 'addcontent_page.dart' as addContent;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';


class AddToGroupPage extends StatefulWidget {
  AddToGroupPage(this.pressedContent);
  final Content pressedContent;

  @override
  AddToGroupPageState createState() => new AddToGroupPageState(pressedContent);
}

class AddToGroupPageState extends State<AddToGroupPage> {
  AddToGroupPageState(this.pressedContent);
  Content pressedContent;

  Widget body;
  List<Group> groups = new List();
  Group group;
  Content content;

  String _contentKey;

  File newCover;
  File newSound;

  String _coverUrl;
  String _soundUrl;

  DatabaseReference contentRef;
  DatabaseReference groupRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Group> dbGroups;

  @override
  void initState() {
    super.initState();
    group = Group("");
    content = Content("", "", "", "");

    final FirebaseDatabase database = FirebaseDatabase.instance;
    contentRef = database.reference().child('content');

    groupRef = database.reference().child('group');
    groupRef.onChildAdded.listen(_onEntryAdded);
    groupRef.onChildChanged.listen(_onEntryChanged);

    getGroups();
  }

  void getGroups() async {
    SQFLiteConnect db = new SQFLiteConnect();
    dbGroups = await db.groups();
    // return true;
    //animatedListBuilder();
  }

  _onEntryAdded(Event event) {
    setState(() {
      // List<Group> unfilteredGroups = List();
      groups.add(Group.fromSnapshot(event.snapshot));
      // for (var dbGroup in dbGroups) {
      //   groups = unfilteredGroups.where((c) => c.key == dbGroup.key).toList();
      // }
    });
  }

  _onEntryChanged(Event event) {
    var old = groups.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      List<Group> unfilteredGroups = List();
      unfilteredGroups[groups.indexOf(old)] = Group.fromSnapshot(event.snapshot);
      for (var dbGroup in dbGroups) {
        groups = unfilteredGroups.where((c) => c.key == dbGroup.key).toList();
      }
    });
  }


  Future<Null> uploadCover(File image, _contentKey) async {
    String fileType = image.path.split(".")[1];
    final StorageReference ref = FirebaseStorage.instance.ref().child(_contentKey + "." + fileType);
    final StorageUploadTask task = ref.putFile(image);
    final Uri coverUrl = (await task.future).downloadUrl;
    _coverUrl = coverUrl.toString();

    print(_coverUrl);
  }

  Future<Null> uploadSound(File sound, _contentKey) async {
    String fileType = sound.path.split(".")[3];
    final StorageReference ref = FirebaseStorage.instance.ref().child(_contentKey + "." + fileType);
    final StorageUploadTask task = ref.putFile(sound);
    final Uri soundUrl = (await task.future).downloadUrl;
    _soundUrl = soundUrl.toString();

    print(_soundUrl);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Choose group to add to"),
      ),
      body: // row,
      new FirebaseAnimatedList(
        query: groupRef,
        itemBuilder: (BuildContext context, DataSnapshot snapshot, 
            Animation<double> animation, int index) {
          return new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Card(
              child: new ListTile(
                onTap: () async {

                  _contentKey = Helper().base62();

                  // So if it is a local content object
                  if (pressedContent.group == null) {

                    //File file = new File(pressedContent.coverUrl);
                    // var meep = await rootBundle.load(pressedContent.coverUrl);
                    // var m = await file.writeAsBytes(meep.buffer.asUint8List());

                    if (pressedContent.coverUrl != null) {
                      File newCover = new File(pressedContent.coverUrl);
                      await uploadCover(newCover, _contentKey);
                    }

                    if (pressedContent.soundUrl != null) {
                      newSound = new File(pressedContent.soundUrl);
                      await uploadSound(newSound, _contentKey);
                    }
                  }

                  print(dbGroups[index].key);

                  submitRecords(dbGroups[index].key, pressedContent);

                },
                leading: Helper().roundAvatar(groups[index].name),
                title: new Text(groups[index].name),
              )
            )
          );
        }
      ),
    );
  }
  // Widget row;
  // void animatedListBuilder() async {
  //   final GlobalKey<AnimatedListState> _listKey =
  //       new GlobalKey<AnimatedListState>();
  //   row = new AnimatedList(
  //     key: _listKey,
  //     initialItemCount: dbGroups.length,
  //     itemBuilder: (BuildContext context, int index, Animation<double> animation) {
  //         return new Container(
  //           margin: const EdgeInsets.only(top: 5.0),
  //           child: new Card(
  //             child: new ListTile(
  //               onTap: () async {
  //                 _contentKey = Helper().base62();

  //                 // So if it is a local content object
  //                 if (pressedContent.group == null) {

  //                   //File file = new File(pressedContent.coverUrl);
  //                   // var meep = await rootBundle.load(pressedContent.coverUrl);
  //                   // var m = await file.writeAsBytes(meep.buffer.asUint8List());

  //                   if (pressedContent.coverUrl != null) {
  //                     File newCover = new File(pressedContent.coverUrl);
  //                     await uploadCover(newCover, _contentKey);
  //                   }

  //                   if (pressedContent.soundUrl != null) {
  //                     newSound = new File(pressedContent.soundUrl);
  //                     await uploadSound(newSound, _contentKey);
  //                   }
  //                 }

  //                 print(dbGroups[index].key);

  //                 submitRecords(dbGroups[index].key, pressedContent);

  //               },
  //               leading: Helper().roundAvatar(dbGroups[index].name),
  //               title: new Text(dbGroups[index].name),
  //             )
  //           )
  //         );
  //     }
  //   );
  //   setState(() {     
  //   });
  // }

  void submitRecords(String groupToAddTo, Content pressedContent) {
    content.group = groupToAddTo;
    content.coverUrl = _coverUrl;
    content.soundUrl = _soundUrl;
    content.name = pressedContent.name;

    contentRef.child(_contentKey).set(content.toJson());
  }
}
