import 'dart:convert';

import 'package:jmixclientv1/src/entities/entity.dart';
import 'package:jmixclientv1/src/entities/session.dart';
import 'package:jmixclientv1/src/entities/user_info.dart';
import 'package:jmixclientv1/src/http_client.dart';

class ServiceMethods {
  final String name;
  final String? type;

  ServiceMethods({required this.name, required this.type});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'type': type};
  }

  factory ServiceMethods.fromMap(Map<String, dynamic> json) {
    return ServiceMethods(name: json['name'], type: json['type']);
  }
}

class Service {
  final String name;
  final List<ServiceMethods> methods;

  Service({required this.name, required this.methods});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'methods': methods.map((e) => e.toMap()).toList()};
  }

  factory Service.fromMap(Map<String, dynamic> json) {
    return Service(
        name: json['name'],
        methods: json['methods']
            .map<ServiceMethods>(
                (serviceMethods) => ServiceMethods.fromMap(serviceMethods))
            .toList());
  }
}

class QueryParams {
  final String name;
  final String type;

  QueryParams({required this.name, required this.type});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'type': type};
  }

  factory QueryParams.fromMap(Map<String, dynamic> json) {
    return QueryParams(name: json['name'], type: json['type']);
  }
}

class Query {
  final String name;
  final String jpql;
  final String entityName;
  final String fetchPlanName;
  final QueryParams params;

  Query({
    required this.name,
    required this.jpql,
    required this.entityName,
    required this.fetchPlanName,
    required this.params,
  });

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'jpql': jpql,
      'entityName': entityName,
      'fetchPlanName': fetchPlanName,
      'params': params
    };
  }

  factory Query.fromMap(Map<String, dynamic> json) {
    return Query(
        name: json['name'],
        jpql: json['jpql'],
        entityName: json['entityName'],
        fetchPlanName: json['fetchPlanName'],
        params: QueryParams.fromMap(json['params']));
  }
}

abstract class GroupCondition {
  Map<String, dynamic> toMap();
}

class Group implements GroupCondition {
  final String type;
  final List<Condition> conditions;

  Group({required this.type, required this.conditions});

  @override
  String toString() {
    return json.encode(toMap());
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'group': type,
      'conditions':
          conditions.map((Condition condition) => condition.toMap()).toList()
    };
  }
}

class Condition implements GroupCondition {
  final String property;
  final String operator;
  final String value;

  Condition(
      {required this.property, required this.operator, required this.value});

  @override
  String toString() {
    return json.encode(toMap());
  }

  @override
  Map<String, dynamic> toMap() {
    return {'property': property, 'operator': operator, 'value': value};
  }
}

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
    final String authorizationClean = "$clientId:$clientSecret";
    final List<int> authorizationEncoded = utf8.encode(authorizationClean);
    final String authorizationBase64 = base64.encode(authorizationEncoded);
    basicAuthorization = "Basic $authorizationBase64";
    url = "$protocol://$hostname:$port";
  }

  Future<Session> getAccessToken(
      {required String username, required String password}) async {
    final String response =
        await httpClient.post(url: '$url/oauth/token', headers: {
      'Authorization': basicAuthorization,
      'Content-Type': 'application/x-www-form-urlencoded'
    }, body: {
      'grant_type': 'password',
      'username': username,
      'password': password
    });

    session = Session.fromMap(json.decode(response));
    return session;
  }

  Future<Session> refreshAccessToken({required String refreshToken}) async {
    final String response =
        await httpClient.post(url: '$url/oauth/token', headers: {
      'Authorization': basicAuthorization,
      'Content-Type': 'application/x-www-form-urlencoded'
    }, body: {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken
    });

    return Session.fromMap(json.decode(response));
  }

  Future<dynamic> refreshTokenAndRetry(
      {required InvalidHttpRequestException error,
      required Function callback}) async {
    final Map<String, dynamic> errorAsJson =
        json.decode(error.invalidResponse.body);
    final String errorType = errorAsJson['error'] ?? '';
    if (errorType == 'invalid_grant') {
      throw InvalidRefreshToken(message: error.invalidResponse.body);
    }

    if (errorType.contains('invalid_token')) {
      session = await refreshAccessToken(refreshToken: session.refreshToken);
      return await callback();
    }

    throw error;
  }

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

  Future<String> createEntity<T extends EntityToCreate>(
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
          url: '$url/rest/queries/$name/$id',
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

  Future<List<Service>> getServices() async {
    try {
      String response = await httpClient.get(
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

  Future<T> executeService<T>({
    required String name,
    required String method,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> map) parseCallback,
  }) async {
    try {
      String response = await httpClient.post(
          url: '$url/rest/services/$name/$method',
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
          body: body);
      final dynamic parsed = json.decode(response).cast<Map<String, dynamic>>();
      return parsed.map<T>((json) => parseCallback(json)).toList();
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
