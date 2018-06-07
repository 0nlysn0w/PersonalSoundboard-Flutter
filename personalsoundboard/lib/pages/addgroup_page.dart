import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../utils/group.dart';
import '../utils/helper.dart';

import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'group_page.dart';


class AddGroupPage extends StatefulWidget {
  @override
  AddGroupPageState createState() => new AddGroupPageState();
}

class AddGroupPageState extends State<AddGroupPage> {
  List<Group> groups = new List<Group>();
  Group group;
  DatabaseReference groupRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();  

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

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      groupRef.push().set(group.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Add a group"),
      ),
      body: new Column(
        children: <Widget>[
          new Form(
            key: formKey,
            child: 
            new ListTile(
              leading: const Icon(Icons.description),
              title: new TextFormField(
                onSaved: (val) => group.name = val,
                validator: (val) => val == "" ? val : null,
                decoration: new InputDecoration(
                  hintText: "GroupName",
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          handleSubmit();
          Navigator.push(context, new MaterialPageRoute(builder: (context) => new GroupPage()));
        },
        child: new Icon(Icons.check_circle)
      ),
    );
  }
}
