import 'dart:convert';

class EntityPermission {
  final String target;
  final int value;

  EntityPermission({required this.target, required this.value});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {'target': target, 'value': value};
  }

  factory EntityPermission.fromMap(Map<String, dynamic> json) {
    return EntityPermission(target: json['target'], value: json['value']);
  }
}

class Permission {
  final List<String> authorities;
  final List<EntityPermission> entities;

  Permission({required this.authorities, required this.entities});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'authorities': authorities,
      'entities': entities.map((e) => e.toMap()).toList()
    };
  }

  factory Permission.fromMap(Map<String, dynamic> json) {
    return Permission(
        authorities: json['authorities'],
        entities: json['entities']
            .map<EntityPermission>((entity) => EntityPermission.fromMap(entity))
            .toList());
  }
}
