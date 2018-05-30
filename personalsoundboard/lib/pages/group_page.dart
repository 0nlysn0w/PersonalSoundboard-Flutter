import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroupPage extends StatefulWidget {
  @override
  GroupPageState createState() => new GroupPageState();
}

class GroupPageState extends State<GroupPage> {

  List data;

  Future<String> getData() async {
    http.Response response = await http.get(
      Uri.encodeFull("http://jooststam.com/soundboard/api.php/groups"),
      headers: {
        "Accept": "application/json"
      }
    );

    this.setState(() {
      data = JSON.decode(response.body);
    });
    print(data[1]["name"]);
  }

  @override
  void initState() {
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Groups"),
      ),
      body: new ListView.builder(
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (BuildContext context, int index) {
          return new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Card(
              child: new ListTile(
                leading: avatar(data[index]["name"]),
                title: new Text(data[index]["name"]),
              )
            )
          );
        }
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => debugPrint("Add"),
        child: new Icon(Icons.add_circle),
      ),
    );
  }

    CircleAvatar avatar(String groupName) {
    return new CircleAvatar(
      backgroundColor: Colors.redAccent,
      child: new Text(groupName[0]),
    );
  }
}