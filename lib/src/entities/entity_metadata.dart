import 'dart:convert';

class EntityMetadataProperty {
  final String name;
  final String attributeType;
  final String type;
  final String cardinality;
  final bool mandatory;
  final bool readOnly;
  final String description;
  final bool persistent;

  EntityMetadataProperty(
      {required this.name,
      required this.attributeType,
      required this.type,
      required this.cardinality,
      required this.mandatory,
      required this.readOnly,
      required this.description,
      required this.persistent});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'attributeType': attributeType,
      'type': type,
      'cardinality': cardinality,
      'mandatory': mandatory,
      'readOnly': readOnly,
      'description': description,
      'persistent': persistent
    };
  }

  factory EntityMetadataProperty.fromMap(Map<String, dynamic> json) {
    return EntityMetadataProperty(
        name: json['name'],
        attributeType: json['attributeType'],
        type: json['type'],
        cardinality: json['cardinality'],
        mandatory: json['mandatory'],
        readOnly: json['readOnly'],
        description: json['description'],
        persistent: json['persistent']);
  }
}

class EntityMetadata {
  final String entityName;
  final String ancestor;
  final List<EntityMetadataProperty> properties;

  EntityMetadata(
      {required this.entityName,
      required this.ancestor,
      required this.properties});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'entityName': entityName,
      'ancestor': ancestor,
      'properties': properties.map((e) => e.toMap()).toList()
    };
  }

  factory EntityMetadata.fromMap(Map<String, dynamic> json) {
    return EntityMetadata(
        entityName: json['entityName'],
        ancestor: json['ancestor'],
        properties: json['properties']
            .map<EntityMetadataProperty>(
                (property) => EntityMetadataProperty.fromMap(property))
            .toList());
  }
}
