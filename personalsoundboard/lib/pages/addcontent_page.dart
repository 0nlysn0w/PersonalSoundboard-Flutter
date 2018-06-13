import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../utils/content.dart';
import '../utils/group.dart';
import '../utils/helper.dart';
import './content_page.dart';

import 'package:firebase_storage/firebase_storage.dart';

class AddContentPage extends StatefulWidget {
  AddContentPage(this.group);
  final Group group;

  @override
  AddContentPageState createState() => new AddContentPageState(group);
}

class AddContentPageState extends State<AddContentPage> {
  AddContentPageState(this.group);
  Group group;
  File _image;

  List<Content> contents = new List();
  Content content;

  DatabaseReference contentRef;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    content = Content("", "", "", "");

    final FirebaseDatabase database = FirebaseDatabase.instance;
    contentRef = database.reference().child('content');
    contentRef.onChildAdded.listen(_onEntryAdded);
    contentRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    setState(() {
      contents.add(Content.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = contents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      contents[contents.indexOf(old)] = Content.fromSnapshot(event.snapshot);
    });
  }

  Future handleSubmit(File image) async {
    // Create base62 key for record and filename
    String contentKey = Helper().base62();

    String fileType = image.path.split(".")[1];
    
    // final StorageReference ref = FirebaseStorage.instance.ref().child(contentKey);
    // final StorageUploadTask task = ref.putFile(image);
    // final Uri downloadUrl = (await task.future).downloadUrl;

    content.group = group.key;
    // content.type = fileType;
    // content.downloadUrl = downloadUrl.toString();

    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      contentRef.child(contentKey).set(content.toJson());
    }
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
          title: new Text(group.name),
        ),
        body: new Column(
          children: <Widget>[
            new Form(
              key: formKey,
              child: new ListTile(
                leading: const Icon(Icons.description),
                title: new TextFormField(
                  onSaved: (val) => content.name = val,
                  validator: (val) => val == "" ? val : null,
                  decoration: new InputDecoration(
                    hintText: "ContentName",
                  ),
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
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () {
            Navigator.pop(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ContentPage(group)));
            handleSubmit(_image);
          },
          child: new Icon(Icons.check_circle),
        ));
  }
}
