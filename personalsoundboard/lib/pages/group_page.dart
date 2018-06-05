import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './content_page.dart';
import './addgroup_page.dart';
import '../utils/drawer.dart';
import '../utils/group.dart';

class GroupPage extends StatefulWidget {
  @override
  GroupPageState createState() => new GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  Widget body;
  List<Group> groups = new List<Group>();

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
        var group = new Group(json["id"], json["name"]);
        groups.add(group); 
      }
      setGroups();
    });

    return "Success!";
  }

  void setGroups() async {
    body = new ListView.builder(
      itemCount: groups == null ? 0 : groups.length,
      itemBuilder: (BuildContext context, int index) {
        return new Container(
          margin: const EdgeInsets.only(top: 5.0),
          child: new Card(
            child: new ListTile(
              onTap: () {
                setState(() {
                    _id = groups[index].id;
                });
                Navigator.push(context, new MaterialPageRoute(builder: (context) => new ContentPage(groups[index])));
              },
              leading: avatar(groups[index].name),
              title: new Text(groups[index].name),
            )
          )
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    this.getGroups();
  }

  String _id;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Groups"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.refresh),
            onPressed: () {
              this.getGroups();
            },
          ),
          new IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new AddGroupPage()));              
            },
          ),
        ],
      ),
      body: body,
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