import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/content.dart';
import './addcontent_page.dart';
import '../utils/group.dart';

class ContentPage extends StatefulWidget {
  ContentPage(this.group);
  final Group group;

  @override
  ContentPageState createState() => new ContentPageState(group);
}

class ContentPageState extends State<ContentPage> {
  ContentPageState(this.group);
  final Group group;
  List<Content> contents = new List<Content>();
  Widget body;

  Future<String> getContent() async {
    http.Response response = await http.get(
      Uri.encodeFull("http://jooststam.com/soundboard/api.php/content?group_id="),
      headers: {
        "Accept": "application/json"
      }

    );

    this.setState(() {
      contents = new List<Content>();
      List contentJson = JSON.decode(response.body);

      for (var json in contentJson) {
        var content = new Content(json["id"], json["name"], json["group_id"], json["type_id"]);
        contents.add(content); 
      }
      setContent();
    });

    return "Succes!";
  }

  void setContent() async {
    body = new GridView.builder(
        itemCount: contents == null ? 0 : contents.length,
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (4 == Orientation.portrait) ? 2 : 3),
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new InkWell(
              child: new Text(contents[index].name),
              onTap: () => debugPrint("item pressed"),
            ),
          );
        }
      );
  }

  @override
  void initState() {
    super.initState();    
    this.getContent();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Content of " + group.name),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.refresh),
            onPressed: () {
              this.getContent();
            },
          ),
          new IconButton(
            icon: new Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new AddContentPage(group)));
            },
          )
        ],
      ),
      body: body
      // new GridView.builder(
      //   itemCount: contents == null ? 0 : contents.length,
      //   gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (4 == Orientation.portrait) ? 2 : 3),
      //   itemBuilder: (BuildContext context, int index) {
      //     return new Card(
      //       child: new InkWell(
      //         child: new Text(contents[index].name),
      //         onTap: () => debugPrint("item pressed"),
      //       ),
      //     );
      //   }
      // )
    );
  }
}
