import 'dart:isolate';

/// Перечисление типов сообщений для обмена между изолятами.
enum MessageType {
  start, // Сообщение для инициализации связи.
  stop, // Сообщение для завершения работы.
  request, // Сообщение с запросом на выполнение операции.
  response; // Сообщение с результатом операции.

  /// Фабричный метод для создания экземпляра MessageType из строки.
  static MessageType fromString(String value) {
    return switch (value) {
      'start' => MessageType.start,
      'request' => MessageType.request,
      'response' => MessageType.response,
      'stop' => MessageType.stop,
      _ => throw Exception('Unknown message type: $value'),
    };
  }
}

/// Запечатанный (sealed) базовый класс для всех сообщений.
/// Определяет общую структуру и фабрику для десериализации JSON.
sealed class Message {
  final MessageType type;
  Message({required this.type});

  /// Фабрика для создания конкретного экземпляра сообщения из JSON.
  /// Использует поле 'type' для определения, какой класс сообщения создать.
  factory Message.fromJson(Map<String, dynamic> json) {
    if (json case {'type': var type}) {
      var msType = MessageType.fromString(type);
      return switch (msType) {
        MessageType.start => StartMessage.fromJson(json),
        MessageType.stop => StopMessage.fromJson(json),
        MessageType.request => RequestMessage.fromJson(
            json,
          ),
        MessageType.response => ResponseMessage.fromJson(
            json,
          ),
      };
    }

    throw Exception('Unknown message: $json');
  }

  /// Абстрактный метод для преобразования сообщения в JSON.
  Map<String, dynamic> toJson();
}

/// Сообщение, отправляемое дочерним изолятом для инициализации.
/// Содержит [SendPort] для обратной связи и приветственное сообщение.
class StartMessage extends Message {
  final SendPort sender; // Порт для отправки сообщений в этот изолят.
  final String hello; // Приветственное сообщение.
  StartMessage(
    this.sender,
    this.hello, {
    super.type = MessageType.start,
  });

  /// Фабрика для создания StartMessage из JSON.
  factory StartMessage.fromJson(Map<String, dynamic> json) {
    return StartMessage(json['sender'], json['hello']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.name, 'sender': sender, 'hello': hello};
  }
}

/// Сообщение для остановки работы изолята.
class StopMessage extends Message {
  StopMessage({super.type = MessageType.stop});

  /// Фабрика для создания StopMessage из JSON.
  factory StopMessage.fromJson(Map<String, dynamic> json) {
    return StopMessage();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
    };
  }
}

/// Сообщение-запрос от главного изолята к дочернему.
/// Содержит данные для вычислений.
class RequestMessage extends Message {
  final int firstValue; // Первое число для операции.
  final int secondValue; // Второе число для операции.

  RequestMessage(
    this.firstValue,
    this.secondValue, {
    super.type = MessageType.request,
  });

  /// Фабрика для создания RequestMessage из JSON.
  factory RequestMessage.fromJson(Map<String, dynamic> json) {
    return RequestMessage(
      json['firstValue'],
      json['secondValue'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'firstValue': firstValue,
      'secondValue': secondValue,
    };
  }
}

/// Сообщение-ответ от дочернего изолята к главному.
/// Содержит результат вычислений.
class ResponseMessage extends Message {
  final int result; // Результат вычисления.
  ResponseMessage(
    this.result, {
    super.type = MessageType.response,
  });

  /// Фабрика для создания ResponseMessage из JSON.
  factory ResponseMessage.fromJson(Map<String, dynamic> json) {
    if (json case {'type': 'response', 'result': int data}) {
      return ResponseMessage(data);
    }
    throw ArgumentError.value(json, 'WTF', "It isn't result");
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'result': result,
    };
  }
}
