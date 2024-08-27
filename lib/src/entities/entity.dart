import 'dart:convert';

abstract class EntityToCreate {
  @override
  String toString() => json.encode(toMap());

  Map<String, dynamic> toMap();
}

class EmptyEntity implements EntityToCreate {
  final Map<String, dynamic> map;

  EmptyEntity({required this.map});

  @override
  Map<String, dynamic> toMap() => map;

  factory EmptyEntity.fromMap(Map<String, dynamic> map) =>
      EmptyEntity(map: map);
}

abstract class Entity {
  final String id;
  final String entityName;
  final String instanceName;

  Entity(
      {required this.id, required this.entityName, required this.instanceName});

  Map<String, dynamic> toMap();
}
