import 'dart:async';

import 'package:flutter/material.dart';

import '../sqflite_connection.dart';
import './content_page.dart';
import './addgroup_page.dart';
import '../utils/drawer.dart';
import '../utils/group.dart';
import '../utils/helper.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class GroupPage extends StatefulWidget {
  @override
  GroupPageState createState() => new GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  Widget body;
  List<Group> groups = new List();
  Group group;

  DatabaseReference groupRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Group> dbGroups;
  @override
  void initState() {
    super.initState();
    group = Group("");

    final FirebaseDatabase database = FirebaseDatabase.instance;
    // groupRef = database.reference().child('group');
    // groupRef.onChildAdded.listen(_onEntryAdded);
    // groupRef.onChildChanged.listen(_onEntryChanged);
    getGroups();
  }

  void getGroups() async {
    SQFLiteConnect db = new SQFLiteConnect();
    dbGroups = await db.groups();
    // return true;
    animatedListBuilder();
  }
  _onEntryAdded(Event event) async {
    getGroups();
    // setState(() {
    //   groups.add(Group.fromSnapshot(event.snapshot));
    //   groups.removeWhere((g) => !dbGroups.contains(g));
    // });
  }
    
  // _onEntryChanged(Event event) async {
  //   getGroups();
  //   var old = groups.singleWhere((entry) {
  //     return entry.key == event.snapshot.key;
  //   });
  //   setState(() {
  //     groups[groups.indexOf(old)] = Group.fromSnapshot(event.snapshot);
  //     groups.removeWhere((g) => !dbGroups.contains(g));

  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Groups"),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new AddGroupPage())).whenComplete(() => getGroups());              
            },
          ),
        ],
      ),
      body: row
      // new FirebaseAnimatedList(
      //   query: groupRef,
      //   itemBuilder: (BuildContext context, DataSnapshot snapshot, 
      //       Animation<double> animation, int index) {
      //     return new Container(
      //       margin: const EdgeInsets.only(top: 5.0),
      //       child: new Card(
      //         child: new ListTile(
      //           onTap: () {
      //             Navigator.push(context, new MaterialPageRoute(builder: (context) => new ContentPage(groups[index])));
      //           },
      //           leading: Helper().roundAvatar(groups[index].name),
      //           title: new Text(groups[index].name),
      //         )
      //       )
      //     );
      //   }
      // ),
      
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
                onTap: () {
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new ContentPage(dbGroups[index]))).whenComplete(() => getGroups());
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
}
