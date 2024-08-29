import 'dart:convert';

class InvalidHttpResponseException implements Exception {
  Type type;
  InvalidHttpResponseException({required this.type});

  Map<String, dynamic> toMap() {
    return {'type': type};
  }

  @override
  String toString() => json.encode(toMap());
}
