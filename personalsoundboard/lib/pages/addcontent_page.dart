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
  File _sound;
  String _contentKey;
  String _coverUrl;
  String _soundUrl;
  final contentNameController = new TextEditingController();

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

  Future<Null> uploadCover(File image) async {
    final StorageReference ref = FirebaseStorage.instance.ref().child(_contentKey);
    final StorageUploadTask task = ref.putFile(image);
    final Uri coverUrl = (await task.future).downloadUrl;
    _coverUrl = coverUrl.toString();

    print(_coverUrl);
  }

  // Future<Null> uploadSound(File sound, [_contentKey, name]) async {
  //   final StorageReference ref = FirebaseStorage.instance.ref().child(_contentKey);
  //   final StorageUploadTask task = ref.putFile(sound);
  //   final Uri soundUrl = (await task.future).downloadUrl;
  //   _soundUrl = soundUrl.toString();

  //   print(_soundUrl);
  // }

  void submitRecords(File image, File sound) {
    content.group = group.key;
    content.coverUrl = _coverUrl;
    content.name = contentNameController.text;

    contentRef.child(_contentKey).set(content.toJson());
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
                  controller: contentNameController,
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
                        onPressed: getImage, child: new Icon(Icons.add))
                    : new Image.file(_image))
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () async {
            Navigator.pop(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ContentPage(group)));
            // Create base62 key for record and filename
            _contentKey = Helper().base62();

            if (_image != null) {
              await uploadCover(_image);
            }

            submitRecords(_image,_sound);
          },
          child: new Icon(Icons.check_circle),
        ));
  }
}
