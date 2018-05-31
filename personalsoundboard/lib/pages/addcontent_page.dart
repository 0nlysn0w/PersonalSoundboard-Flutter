import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

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
              decoration: new InputDecoration(
                hintText: "ContentName",
              ),
            ),
          ),
          new Card(
            
            child: _image == null
            ? new RaisedButton(
              onPressed: getImage,
              child: new Icon(Icons.add))
            : new Image.file(_image)
          )
        ],
      )
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       appBar: new AppBar(
//         title: new Text(id),
//       ),
//       body: new Center(
//         child: _image == null
//           ? new RaisedButton(
//             onPressed: getImage,
//             child: new Icon(Icons.add))
//           : new Image.file(_image),
//       ),
//     );
//   }
// }