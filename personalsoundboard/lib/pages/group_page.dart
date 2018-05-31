import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './content_page.dart';
import '../utils/drawer.dart';

class GroupPage extends StatefulWidget {
  @override
  GroupPageState createState() => new GroupPageState();
}

class GroupPageState extends State<GroupPage> {

  List groups;

  Future<String> getGroups() async {
    http.Response response = await http.get(
      Uri.encodeFull("http://jooststam.com/soundboard/api.php/groups"),
      headers: {
        "Accept": "application/json"
      }
    );

    this.setState(() {
      groups = JSON.decode(response.body);
    });
    return "Succes!";
  }

  @override
  void initState() {
    this.getGroups();
  }

  String _id;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Groups"),
      ),
      body: new ListView.builder(
        itemCount: groups == null ? 0 : groups.length,
        itemBuilder: (BuildContext context, int index) {
          return new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Card(
              child: new ListTile(
                onTap: () {
                  setState(() {
                      _id = groups[index]["id"];
                  });
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new ContentPage(groups[index]["id"])));
                  
                  final snackBar = new SnackBar(
                    content: new Text(groups[index]["id"]),
                  );

                  Scaffold.of(context).showSnackBar(snackBar);
                },
                leading: avatar(groups[index]["name"]),
                title: new Text(groups[index]["name"]),
              )
            )
          );
        }
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          //Navigator.push(context, new MaterialPageRoute(builder: (context) => new ContentPage()));
        },
        child: new Icon(Icons.add_circle),
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