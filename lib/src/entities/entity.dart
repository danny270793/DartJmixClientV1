import 'dart:convert';

class MapEntity {
  final Map<String, dynamic> map;

  MapEntity({required this.map});

  Map<String, dynamic> toMap() => map;

  factory MapEntity.fromMap(Map<String, dynamic> map) => MapEntity(map: map);
}

abstract class Entity {
  final String id;
  final String entityName;
  final String instanceName;

  Entity(
      {required this.id, required this.entityName, required this.instanceName});

  Map<String, dynamic> toMap();
}
