import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContentPage extends StatefulWidget {
  @override
  ContentPageState createState() => new ContentPageState();
}

class ContentPageState extends State<ContentPage> {

    List content;

  Future<String> getContent() async {
    http.Response response = await http.get(
      Uri.encodeFull("http://jooststam.com/soundboard/api.php/content"),
      headers: {
        "Accept": "application/json"
      }
    );

    this.setState(() {
      content = JSON.decode(response.body);
    });
    return "Succes!";
  }

  @override
  void initState() {
    this.getContent();
  }


  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Content"),
      ),
      body: new GridView.builder(
        itemCount: content == null ? 0 : content.length,
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (4 == Orientation.portrait) ? 2 : 3),
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new InkWell(
              onTap: () => debugPrint("item pressed"),
            ),
          );
        }
      )
    );
  }
}
