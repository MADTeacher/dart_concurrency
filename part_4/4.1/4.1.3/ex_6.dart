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
  // порт для получения события о приостановке изолята,
  // который подключим на прослушивание события onExit
  // в момент последней приостановки изолята
  final exitPausePort = ReceivePort();

  final isolate = await Isolate.spawn(
    workerFunction,
    port.sendPort,
    errorsAreFatal: false,
    paused: true, // стартуем приостановленный изолят
  );

  // Подписываемся на прослушивание события о завершении работы изолята
  final exitPort = ReceivePort();
  isolate.addOnExitListener(exitPort.sendPort);
  final exitSub = exitPort.listen((_) {
    print('Isolate finished working');
  });

  print('[Main isolate]: Configure isolate');
  await Future.delayed(const Duration(seconds: 2));
  // Запускаем изолят. Сначала запускаем с фейковым Capability,
  // который будет проигнорирован
  var fakePauseCapability = Capability();
  print('[Main isolate]: Fake resume isolate');
  isolate.resume(fakePauseCapability); // проигнорируется
  await Future.delayed(const Duration(seconds: 2));
  // Затем запускаем с реальным Capability
  print('[Main isolate]: Resume isolate');
  isolate.resume(isolate.pauseCapability!);

  // Подписываемся на прослушивание сообщений от исходного изолята
  var count = 0;
  final portSub = port.listen((message) async {
    print('[Main isolate]: $message');
    count++;
    switch (count) {
      case 3:
        // Первый раз приостанавливаем изолят,
        // используя стандартный подход с pauseCapability
        print('[Main isolate]: First pause isolate');
        isolate.pause(isolate.pauseCapability!);
        await Future.delayed(const Duration(seconds: 2));
        print('[Main isolate]: Resume isolate');
        isolate.resume(isolate.pauseCapability!);
      case 5:
        // Второй раз приостанавливаем изолят,
        // используя метод pause и возвращаемый им
        // объект для вызова resume
        print('[Main isolate]: Second pause isolate');
        var pauseCapability = isolate.pause();
        await Future.delayed(const Duration(seconds: 2));
        print('[Main isolate]: Resume isolate');
        isolate.resume(pauseCapability);
      case 7:
        // Третий раз приостанавливаем изолят,
        // используя передаваемый в метод pause
        // пользовательский экземпляр Capability, который
        // будем использовать и для вызова resume
        print('[Main isolate]: Third pause isolate');
        var pauseCapability = Capability();
        isolate.pause(pauseCapability);
        await Future.delayed(const Duration(seconds: 1));
        print('[Main isolate]: Add listener on exit');
        // Подписываемся на прослушивание события
        // о завершении работы изолята, пока он на паузе
        isolate.addOnExitListener(exitPausePort.sendPort);
        await Future.delayed(const Duration(seconds: 1));
        print('[Main isolate]: Resume isolate');
        isolate.resume(pauseCapability);
    }
  });

  // Ожидаем завершения изолята
  await exitPausePort.first;
  print('App finished working');
  // Завершаем подписки на события и закрываем порты
  await portSub.cancel();
  await exitSub.cancel();
  port.close();
  exitPort.close();
}
