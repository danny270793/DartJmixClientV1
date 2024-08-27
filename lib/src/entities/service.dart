import 'dart:convert';

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
