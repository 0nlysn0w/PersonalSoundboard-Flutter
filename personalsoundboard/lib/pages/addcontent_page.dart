import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import '../utils/base62.dart' as randoms;


class AddContentPage extends StatefulWidget {
  AddContentPage(this.id);
  final String id;

  @override
  AddContentPageState createState() => new AddContentPageState(id);
}

class AddContentPageState extends State<AddContentPage> {
  AddContentPageState(this.id);
  final String id;
  File _image;

  final myController = new TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myController.dispose();
    super.dispose();
  }

  postContent(String name) {
    // var client = new http.Client();

    // client.post(
    //   "http://jooststam.com/soundboard/api.php/content",
    //   body: {
    //     "id": "56gh",
    //     "name": name,
    //     "group_id": "fadgarg",
    //     "type_id": "fgaf"
    //   }
    // ).whenComplete(client.close);
    print("=>" + _random);
  }
  

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(id),
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
            leading: const Icon(Icons.description),
            title: new TextField(
              controller: myController,
              decoration: new InputDecoration(
                hintText: "ContentName",
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
        onPressed: () => postContent(myController.text),
        child: new Icon(Icons.check_circle),
      )
    );
  }
}
