import 'dart:async';
import 'dart:isolate';

void workerFunction(SendPort sendPort) {
  int counter = 0;
  Timer.periodic(const Duration(seconds: 1), (timer) {
    counter++;
    sendPort.send('[${Isolate.current.debugName}]: $counter');
    if (counter == 9) {
      timer.cancel();
      Isolate.exit(sendPort, 'exit');
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

  // Подписываемся на прослушивание события о завершении работы изолята
  final exitPort = ReceivePort();
  isolate.addOnExitListener(exitPort.sendPort);

  // Подписываемся на прослушивание сообщений от исходного изолята
  var count = 0;
  final portSub = port.listen((message) async {
    print('[Main isolate]: $message');
    count++;
    switch (count) {
      case 3:
        // Первый раз проверяем жив изолят или нет
        // без задания таймаутов на его принудительное завершение
        print('[Main isolate]: Check isolate is alive');
        final checkPort = ReceivePort();
        isolate.ping(checkPort.sendPort, response: 'pong');
        final response = await checkPort.first;
        print('[Main isolate]: Isolate is alive: ${response == 'pong'}');
      case 5:
        // Второй раз проверяем жив изолят или нет
        // задав таймаут на его принудительное завершение

        // Закомментируйте следующие 2 строки кода, если хотите
        // проверить, как срабатывается таймаут
        isolate.pause(isolate.pauseCapability!);
        // Задержка для того, чтобы изолят успел приостановиться
        await Future.delayed(const Duration(seconds: 2));

        print('[Main isolate]: Check isolate is alive');
        final checkPort = ReceivePort();
        isolate.ping(
          checkPort.sendPort,
          response: 'pong',
          // т.к. изолят поставили на паузу, ответ от него
          // при заданном приоритете операции не прийдет до тех пор,
          // пока он не восстановит работу
          priority: Isolate.beforeNextEvent,
        );

        // Создаем гонку между ответом на ping и таймаутом
        final timeoutFuture = Future.delayed(
          const Duration(seconds: 2),
          () => 'timeout',
        );
        final pingFuture = checkPort.first;

        final result = await Future.any([pingFuture, timeoutFuture]);

        if (result == 'timeout') {
          print('[Main isolate]: Isolate is not alive (timeout)');
          isolate.kill(priority: Isolate.immediate);
          checkPort.close();
        } else {
          print('[Main isolate]: Isolate is alive: ${result == 'pong'}');
        }
    }
  });

  // Ожидаем завершения изолята
  await exitPort.first;
  print('Isolate finished working');
  print('App finished working');
  // Завершаем подписки на события и закрываем порты
  await portSub.cancel();
  port.close();
}
