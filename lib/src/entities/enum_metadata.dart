import 'dart:convert';

class EnumMetadataValue {
  final String name;
  final String id;
  final String caption;

  EnumMetadataValue(
      {required this.name, required this.id, required this.caption});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id, 'caption': caption};
  }

  factory EnumMetadataValue.fromMap(Map<String, dynamic> json) {
    return EnumMetadataValue(
        name: json['name'], id: json['id'], caption: json['caption']);
  }
}

class EnumMetadata {
  final String name;
  final List<EnumMetadataValue> values;

  EnumMetadata({required this.name, required this.values});

  @override
  String toString() {
    return json.encode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'values': values.map((e) => e.toMap()).toList()};
  }

  factory EnumMetadata.fromMap(Map<String, dynamic> json) {
    return EnumMetadata(
        name: json['name'],
        values: json['id']
            .map<EnumMetadataValue>(
                (property) => EnumMetadataValue.fromMap(property))
            .toList());
  }
}
