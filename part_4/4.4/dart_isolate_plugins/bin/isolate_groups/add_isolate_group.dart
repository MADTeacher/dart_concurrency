import 'dart:isolate';

import '../message.dart';

/// Точка входа для изолята, выполняющего сложение.
/// [args] - аргументы командной строки (не используются).
/// [mainIGroup] - порт для отправки сообщений в главный изолят.
void main(List<String> args, SendPort mainIGroup) async {
  // Создание порта для получения сообщений от главного изолята.
  ReceivePort port = ReceivePort();

  // Отправка в главный изолят сообщения о старте, содержащего
  // порт для обратной связи (port.sendPort) и имя плагина.
  mainIGroup.send(StartMessage(port.sendPort, 'Add plugin').toJson());

  // Прослушивание входящих сообщений от главного изолята.
  port.listen((data) {
    var message = Message.fromJson(data);
    switch (message) {
      // Если получено сообщение об остановке.
      case StopMessage():
        // Отправляем подтверждение остановки обратно.
        mainIGroup.send(StopMessage().toJson());
        // Закрываем порт.
        port.close();
        // Завершаем работу текущего изолята.
        Isolate.current.kill();
      // Если получено сообщение с запросом на вычисление.
      case RequestMessage(
          firstValue: int a,
          secondValue: int b,
        ):
        // Выполняем сложение.
        var result = a + b;
        // Отправляем результат обратно в главный изолят.
        mainIGroup.send(ResponseMessage(result).toJson());
      // Эти типы сообщений не должны приходить в этот изолят.
      case StartMessage() || ResponseMessage():
        print('Message is not supported');
    }
  });
}
