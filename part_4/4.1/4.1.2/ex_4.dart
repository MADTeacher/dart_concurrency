import 'dart:isolate';

void entryFunction(Object? _) {
  final sum = 2 + 3;
  print('[Isolate] sum: $sum');
}

Future<void> main() async {
  final receivePort = ReceivePort();
  final isolate = await Isolate.spawn(entryFunction, null);
  isolate.addOnExitListener(receivePort.sendPort, response: 55);
  final result = await receivePort.first;
  print('[Main] result: $result');
}
