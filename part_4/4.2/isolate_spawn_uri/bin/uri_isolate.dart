import 'dart:isolate';
import 'dart:math';

import 'message.dart';
import 'user.dart';

void main(List<String> arguments, SendPort sendPort) async {
  int? startUserId;
  if (arguments.isNotEmpty) {
    startUserId = int.tryParse(arguments[0]);
    return;
  }

  var receivePort = ReceivePort();
  sendPort.send(
    StartMessage(receivePort.sendPort).toJson(),
  );

  if (startUserId is int) {
    var user = await fetchUser(startUserId);
    sendPort.send(
      UserResponseMessage(user).toJson(),
    );
  }

  receivePort.listen((message) async {
    var mes = Message.fromJson(message);
    switch (mes) {
      case StopMessage():
        sendPort.send(
          StopMessage().toJson(),
        );
        receivePort.close();
        Isolate.current.kill();
      case UserRequestMessage(id: var id):
        var user = await fetchUser(id);
        sendPort.send(
          UserResponseMessage(user).toJson(),
        );
      case StartMessage() || UserResponseMessage():
        print('Message is not supported');
    }
  });
}

Future<User?> fetchUser(int id) async {
  if (id > 20) {
    return null;
  }

  // Генератор случайных чисел
  final random = Random();

  // Списки с данными для генерации
  final firstNames = ['John', 'Jane', 'Alex', 'Emily', 'Chris'];
  final lastNames = ['Doe', 'Smith', 'Johnson', 'Williams', 'Brown'];
  final avatars = [
    'https://ex.in/img/faces/1-image.jpg',
    'https:// ex.in/img/faces/2-image.jpg',
    'https:// ex.in/img/faces/3-image.jpg',
    'https:// ex.in/img/faces/4-image.jpg',
    'https:// ex.in/img/faces/5-image.jpg'
  ];
  final supportUrls = [
    'https:// ex.in/#support-heading',
    'https://example.com/support',
  ];
  final supportTexts = [
    'To keep ReqRes free, contributions are appreciated!',
    'Example support text.',
  ];

  // Имитация задержки, чтобы симулировать сетевой запрос
  await Future.delayed(Duration(milliseconds: 500));

  // Генерация случайных данных
  final firstName = firstNames[random.nextInt(firstNames.length)];
  final lastName = lastNames[random.nextInt(lastNames.length)];
  final email = '${firstName.toLowerCase()}.${lastName.toLowerCase()}'
      '@example.com';
  final avatar = avatars[random.nextInt(avatars.length)];
  final supportUrl = supportUrls[random.nextInt(supportUrls.length)];
  final supportText = supportTexts[random.nextInt(supportTexts.length)];

  // Создание объекта User с сгенерированными данными
  final user = User(
    data: UserData(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
    ),
    support: Support(
      url: supportUrl,
      text: supportText,
    ),
  );

  return user;
}
