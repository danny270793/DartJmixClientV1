import 'package:jmixclientv1/src/entities/entity.dart';

class UserInfo<T extends Entity> {
  final String username;
  final String locale;
  final T attributes;

  UserInfo(
      {required this.username, required this.locale, required this.attributes});

  factory UserInfo.fromMap(
      {required Map<String, dynamic> map,
      required T Function(Map<String, dynamic> map) parseCallback}) {
    final Map<String, dynamic> attributes = map['attributes'];
    attributes['_entityName'] = '';
    attributes['_instanceName'] = '';

    return UserInfo(
        username: map['username'],
        locale: map['locale'],
        attributes: parseCallback(attributes));
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'locale': locale,
      'attributes': attributes.toMap()
    };
  }
}
