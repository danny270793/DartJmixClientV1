import 'dart:convert';

class InvalidRequest {
  final Uri uri;
  final String method;
  final Map<String, String> headers;
  final String? body;

  InvalidRequest(
      {required this.uri,
      required this.method,
      required this.headers,
      this.body});

  Map<String, dynamic> toMap() {
    return {
      'url': uri.toString(),
      'method': method,
      'headers': headers,
      'body': body
    };
  }

  @override
  String toString() => json.encode(toMap());
}

class InvalidResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final String? reasonPhrase;

  InvalidResponse(
      {required this.statusCode,
      required this.headers,
      required this.body,
      required this.reasonPhrase});

  Map<String, dynamic> toMap() {
    return {
      'statusCode': statusCode,
      'headers': headers,
      'body': body,
      'reasonPhrase': reasonPhrase
    };
  }

  @override
  String toString() => json.encode(toMap());
}

class InvalidHttpRequestException implements Exception {
  final InvalidRequest invalidRequest;
  final InvalidResponse invalidResponse;

  InvalidHttpRequestException(
      {required this.invalidRequest, required this.invalidResponse});

  Map<String, dynamic> toMap() {
    return {
      'invalidRequest': invalidRequest.toMap(),
      'invalidResponse': invalidResponse.toMap()
    };
  }

  @override
  String toString() => json.encode(toMap());
}
