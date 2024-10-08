import 'package:jmixclientv1/jmixclientv1.dart';
import 'package:jmixclientv1/src/entities/entity.dart';
import 'package:jmixclientv1/src/entities/session.dart';
import 'package:jmixclientv1/src/entities/user.dart';

class ExcelUploaded extends Entity {
  final String name;
  final String excel;
  ExcelUploaded(
      {required this.name,
      required this.excel,
      required super.id,
      required super.entityName,
      required super.instanceName});

  factory ExcelUploaded.fromMap(final Map<String, dynamic> map) {
    return ExcelUploaded(
        name: map['name'],
        excel: map['excel'],
        id: map['id'],
        entityName: map['_entityName'],
        instanceName: map['_instanceName']);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'excel': excel};
  }
}

Future<void> main() async {
  final JmixClient jmixClient = JmixClient(
    protocol: String.fromEnvironment('JMIX_PROTOCOL', defaultValue: 'http'),
    hostname:
        String.fromEnvironment('JMIX_HOSTNAME', defaultValue: '127.0.0.1'),
    port: int.fromEnvironment('JMIX_PORT', defaultValue: 8080),
    clientId:
        String.fromEnvironment('JMIX_CLIENT_ID', defaultValue: 'c3c0353462'),
    clientSecret: String.fromEnvironment('JMIX_CLIENT_SECRET',
        defaultValue: '2fc9f1be5d7b0d18f25be642b3af1e5b'),
  );

  final Session session = await jmixClient.getAccessToken(
      username: 'admin',
      password: 'admin',
      parseCallback: (map) => Session.fromMap(map));
  print(session.toMap());

  final List<User> users = await jmixClient.getEntities<User>(
      name: 'User', parseCallback: (e) => User.fromMap(e));
  print(users);

  /*
  final List<ExcelUploaded> excels =
      await jmixClient.getEntities<ExcelUploaded>(
          name: 'ExcelUploaded',
          parseCallback: ((e) => ExcelUploaded.fromMap(e)));
  print(excels);

  final Map<String, dynamic> fileUploaded = await jmixClient.uploadFile(
      path:
          '/home/dvaca/Gitlab/danny-vaca/customers/edgar-zeas/courier-app/documents/OP156-906-13152473_09.08.24_EZ EXPRESS.xlsx',
      name: 'OP156-906-13152473_09.08.24_EZ EXPRESS.xlsx');
  print(fileUploaded);

  final File file = await jmixClient.downloadFile(
      id: fileUploaded['fileRef'], path: fileUploaded['name']);
  print(file);
  */

  /*
  final List<User> users = await jmixClient.getEntities<User>(
      name: 'User', parseCallback: (e) => User.fromMap(e));

  final User user = await jmixClient.executeService<User>(
      name: 'MobileApp',
      method: 'createUser',
      body: {
        "username": "danny${users.length + 1}",
        "password": "danny",
        "firstname": "danny",
        "lastname": "danny"
      },
      parseCallback: (e) => User.fromMap(e));
  print(user.toMap());

  await jmixClient.executeService(
      name: 'MobileApp',
      method: 'updatePassword',
      body: {"password": "admin"},
      parseCallback: (e) => e);
  */

  /*
  final List<User> users = await jmixClient.getEntities<User>(
      name: 'User', parseCallback: (e) => User.fromMap(e));

  final User user = await jmixClient.executeService<User>(
      name: 'MobileApp',
      method: 'createUser',
      body: {
        "username": "danny${users.length + 1}",
        "password": "danny",
        "firstname": "danny",
        "lastname": "danny"
      },
      parseCallback: (e) => User.fromMap(e));
  print(user.toMap());

  final List<Map<String, dynamic>> rows =
      await jmixClient.executeService<Map<String, dynamic>>(
          name: 'MobileApp',
          method: 'getMyExcelRows',
          body: {},
          parseCallback: (e) => e);
  print(rows);
  */

  /*
  final Session session =
      await jmixClient.getAccessToken(username: 'admin', password: 'admin');
  print(session.toMap());

  final Session newSession =
      await jmixClient.refreshAccessToken(refreshToken: session.refreshToken);
  print(newSession.toMap());

  final List<User> users = await jmixClient.getEntities<User>(
      name: 'User', parseCallback: (Map<String, dynamic> e) => User.fromMap(e));
  for (final User user in users) {
    print(user.toMap());
  }

  final User user = await jmixClient.getEntity<User>(
      name: 'User',
      id: users[0].id,
      parseCallback: (Map<String, dynamic> e) => User.fromMap(e));
  print(user.toMap());

  final List<User> matchUsers = await jmixClient.searchEntities<User>(
      name: 'User',
      conditions: [
        Condition(property: 'username', operator: '=', value: 'danny270793')
      ],
      parseCallback: (Map<String, dynamic> e) => User.fromMap(e));
  for (final User user in matchUsers) {
    print(user.toMap());
  }

  final String id = await jmixClient.createEntity(
      name: 'User', entity: MapEntity(map: {'username': 'admin2'}));
  await jmixClient.deleteEntity(name: 'User', id: id);

  final List<Query> queries = await jmixClient.getQueries(name: 'User');
  print(queries);

  final UserInfo userInfo =
      await jmixClient.getUserInfo(parseCallback: (p) => User.fromMap(p));
  print(userInfo.toMap());

  final List<Service> services = await jmixClient.getServices();
  print(services);

  final Service service = await jmixClient.getService(name: 'MobileApp');
  print(service);

  final dynamic serviceResult =
      await jmixClient.executeService<Map<String, dynamic>>(
          name: 'MobileApp',
          method: 'verifyPassword',
          body: {'password': '270793'},
          parseCallback: (map) => map);
  print(serviceResult);
  */
}
