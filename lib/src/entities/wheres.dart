import 'dart:convert';

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
