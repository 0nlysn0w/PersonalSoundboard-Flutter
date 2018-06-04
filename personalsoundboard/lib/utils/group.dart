import 'dart:io';

class Group {
   final String id;
   final String name;

  Group(this.id, this.name);

  Group.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'name': name,
    };
}