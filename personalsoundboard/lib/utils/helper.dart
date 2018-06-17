import 'dart:math';
import 'dart:core';
import 'package:flutter/material.dart';

class Helper {
  int length = 10;

  String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  String base62() {
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < length; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }

  CircleAvatar roundAvatar(String content) {
    return new CircleAvatar(
      backgroundColor: Colors.redAccent,
      child: new Text(content[0]),
    );
  }


}