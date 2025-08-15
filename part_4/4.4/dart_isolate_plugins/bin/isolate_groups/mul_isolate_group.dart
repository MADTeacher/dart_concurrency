import 'dart:isolate';

import '../message.dart';

/// Точка входа для изолята, выполняющего умножение.
/// [args] - аргументы командной строки (не используются).
/// [mainIGroup] - порт для отправки сообщений в главный изолят.
void main(List<String> args, SendPort mainIGroup) async {
  // Создание порта для получения сообщений от главного изолята.
  ReceivePort port = ReceivePort();

  // Отправка в главный изолят сообщения о старте с портом для обратной связи
  // и именем плагина.
  mainIGroup.send(StartMessage(port.sendPort, 'Multiply plugin').toJson());

  // Прослушивание входящих сообщений.
  port.listen((data) {
    var message = Message.fromJson(data);
    switch (message) {
      // Обработка сообщения об остановке.
      case StopMessage():
        mainIGroup.send(StopMessage().toJson());
        port.close();
        Isolate.current.kill();
      // Обработка запроса на вычисление.
      case RequestMessage(
          firstValue: int a,
          secondValue: int b,
        ):
        // Выполняем умножение.
        var result = a * b;
        // Отправляем результат обратно.
        mainIGroup.send(ResponseMessage(result).toJson());
      // Эти типы сообщений не поддерживаются этим изолятом.
      case StartMessage() || ResponseMessage():
        print('Message is not supported');
    }
  });
}
