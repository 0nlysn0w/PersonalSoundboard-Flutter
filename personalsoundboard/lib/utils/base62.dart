import 'dart:math';

class Helper {
  String randomString(int length) {
    var rand = new Random();
    var codeUnits = new List.generate(
      length, 
      (index) {
        return rand.nextInt(33)+89;
      }
    );

    return new String.fromCharCodes(codeUnits);
  }
}