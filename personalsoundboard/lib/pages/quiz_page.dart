import 'package:flutter/material.dart';
import '../utils/question.dart';
import '../utils/quiz.dart';

class QuizPage extends StatefulWidget {
  @override
  State createState() => new QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Column( // This is out main page
          children: <Widget>[
            new Expanded(
              child: 
              new Material( // True button
                color: Colors.greenAccent,
                child: new InkWell(
                  onTap: () => debugPrint("You answerd true"),
                  child: new Center(
                    child: new Container(
                      child: new Text("True"),
                    ),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}