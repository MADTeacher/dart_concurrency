import 'dart:async';
import 'dart:isolate';

void workerFunction(SendPort sendPort) {
  int counter = 0;
  Timer.periodic(const Duration(seconds: 1), (timer) {
    counter++;
    sendPort.send('[${Isolate.current.debugName}]: $counter');
    if (counter == 5) {
      timer.cancel();
    }
  });
}

void main() async {
  final port = ReceivePort();

  final isolate = await Isolate.spawn(
    workerFunction,
    port.sendPort,
    errorsAreFatal: false,
  );

  // Обрабатываем сообщения, поступающие от порожденного изолята
  final completer = Completer<void>();

  // Подписываемся на прослушивание события о завершении работы изолята
  final exitPort = ReceivePort();
  isolate.addOnExitListener(exitPort.sendPort);
  final exitSub = exitPort.listen((_) {
    print('Isolate finished working');
    // Завершаем completer только при фактическом завершении изолята
    completer.complete();
  });

  // Подписываемся на прослушивание сообщений от исходного изолята
  final portSub = port.listen((message) {
    print('[Main isolate]: $message');
  });

  await completer.future;
  print('App finished working');
  // Завершаем подписки на события и закрываем порты
  await portSub.cancel();
  await exitSub.cancel();
  port.close();
  exitPort.close();
}
