# DartJmixClientV1

[![Github pipeline status](https://github.com/danny270793/DartJmixClientV1/actions/workflows/releaser.yaml/badge.svg)](https://github.com/danny270793/DartJmixClientV1/actions/workflows/releaser.yaml)

![GitHub repo size](https://img.shields.io/github/repo-size/danny270793/DartJmixClientV1)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/danny270793/DartJmixClientV1)

![GitHub commit activity](https://img.shields.io/github/commit-activity/m/danny270793/DartJmixClientV1)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/danny270793/DartJmixClientV1/total)

[![pub package](https://img.shields.io/pub/v/jmixclientv1.svg)](https://pub.dev/packages/jmixclientv1)
[![package publisher](https://img.shields.io/pub/publisher/jmixclientv1.svg)](https://pub.dev/packages/jmixclientv1/publisher)

Library to comunicate with jmix 1.x rest api

## Instalation

Install package into dart

```bash
dart pub add jmixclientv1
```

Install package into flutter

```bash
flutter pub add jmixclientv1
```

## Examples

Make and http request

```dart
import 'package:http/http.dart';

Future<void> main() async {
  final JmixClient jmixClient = JmixClient(
    protocol: String.fromEnvironment('JMIX_PROTOCOL'),
    hostname:
        String.fromEnvironment('JMIX_HOSTNAME'),
    port: int.fromEnvironment('JMIX_PORT'),
    clientId:
        String.fromEnvironment('JMIX_CLIENT_ID'),
    clientSecret: String.fromEnvironment('JMIX_CLIENT_SECRET')
  );
  final Session session = await jmixClient.getAccessToken(username: 'admin', password: 'admin');
  print(session.toMap());
}
```

## Follow me

[![YouTube](https://img.shields.io/badge/YouTube-%23FF0000.svg?style=for-the-badge&logo=YouTube&logoColor=white)](https://www.youtube.com/channel/UC5MAQWU2s2VESTXaUo-ysgg)
[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://www.github.com/danny270793/)
[![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/danny270793)

## LICENSE

[![GitHub License](https://img.shields.io/github/license/danny270793/DartJmixClientV1)](license.md)

## Version

![GitHub Tag](https://img.shields.io/github/v/tag/danny270793/DartJmixClientV1)
![GitHub Release](https://img.shields.io/github/v/release/danny270793/DartJmixClientV1)

Last update 27/08/2024
