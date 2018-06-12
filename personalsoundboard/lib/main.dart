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
    gridviewthing();
    SimplePermissions.requestPermission(Permission.RecordAudio);
  }
  
  Widget row;
  

  //Dialog
  Future<Null> _soundOptions(String id) async {
    await showDialog<Department>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          contentPadding: new EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
          title: const Text('What would you like to do with this sound?', textAlign: TextAlign.center,),
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
            children: <Widget>[
            new Container(
              padding: const EdgeInsets.fromLTRB(1.0, 0.0, 0.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  deleteSounds(id);
                  Navigator.pop(context);
                },
                child: const Icon(Icons.delete, size: 80.0, color: Colors.black54,),
              ),
            ),
            new Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 1.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {

                },
                child: const Icon(Icons.reply, size: 80.0, color: Colors.green,),
              ),
              )],
            )
          ],
        );
      }
    );
    setState(() { });

  }

  void gridviewthing() async {
    SQFLiteConnect _db = new SQFLiteConnect();
    List<Map<String, dynamic>> sounds = await _db.getSounds();
    List<Widget> images = new List<Widget>();
    for (var item in sounds) {
      String path = item["image"];
      if (item["image"] == null) {
        images.add(new Icon(Icons.play_arrow));
      } else {
        final file = new File(path);
        images.add(new Image.file(file));
      }
    }
    row = new GridView.builder(
      itemCount: sounds.length,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext builder, int index){
        return new Card(
          child: new GridTile(
            footer: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new DecoratedBox(
                  decoration: new BoxDecoration( 
                    color: Colors.white70,
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                child: new Text(sounds[index]["title"] == null ? '' : sounds[index]["title"], textAlign: TextAlign.center,)
                )
              ],
            ),
            child: 
            new InkResponse(
              child: images[index],
              onTap: () {
                  AudioplayerRamon.localPath(sounds[index]["sound"]);
                },
              onLongPress: () {
                _soundOptions(sounds[index]["id"]);
               // _db.deleteSound(sounds[index]["id"]);
                // gridviewthing();
              },
            ),
          ),
        );
      },
    );
    setState(() {});
  }

  void deleteSounds(String id) async {
    SQFLiteConnect db = new SQFLiteConnect();
    bool complete = await db.deleteSound(id);
    if (complete) {
      gridviewthing();
    }
  }

  void _addSounds() async {
    await Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => new AppBody()),
      ).whenComplete(() =>
        gridviewthing()
      );
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
        onPressed: _addSounds,
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
  pickerGallery() async {
    print('Picker is called');
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = img;
    });
  }
  pickerCamera() async {
    print('Picker is called');
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      image = img;
    });
  }
  

 Future<Null> picker() async {
    await showDialog<Department>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          contentPadding: new EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
            children: <Widget>[
            new Container(
              padding: const EdgeInsets.fromLTRB(1.0, 0.0, 0.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  pickerGallery();
                  Navigator.pop(context);
                },
                child: const Icon(Icons.image, size: 80.0, color: Colors.blue,),
              ),
            ),
            new Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 1.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  pickerCamera();
                  Navigator.pop(context);
                },
                child: const Icon(Icons.camera_alt, size: 80.0, color: Colors.red,),
              ),
              )],
            )
          ],
        );
      }
    );
    setState(() { });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(''),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){_insertIntoDb();},
        ),
      ),
    body: new Wrap(
      children: <Widget>[
        image == null?new Center(
          child: new Container( width: 220.0, height: 220.0,
          child: new IconButton(
              icon: new Icon(Icons.add_photo_alternate),
              iconSize: 200.0,
              color: Colors.green,
              onPressed: () {
                picker();
              },
            ),
          ),
        ):
    
      new Center( heightFactor: 1.1,
         child: new Container( width: 200.0, height: 200.0,
        child:new InkResponse(child: new Image.file(image), onTap: () {picker();},),
      
      ),
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
              _insertIntoDb();
          },
          child: new Text("Save"),
        ),
      )
    ]
    )
    );
  }

  _insertIntoDb() async {
    if(_formKey.currentState.validate()) {
      var m = await _db.insertTitleAndImage(_id,  title, image==null? null : image.path);
      if (m) {
        Navigator.pop(context, "meep 2");
      }
    }
  }
}

