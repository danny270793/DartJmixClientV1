import 'dart:convert';

import 'package:http/http.dart' as http;

class InvalidRefreshToken implements Exception {
  InvalidRefreshToken({required String message});
}

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

class HttpClient {
  String parseBody({required Map<String, String> headers, required body}) {
    if (headers.containsKey('Content-Type')) {
      if (headers['Content-Type'] == 'application/x-www-form-urlencoded') {
        return Uri(queryParameters: body).query;
      } else if (headers['Content-Type'] == 'application/json') {
        return json.encode(body);
      } else {
        return json.encode(body);
      }
    } else {
      return json.encode(body);
    }
  }

  Future<String> post(
      {required String url,
      required Map<String, String> headers,
      Map<String, dynamic>? query,
      required Map<String, dynamic> body}) async {
    final String bodyParsed = parseBody(headers: headers, body: body);

    final String queryParsed =
        query != null ? Uri(queryParameters: query).query : '';
    final Uri uri = Uri.parse("$url?$queryParsed");

    final http.Response response =
        await http.post(uri, headers: headers, body: bodyParsed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw InvalidHttpRequestException(
        invalidRequest: InvalidRequest(
            uri: uri, method: 'POST', headers: headers, body: bodyParsed),
        invalidResponse: InvalidResponse(
            statusCode: response.statusCode,
            body: response.body,
            headers: response.headers,
            reasonPhrase: response.reasonPhrase));
  }

  Future<String> put(
      {required String url,
      required Map<String, String> headers,
      Map<String, dynamic>? query,
      required Map<String, dynamic> body}) async {
    final String bodyParsed = parseBody(headers: headers, body: body);
    final String queryParsed =
        query != null ? Uri(queryParameters: query).query : '';
    final Uri uri = Uri.parse("$url?$queryParsed");

    http.Response response =
        await http.put(uri, headers: headers, body: bodyParsed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw InvalidHttpRequestException(
        invalidRequest: InvalidRequest(
            uri: uri, method: 'PUT', headers: headers, body: bodyParsed),
        invalidResponse: InvalidResponse(
            statusCode: response.statusCode,
            body: response.body,
            headers: response.headers,
            reasonPhrase: response.reasonPhrase));
  }

  Future<String> get(
      {required String url,
      required Map<String, String> headers,
      Map<String, dynamic>? query}) async {
    final String queryParsed =
        query != null ? Uri(queryParameters: query).query : '';
    final Uri uri = Uri.parse("$url?$queryParsed");

    http.Response response = await http.get(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw InvalidHttpRequestException(
        invalidRequest:
            InvalidRequest(uri: uri, method: 'GET', headers: headers),
        invalidResponse: InvalidResponse(
            statusCode: response.statusCode,
            body: response.body,
            headers: response.headers,
            reasonPhrase: response.reasonPhrase));
  }

  Future<String> delete(
      {required String url,
      required Map<String, String> headers,
      Map<String, dynamic>? query}) async {
    final String queryParsed =
        query != null ? Uri(queryParameters: query).query : '';
    final Uri uri = Uri.parse("$url?$queryParsed");

    http.Response response = await http.delete(uri, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body;
    }

    throw InvalidHttpRequestException(
        invalidRequest:
            InvalidRequest(uri: uri, method: 'DELETE', headers: headers),
        invalidResponse: InvalidResponse(
            statusCode: response.statusCode,
            body: response.body,
            headers: response.headers,
            reasonPhrase: response.reasonPhrase));
  }
}
