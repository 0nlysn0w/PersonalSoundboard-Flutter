import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../utils/helper.dart';

import 'dart:math';


class AddGroupPage extends StatefulWidget {
  @override
  AddGroupPageState createState() => new AddGroupPageState();
}

class AddGroupPageState extends State<AddGroupPage> {

  postGroup(String name) {
    var base62 = new Helper().base62();

    var client = new http.Client();
    client.post(
      "http://jooststam.com/soundboard/api.php/groups",
      body: {
        "id": base62,
        "name": name
      }
    ).whenComplete(client.close);
  }

  final groupNameInputField = new TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    groupNameInputField.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Add a group"),
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
            leading: const Icon(Icons.description),
            title: new TextField(
              controller: groupNameInputField,
              decoration: new InputDecoration(
                hintText: "GroupName",
              ),
            ),
          ),
          // new Card(
            
          //   child: _image == null
          //   ? new RaisedButton(
          //     onPressed: getImage,
          //     child: new Icon(Icons.add))
          //   : new Image.file(_image)
          // )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => postGroup(groupNameInputField.text),
        child: new Icon(Icons.check_circle)
      ),
    );
  }
}
