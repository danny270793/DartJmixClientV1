import 'package:jmixclientv1/src/entities/entity.dart';

class User extends Entity {
  final String username;
  final String firstName;
  final String lastName;
  final String email;

  User(
      {required this.username,
      required this.firstName,
      required this.lastName,
      required this.email,
      required super.id,
      required super.entityName,
      required super.instanceName});

  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      entityName: json['_entityName'],
      instanceName: json['_instanceName'],
      username: json['username'],
      firstName: json['firstName'] ?? "",
      lastName: json['lastName'] ?? "",
      email: json['email'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'firstName': firstName,
      'lastname': lastName,
      'email': email
    };
  }
}
