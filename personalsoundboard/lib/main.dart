import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'audioplayer.dart';
import 'audiorecord.dart';
import 'sqflite_connection.dart';

import 'package:simple_permissions/simple_permissions.dart';
import 'package:image_picker/image_picker.dart';


enum PlayerState { stopped, playing, paused }
enum Department { title, image, audio }

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'PersonalSoundboard',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'PersonalSoundboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    AudioplayerRamon.initAudioPlayer();
    // buttonsRows();
    gridviewthing();
    SimplePermissions.requestPermission(Permission.RecordAudio);
  }
  
  Widget row;
  

  //Dialog
  Future<Null> _addTitle() async {
    final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
    var db = new SQFLiteConnect();
    String title = "";
    switch (
      await showDialog<Department>(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: const Text('Upload audio fragment'),
            children: <Widget>[
              new Form(
                key: _formKey,
                child:
                new TextFormField(
                  decoration: new InputDecoration(
                    hintText: 'Title'
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the title';
                    }
                    else {
                      title = value;
                    }
                  },
                )
                ,
              ),
              new SimpleDialogOption(
                onPressed: () { if (_formKey.currentState.validate()) {
                  Navigator.pop(context, Department.title);
                  }
                },
                child: const Text('Next'),
              ),
            ],
          );
        }
      )
    ) {
      case Department.title:

      setState(() { });
      break;
    }
  }

  void gridviewthing() async {
    SQFLiteConnect _db = new SQFLiteConnect();
    List<Map<String, dynamic>> sounds = await _db.getSounds();
    row = new GridView.builder(
      itemCount: sounds.length,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext builder, int index){
        return new Card(
          child: new GridTile(
            child: 
            new InkResponse(
              child:new Text(sounds[index]["title"] == null ?"text": sounds[index]["title"]),
              onTap: () {
                  AudioplayerRamon.localPath(sounds[index]["sound"]);
                },
              onLongPress: () {
                _db.deleteSound(sounds[index]["id"]);
              },
            ),
          ),
        );
      },
    );
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: row,
      
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              new MaterialPageRoute(builder: (context) => new AppBody()),
            ).then((val)=>gridviewthing());
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add_box),
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }
}

class PictureAndTitleScreenBody extends StatefulWidget{
  String _id;
  PictureAndTitleScreenBody(String id) {
    _id = id;
  }
  @override
  State<StatefulWidget> createState() => new PictureAndTitleScreen(_id);
}


class PictureAndTitleScreen extends State<PictureAndTitleScreenBody> {
  File image;
  String _id = "";
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String title;
  SQFLiteConnect _db = new SQFLiteConnect();
  PictureAndTitleScreen(String id) {
    _id = id;
  }
  picker() async {
    print('Picker is called');
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(img.path);
    setState(() {
      image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(''),
      ),
    body: new Wrap(
      children: <Widget>[
        image == null?new Center(
          child: new IconButton(
              icon: new Icon(Icons.add_photo_alternate),
              iconSize: 300.0,
              color: Colors.green,
              onPressed: () {
                picker();
              },
            ),
        ):
    
      new Center(
        child:new InkResponse(child: new Image.file(image), onTap: () {picker();},),
      
      ),

      new Center(
        child: new Form(
          key: _formKey,
          child:
            new TextFormField(
            textAlign: TextAlign.center,
            autofocus: false,
            maxLength: 30,
            autocorrect: false,
            decoration: new InputDecoration(
              hintText: 'Enter title here',
              border:  new OutlineInputBorder(
              )
            ),
            validator: (value) {
              print(value);
              if (value.isEmpty) {
                return 'Please enter the title';
              }
              else {
                title = value;
              }
            },
          ),
        ),
      
      ),
      new Center(
        child: new RaisedButton(
          onPressed: () {
            if(_formKey.currentState.validate()) {
              _db.insertTitleAndImage(_id,  title, image==null? null : image.path);
              Navigator.pop(context);
            }
          },
          child: new Text("Save"),
        ),
      )
    ]
    )
    );
  }
}