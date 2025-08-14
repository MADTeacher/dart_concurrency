import 'dart:isolate';
import 'dart:async';

typedef SumFunction = void Function(SumMessage msg);

// Класс-сообщение, содержащее данные для сложения
// и порт для возврата результата
class SumMessage {
  final SendPort replyTo;
  final int a;
  final int b;
  const SumMessage({required this.replyTo, required this.a, required this.b});
}

// Точка входа в изолят в виде верхнеуровневой функции
void topLevelSum(SumMessage msg) {
  msg.replyTo.send(msg.a + msg.b);
}

//Статический метод класса, как точка входа в прожидаемый изолят
class SumWorker {
  static void staticSum(SumMessage msg) {
    msg.replyTo.send(msg.a + msg.b);
  }
}

// Создание точки входа через замыкание
SumFunction topLevelSumClosure(int c) {
  return (SumMessage msg) => msg.replyTo.send(msg.a + msg.b + c);
}

void main() async {
  var (a, b) = (1, 2);

  // Запуск изолята c точкой входа в виде верхнеуровневой функции
  final receivePort = ReceivePort();
  final sendPort = receivePort.sendPort;
  final isolate = await Isolate.spawn(
    topLevelSum,
    SumMessage(replyTo: sendPort, a: a, b: b),
  );
  final sum = await receivePort.first;
  isolate.kill();
  print('[Top level func] sum: $sum');

  // Запуск изолата c точкой входа в виде замыкания
  final receivePort2 = ReceivePort();
  final sendPort2 = receivePort2.sendPort;
  final isolate2 = await Isolate.spawn(
    topLevelSumClosure(3),
    SumMessage(replyTo: sendPort2, a: a, b: b),
  );
  final sum2 = await receivePort2.first;
  isolate2.kill();
  print('[Closure func] sum: $sum2');

  // Запуск изолята с точкой входа в
  // виде статического метода класса
  final receivePort3 = ReceivePort();
  final sendPort3 = receivePort3.sendPort;
  final isolate3 = await Isolate.spawn(
    SumWorker.staticSum,
    SumMessage(replyTo: sendPort3, a: a, b: b),
  );
  final sum3 = await receivePort3.first;
  isolate3.kill();
  print('[Static method] sum: $sum3');

  // Запуск изолята с точкой входа в
  // виде замыкающей анонимной функции
  final receivePort4 = ReceivePort();
  final sendPort4 = receivePort4.sendPort;
  final isolate4 = await Isolate.spawn(
    (SendPort msg) => msg.send(a + b),
    sendPort4,
  );
  final sum4 = await receivePort4.first;
  isolate4.kill();
  print('[Anonymous func] sum: $sum4');
}
