import 'package:flutter/material.dart';

import '../utils/content.dart';
import './addcontent_page.dart';
import '../utils/group.dart';

import 'package:firebase_database/firebase_database.dart';

class ContentPage extends StatefulWidget {
  ContentPage(this.group);
  final Group group;

  @override
  ContentPageState createState() => new ContentPageState(group);
}

class ContentPageState extends State<ContentPage> {
  ContentPageState(this.group);
  
  Group group;
  
  List<Content> contents = new List();
  Content content;

  DatabaseReference contentRef;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();    
    final FirebaseDatabase database = FirebaseDatabase.instance;
    contentRef = database.reference().child('content');
    contentRef.equalTo(group.key);
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

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Content of " + group.name),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new AddContentPage(group)));
            },
          )
        ],
      ),
      body: new GridView.extent(
          children: _cardGridBuilder(contents.length), 
          maxCrossAxisExtent: 180.0,
        )
    );
  }

  List<Widget> _cardGridBuilder(numberOfContents) {
    List<Card> cards = new List<Card>.generate(numberOfContents, 
    (int index) {
      return new Card(
        child: new InkWell(
          child: new Text(contents[index].name),
          onTap: () => debugPrint("item pressed"),
        ),
      );
    });
    return cards;
  }
}
