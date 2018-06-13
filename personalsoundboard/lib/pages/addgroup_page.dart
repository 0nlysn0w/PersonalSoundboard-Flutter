import 'package:flutter/material.dart';

import '../sqflite_connection.dart';
import '../utils/group.dart';
import '../utils/helper.dart';
import 'group_page.dart';

import 'package:firebase_database/firebase_database.dart';

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

  void handleSubmit() async {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      var key = Helper().base62();

      form.save();
      form.reset();
      groupRef.child(key).set(group.toJson());
      group.key = key;
      SQFLiteConnect db = new SQFLiteConnect();
      var m = await db.addGroup(group);
      if(m != null) {
                    Navigator.pop(context,
                new MaterialPageRoute(builder: (context) => new GroupPage()));
      }
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
            child: new ListTile(
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
          },
          child: new Icon(Icons.check_circle)),
    );
  }
}
