import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../sqflite_connection.dart';
import './content_page.dart';
import './addgroup_page.dart';
import '../utils/group.dart';
import '../utils/helper.dart';
import '../utils/drawer.dart';

import 'package:firebase_database/firebase_database.dart';

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

    getGroups();
  }

  void getGroups() async {
    SQFLiteConnect db = new SQFLiteConnect();
    dbGroups = await db.groups();
    // return true;
    animatedListBuilder();
  }


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
      body: row,
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
      drawer: new TestDrawer(),
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
                onLongPress: () {
                  _dialogOptions(dbGroups[index].key, dbGroups[index].name);
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

    Future<Null> _dialogOptions(String id, String name) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          contentPadding: new EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
          title: const Text('What would you like to do with this group?', textAlign: TextAlign.center,),
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
            children: <Widget>[
            new Container(
              padding: const EdgeInsets.fromLTRB(1.0, 0.0, 0.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  deleteGroup(id);
                },
                child: const Icon(Icons.delete, size: 80.0, color: Colors.black54,),
              ),
            ),
            new Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 1.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  share(id, name);
                },
                child: const Icon(Icons.reply, size: 80.0, color: Colors.green,),
              ),
              )],
            )
          ],
        );
      }
    );
    setState(() { });

  }
  void share(String id, String name) {
    Share.share("Join the $name soundboard! http://www.personalsoundboard.com/groups?key=$id&name=$name");
  }
  void deleteGroup(String id) async {
    SQFLiteConnect db = new SQFLiteConnect();
    var m = await db.deleteGroup(id);
    if (m) {
      getGroups();
      Navigator.pop(context);
    }
  }
}
