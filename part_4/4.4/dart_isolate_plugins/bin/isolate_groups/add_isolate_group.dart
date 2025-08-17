import 'dart:isolate';

import '../message.dart';

// Точка входа для изоляционной группы выполняющей сложение
void main(List<String> args, SendPort mainIGroup) async {
  // Создаем порт для получения сообщений от главного изолята
  ReceivePort port = ReceivePort();

  // Отправляем в главный изолят сообщения о старте, содержащее
  // порт для обратной связи (port.sendPort) и имя плагина
  mainIGroup.send(StartMessage(port.sendPort, 'Add plugin').toJson());

  // Прослушиваем входящие сообщения от изолята
  // из главной изоляционной группы
  port.listen((data) {
    var message = Message.fromJson(data);
    switch (message) {
      // Если получено сообщение об остановке
      case StopMessage():
        // Отправляем подтверждение остановки обратно
        mainIGroup.send(StopMessage().toJson());
        port.close(); // Закрываем порт
        Isolate.exit(); // Завершаем работу изоляционной группы (плагина)
      // Если получено сообщение с запросом на вычисление
      case RequestMessage(
          firstValue: int a,
          secondValue: int b,
        ):
        // Выполняем сложение
        var result = a + b;
        // Отправляем результат обратно в основное приложение
        mainIGroup.send(ResponseMessage(result).toJson());
      // Не поддерживаемые типы сообщений
      case StartMessage() || ResponseMessage():
        print('Message is not supported');
    }
  });
}
