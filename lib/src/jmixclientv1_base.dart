import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:jmixclientv1/src/entities/datatype.dart';
import 'package:jmixclientv1/src/entities/entity.dart';
import 'package:jmixclientv1/src/entities/entity_metadata.dart';
import 'package:jmixclientv1/src/entities/enum_metadata.dart';
import 'package:jmixclientv1/src/entities/premission.dart';
import 'package:jmixclientv1/src/entities/query.dart';
import 'package:jmixclientv1/src/entities/service.dart';
import 'package:jmixclientv1/src/entities/session.dart';
import 'package:jmixclientv1/src/entities/user_info.dart';
import 'package:jmixclientv1/src/entities/wheres.dart';
import 'package:jmixclientv1/src/exceptions/invalid_http_request_exception.dart';
import 'package:jmixclientv1/src/exceptions/invalid_http_response_exception.dart';
import 'package:jmixclientv1/src/exceptions/invalid_refresh_token.dart';
import 'package:jmixclientv1/src/http_client.dart';

class JmixClient {
  final HttpClient httpClient = HttpClient();

  final String protocol;
  final String hostname;
  final int port;
  final String clientId;
  final String clientSecret;

  late String basicAuthorization;
  late String url;
  late Session session;

  JmixClient({
    required this.protocol,
    required this.hostname,
    required this.port,
    required this.clientId,
    required this.clientSecret,
  }) {
    final String authorizationClean = '$clientId:$clientSecret';
    final List<int> authorizationEncoded = utf8.encode(authorizationClean);
    final String authorizationBase64 = base64.encode(authorizationEncoded);
    basicAuthorization = 'Basic $authorizationBase64';
    url = '$protocol://$hostname:$port';
  }

  void setAccessToken(
      {required String accessToken,
      required String tokenType,
      required String refreshToken,
      required int expiresIn,
      required String scope,
      required String sessionId}) {
    session = Session(
        accessToken: accessToken,
        tokenType: tokenType,
        refreshToken: refreshToken,
        expiresIn: expiresIn,
        scope: scope,
        sessionId: sessionId);
  }

  Future<dynamic> refreshTokenAndRetry(
      {required InvalidHttpRequestException error,
      required Function callback}) async {
    if (error.invalidResponse.body == '') {
      throw error;
    }

    final Map<String, dynamic> errorAsJson =
        json.decode(error.invalidResponse.body);
    final String errorType = errorAsJson['error'] ?? '';
    if (errorType == 'invalid_grant') {
      throw InvalidRefreshToken(message: error.invalidResponse.body);
    }

    if (errorType.contains('invalid_token')) {
      session = await refreshAccessToken(
          refreshToken: session.refreshToken,
          parseCallback: (map) => Session.fromMap(map));
      return await callback();
    }

    throw error;
  }

  //OAUTH

  Future<T> getAccessToken<T>(
      {required String username,
      required String password,
      required T Function(Map<String, dynamic> map) parseCallback}) async {
    final String response =
        await httpClient.post(url: '$url/oauth/token', headers: {
      'Authorization': basicAuthorization,
      'Content-Type': 'application/x-www-form-urlencoded'
    }, body: {
      'grant_type': 'password',
      'username': username,
      'password': password
    });

    final dynamic jsonDecoded = json.decode(response);

    session = Session.fromMap(jsonDecoded);

    return parseCallback(jsonDecoded);
  }

  Future<T> refreshAccessToken<T>(
      {required String refreshToken,
      required T Function(Map<String, dynamic> map) parseCallback}) async {
    final String response =
        await httpClient.post(url: '$url/oauth/token', headers: {
      'Authorization': basicAuthorization,
      'Content-Type': 'application/x-www-form-urlencoded'
    }, body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken
    });

