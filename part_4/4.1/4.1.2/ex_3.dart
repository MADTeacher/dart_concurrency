import 'dart:isolate';

void entryFunction(Object? _) {
  final sum = 2 + 3;
  print('[Isolate] sum: $sum');
}

Future<void> main() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(entryFunction, null, onExit: receivePort.sendPort);
  // или
  // final isolate = await Isolate.spawn(entryFunction, null);
  // isolate.addOnExitListener(receivePort.sendPort);

  receivePort.listen((_) {
    // в _ будет null
    receivePort.close();
    print('[Main] Isolate finished');
  });
  // или
  // await receivePort.first;
  // print('[Main] Isolate finished');
}
