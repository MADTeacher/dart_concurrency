import 'dart:isolate';

class IsolatesMessage<T> {
  // Порт для отправки ответного сообщения
  final SendPort sender;
  // Полезная нагрузка - само сообщение
  final T message;

  IsolatesMessage({
    required this.sender,
    required this.message,
  });
}
