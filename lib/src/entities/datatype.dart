import 'dart:convert';

class Datatype {
  final String id;
  final String name;
  final String? format;
  final String? decimalSeparator;
  final String? groupingSeparator;

  Datatype(
      {required this.id,
      required this.name,
      this.format,
      this.decimalSeparator,
      this.groupingSeparator});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'format': format,
      'decimalSeparator': decimalSeparator,
      'groupingSeparator': groupingSeparator
    };
  }

  factory Datatype.fromMap(Map<String, dynamic> json) {
    return Datatype(
        name: json['name'],
        id: json['id'],
        format: json['format'],
        decimalSeparator: json['decimalSeparator'],
        groupingSeparator: json['groupingSeparator']);
  }
}
