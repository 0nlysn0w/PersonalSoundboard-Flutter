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

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Group> dbGroups;

  @override
  void initState() {
    super.initState();
    group = Group("");
    content = Content("", "", "", "");

    final FirebaseDatabase database = FirebaseDatabase.instance;
    contentRef = database.reference().child('content');
    getGroups();
  }

  void getGroups() async {
    SQFLiteConnect db = new SQFLiteConnect();
    dbGroups = await db.groups();
    // return true;
    animatedListBuilder();
  }

  Future<Null> uploadCover(File image, _contentKey) async {
    final StorageReference ref = FirebaseStorage.instance.ref().child(_contentKey);
    final StorageUploadTask task = ref.putFile(image);
    final Uri coverUrl = (await task.future).downloadUrl;
    _coverUrl = coverUrl.toString();

    print(_coverUrl);
  }

  Future<Null> uploadSound(File sound, _contentKey) async {
    final StorageReference ref = FirebaseStorage.instance.ref().child(_contentKey);
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
      body: row,
    );
  }
  Widget row;
  void animatedListBuilder() async {
    final GlobalKey<AnimatedListState> _listKey =
        new GlobalKey<AnimatedListState>();
    row = new AnimatedList(
      key: _listKey,
      initialItemCount: dbGroups.length,
      itemBuilder: (BuildContext context, int index, Animation<double> animation) {
          return new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Card(
              child: new ListTile(
                onTap: () async {
                  _contentKey = Helper().base62();
                  // File file = new File(pressedContent.coverUrl);
                  // var meep = await rootBundle.load(pressedContent.coverUrl);
                  // var m = await file.writeAsBytes(meep.buffer.asUint8List());

                  // if (pressedContent.coverUrl != null) {
                  //   File newCover = new File(pressedContent.coverUrl);
                  //   await uploadCover(newCover, _contentKey);
                  // }

                  // if (pressedContent.soundUrl != null) {
                  //   newSound = new File(pressedContent.coverUrl);
                  //   await uploadSound(newSound, _contentKey);
                  // }

                  print(dbGroups[index].key);

                  submitRecords(dbGroups[index].key, pressedContent);

                },
                leading: Helper().roundAvatar(dbGroups[index].name),
                title: new Text(dbGroups[index].name),
              )
            )
          );
      }
    );
    setState(() {     
    });
  }

  void submitRecords(String groupToAddTo, Content pressedContent) {
    content.group = groupToAddTo;
    content.coverUrl = pressedContent.coverUrl;
    content.soundUrl = pressedContent.soundUrl;
    content.name = pressedContent.name;

    contentRef.child(_contentKey).set(content.toJson());
  }
}