    return parseCallback(json.decode(response));
  }

  Future<T> revokeAccessToken<T>(
      {required String accessToken,
      required T Function(Map<String, dynamic> map) parseCallback}) async {
    final String response =
        await httpClient.post(url: '$url/oauth/revoke', headers: {
      'Authorization': basicAuthorization,
      'Content-Type': 'application/x-www-form-urlencoded'
    }, body: {
      'accessToken': accessToken
    });

    return parseCallback(json.decode(response));
  }

  //ENTITIES

  Future<List<T>> getEntities<T extends Entity>(
      {required String name,
      required T Function(Map<String, dynamic> map) parseCallback,
      String? fetchPlan,
      int? limit,
      int? offset,
      String? sort,
      bool? returnNulls,
      bool? returnCount,
      bool? dynamicAttributes}) async {
    try {
      final String response =
          await httpClient.get(url: '$url/rest/entities/$name', query: {
        'fetchPlan': fetchPlan,
        'limit': limit,
        'offset': offset,
        'sort': sort,
        'returnNulls': returnNulls,
        'returnCount': returnCount,
        'dynamicAttributes': dynamicAttributes
      }, headers: {
        'Authorization': 'Bearer ${session.accessToken}'
      });
      final dynamic parsed = json.decode(response).cast<Map<String, dynamic>>();
      return parsed.map<T>((json) => parseCallback(json)).toList();
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error,
          callback: () => getEntities<T>(
              name: name,
              parseCallback: parseCallback,
              fetchPlan: fetchPlan,
              dynamicAttributes: dynamicAttributes,
              limit: limit,
              offset: offset,
              returnCount: returnCount,
              returnNulls: returnNulls,
              sort: sort));
    }
  }

  Future<T> getEntity<T extends Entity>(
      {required String name,
      required String id,
      required T Function(Map<String, dynamic> map) parseCallback,
      String? fetchPlan,
      bool? returnNulls,
      bool? dynamicAttributes}) async {
    try {
      final String response =
          await httpClient.get(url: '$url/rest/entities/$name/$id', query: {
        'fetchPlan': fetchPlan,
        'returnNulls': returnNulls,
        'dynamicAttributes': dynamicAttributes
      }, headers: {
        'Authorization': 'Bearer ${session.accessToken}'
      });
      return parseCallback(json.decode(response));
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error,
          callback: () => getEntity<T>(
              name: name,
              parseCallback: parseCallback,
              id: id,
              fetchPlan: fetchPlan,
              returnNulls: returnNulls));
    }
  }

  Future<String> createEntity<T extends MapEntity>(
      {required String name, required T entity}) async {
    try {
      final String response = await httpClient.post(
          url: '$url/rest/entities/$name',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
          body: entity.toMap());
      return json.decode(response)['id'];
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error,
          callback: () => createEntity<T>(name: name, entity: entity));
    }
  }

  Future<String> updateEntity<T extends MapEntity>(
      {required String name, required String id, required T entity}) async {
    try {
      final String response = await httpClient.put(
          url: '$url/rest/entities/$name/$id',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
          body: entity.toMap());
      return json.decode(response)['id'];
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error,
          callback: () => createEntity<T>(name: name, entity: entity));
    }
  }

  Future<void> deleteEntity<T extends Entity>(
      {required String name, required String id}) async {
    try {
      await httpClient.delete(
          url: '$url/rest/entities/$name/$id',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => deleteEntity<T>(name: name, id: id));
    }
  }

  Future<List<T>> searchEntities<T extends Entity>(
      {required String name,
      required List<GroupCondition> conditions,
      required T Function(Map<String, dynamic> map) parseCallback,
      String? fetchPlan,
      int? limit,
      int? offset,
      String? sort,
      bool? returnNulls,
      bool? returnCount,
      bool? dynamicAttributes}) async {
    try {
      final Map<String, dynamic> body = {
        'filter': {
          'conditions': conditions
              .map((GroupCondition groupCondition) => groupCondition.toMap())
              .toList()
        },
      };
      if (dynamicAttributes != null) {
        body['dynamicAttributes'] = dynamicAttributes;
      }
      if (returnCount != null) body['returnCount'] = returnCount;
      if (returnNulls != null) body['returnNulls'] = returnNulls;
      if (sort != null) body['sort'] = sort;
      if (offset != null) body['offset'] = offset;
      if (fetchPlan != null) body['fetchPlan'] = fetchPlan;
      if (limit != null) body['limit'] = limit;

      String response = await httpClient.post(
          url: '$url/rest/entities/$name/search',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
          body: body);
      final dynamic parsed = json.decode(response).cast<Map<String, dynamic>>();
      return parsed.map<T>((json) => parseCallback(json)).toList();
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error,
          callback: () => searchEntities<T>(
              name: name,
              parseCallback: parseCallback,
              conditions: conditions,
              fetchPlan: fetchPlan,
              limit: limit,
              offset: offset,
              sort: sort,
              returnNulls: returnNulls,
              returnCount: returnCount,
              dynamicAttributes: dynamicAttributes));
    }
  }

  //QUERIES

  Future<List<Query>> getQueries({required String name}) async {
    try {
      String response = await httpClient.get(
          url: '$url/rest/queries/$name',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      final dynamic parsed = json.decode(response).cast<Map<String, dynamic>>();
      return parsed.map<Query>((json) => Query.fromMap(json)).toList();
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getQueries(name: name));
    }
  }

  Future<List<T>> executeQuery<T extends Entity>(
      {required String name,
      required String id,
      required T entity,
      required T Function(Map<String, dynamic> map) parseCallback,
      String? fetchPlan,
      int? limit,
      int? offset,
      String? sort,
      bool? returnNulls,
      bool? returnCount,
      bool? dynamicAttributes}) async {
    try {
      String response = await httpClient.post(
          url: '$url/rest/queries/$name/$id',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
          query: {
            'fetchPlan': fetchPlan,
            'returnNulls': returnNulls,
            'dynamicAttributes': dynamicAttributes
          },
          body: entity.toMap());
      final dynamic parsed = json.decode(response).cast<Map<String, dynamic>>();
      return parsed.map<T>((json) => parseCallback(json)).toList();
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error,
          callback: () => executeQuery<T>(
              name: name,
              id: id,
              fetchPlan: fetchPlan,
              parseCallback: parseCallback,
              entity: entity,
              limit: limit,
              offset: offset,
              sort: sort,
              returnNulls: returnNulls,
              returnCount: returnCount,
              dynamicAttributes: dynamicAttributes));
    }
  }

  Future<int> countQueryResults<T extends Entity>(
      {required String name, required String id, required T entity}) async {
    try {
      final String response = await httpClient.post(
          url: '$url/rest/queries/$name/$id/count',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
          body: entity.toMap());
      return int.parse(response);
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error,
          callback: () =>
              countQueryResults<T>(name: name, id: id, entity: entity));
    }
  }

  //SERVICES

  Future<List<Service>> getServices() async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/services',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      final dynamic parsed = json.decode(response).cast<Map<String, dynamic>>();
      return parsed.map<Service>((json) => Service.fromMap(json)).toList();
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  Future<Service> getService({required String name}) async {
    try {
      String response = await httpClient.get(
          url: '$url/rest/services/$name',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});

      return Service.fromMap(json.decode(response));
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getService(name: name));
    }
  }

  Future<dynamic> executeService<T>({
    required String name,
    required String method,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> map) parseCallback,
  }) async {
    try {
      final String response = await httpClient.post(
          url: '$url/rest/services/$name/$method',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
          body: body);
      if (response == '') {
        return null;
      }

      final dynamic responseParsed = json.decode(response);
      if (responseParsed is List) {
        final dynamic parsed = responseParsed.cast<Map<String, dynamic>>();
        return parsed.map<T>((json) => parseCallback(json)).toList();
      } else if (responseParsed is Map) {
        return parseCallback(responseParsed as Map<String, dynamic>);
      } else {
        throw InvalidHttpResponseException(type: responseParsed.runtimeType);
      }
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error,
          callback: () => executeService<T>(
              name: name,
              method: method,
              body: body,
              parseCallback: parseCallback));
    }
  }

  //FILES

  Future<Map<String, dynamic>> uploadFile(
      {required path, required name}) async {
    try {
      String response = await httpClient.upload(
          file: path,
          query: {'name': name},
          url: '$url/rest/files',
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'image/png',
          });
      return json.decode(response);
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => uploadFile(path: path, name: name));
    }
  }

  Future<File> downloadFile({required String id, required String path}) async {
    try {
      final Uint8List response = await httpClient.download(
          url: '$url/rest/files?fileRef=${Uri.encodeComponent(id)}',
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'image/png',
          });
      return File(path).writeAsBytes(response);
    } on InvalidHttpRequestException catch (error) {
      (error.invalidResponse);
      return await refreshTokenAndRetry(
          error: error, callback: () => downloadFile(path: path, id: id));
    }
  }

  //PERMISSIONS

  Future<Permission> getPermissions() async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/permissions',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      return Permission.fromMap(json.decode(response));
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  //METADATA

  Future<List<EntityMetadata>> getEntitiesMetadata() async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/metadata/entities',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      final dynamic parsed = json.decode(response).cast<Map<String, dynamic>>();
      return parsed
          .map<EntityMetadata>((json) => EntityMetadata.fromMap(json))
          .toList();
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  Future<EntityMetadata> getEntityMetadata({required String name}) async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/metadata/entities/$name',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      return EntityMetadata.fromMap(json.decode(response));
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  Future<List<EnumMetadata>> getEnumsMetadata() async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/metadata/enums',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      final dynamic parsed = json.decode(response).cast<Map<String, dynamic>>();
      return parsed
          .map<EnumMetadata>((json) => EnumMetadata.fromMap(json))
          .toList();
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  Future<EnumMetadata> getEnumMetadata() async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/metadata/enums',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      return EnumMetadata.fromMap(json.decode(response));
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  Future<List<Datatype>> getDatatypes() async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/metadata/datatypes',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      final dynamic parsed = json.decode(response).cast<Map<String, dynamic>>();
      return parsed.map<Datatype>((json) => Datatype.fromMap(json)).toList();
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  //MESSAGES

  Future<Map<String, String>> getEntitiesMessages() async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/messages/entities',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      return json.decode(response);
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  Future<Map<String, String>> getEntityMessages({required String name}) async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/messages/entities/$name',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      return json.decode(response);
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  Future<Map<String, String>> getEnumsMessages() async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/messages/enums',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      return json.decode(response);
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  Future<Map<String, String>> getEnumMessages({required String name}) async {
    try {
      final String response = await httpClient.get(
          url: '$url/rest/messages/enums/$name',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      return json.decode(response);
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error, callback: () => getServices());
    }
  }

  //USERINFO

  Future<UserInfo<T>> getUserInfo<T extends Entity>(
      {required T Function(Map<String, dynamic> map) parseCallback}) async {
    try {
      String response = await httpClient.get(
          url: '$url/rest/userInfo',
          headers: {'Authorization': 'Bearer ${session.accessToken}'});
      return UserInfo.fromMap(
          map: json.decode(response), parseCallback: parseCallback);
    } on InvalidHttpRequestException catch (error) {
      return await refreshTokenAndRetry(
          error: error,
          callback: () => getUserInfo(parseCallback: parseCallback));
    }
  }
}
