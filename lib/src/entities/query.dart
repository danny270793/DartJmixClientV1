import 'dart:convert';

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
