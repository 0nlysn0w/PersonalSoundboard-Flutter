import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './content_page.dart';
import './addgroup_page.dart';
import '../utils/drawer.dart';
import '../utils/group.dart';

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

  Future<String> getGroups() async {
    http.Response response = await http.get(
      Uri.encodeFull("http://jooststam.com/soundboard/api.php/groups"),
      headers: {
        "Accept": "application/json"
      }
    );

    this.setState(() {
      groups = new List<Group>();
      List groupsJson = JSON.decode(response.body);

      for (var json in groupsJson) {
        var group = new Group(json["name"]);
        groups.add(group); 
      }
    });

    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    group = Group("");

    final FirebaseDatabase database = FirebaseDatabase.instance;
    groupRef = database.reference().child('group');
    groupRef.onChildAdded.listen(_onEntryAdded);
    groupRef.onChildChanged.listen(_onEntryChanged);
  }

    _onEntryAdded(Event event) {
    setState(() {
      groups.add(Group.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = groups.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      groups[groups.indexOf(old)] = Group.fromSnapshot(event.snapshot);
    });
  }

  String _id;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Groups"),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new AddGroupPage()));              
            },
          ),
        ],
      ),
      body: new FirebaseAnimatedList(
        query: groupRef,
        itemBuilder: (BuildContext context, DataSnapshot snapshot, 
            Animation<double> animation, int index) {
          return new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Card(
              child: new ListTile(
                // onTap: () {
                //   setState(() {
                //       _id = groups[index].id;
                //   });
                //   Navigator.push(context, new MaterialPageRoute(builder: (context) => new ContentPage(groups[index])));
                // },
                leading: avatar(groups[index].name),
                title: new Text(groups[index].name),
              )
            )
          );
        }
      ),
      drawer: new TestDrawer(),
    );
  }

  CircleAvatar avatar(String groupName) {
    return new CircleAvatar(
      backgroundColor: Colors.redAccent,
      child: new Text(groupName[0]),
    );
  }
}