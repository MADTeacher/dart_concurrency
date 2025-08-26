import 'dart:isolate';

import 'isolates_message.dart';

import '../../agent/message.dart';

class IsolateEntity {
  // Уникальный идентификатор изолята
  final String id;

  // Экземпляр запущенного изолята
  final Isolate isolate;

  // Порт для отправки сообщений в изолят
  final SendPort sendPort;

  IsolateEntity(
    this.id,
    this.isolate,
    this.sendPort,
  );

  // Немедленно завершает работу изолята
  void kill() {
    isolate.kill();
  }

  // Отправляем сообщение в изолят
  Future<AgentMessageResponse> send(
    AgentMessageRequest message,
  ) {
    // Создаем временный ReceivePort для получения ответа
    final port = ReceivePort();
    sendPort.send(
      // Оборачиваем message в IsolatesMessage, добавляя порт для ответа,
      // и отправляем его через sendPort
      IsolatesMessage<AgentMessageRequest>(
        sender: port.sendPort,
        message: message,
      ),
    );
    // Возвращаем Future, который завершается, когда приходит первый ответ
    return port.first.then((value) {
      // Предполагается, что ответ всегда будет типа AgentMessageResponse
      return value as AgentMessageResponse;
    });
  }
}
