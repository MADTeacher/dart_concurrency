import 'dart:async';
import 'dart:isolate';

typedef IsolateSettings = ({Isolate isolate, ReceivePort port});

// Функция, которая будет выполняться в изоляте
void workerFunction(SendPort sendPort) {
  // Выбрасываем неперехватываемую асинхронную ошибку
  Timer(const Duration(seconds: 5), () {
    throw StateError('[Isolate]: async error');
  });

  int counter = 0;
  Timer.periodic(const Duration(seconds: 1), (timer) {
    counter++;
    print('[${Isolate.current.debugName}]: $counter');
    sendPort.send('[${Isolate.current.debugName}]: $counter');
    if (counter >= 9) {
      // Завершаем таймер и изолят
      timer.cancel();
      Isolate.exit(sendPort, 'exit');
    }
  });
}

// Функция, возвращающая дескриптор на
// запущенный изолят с ограниченными возможностями,
// который нельзя завершить методом kill и поставить его
// работу на паузу
Future<IsolateSettings> createIsolate() async {
  final ReceivePort receivePort = ReceivePort();

  final originalIsolate = await Isolate.spawn(
    workerFunction,
    receivePort.sendPort,
    errorsAreFatal: false,
  );
  print('Isolate created');
  // Создаем дескриптор на изолят с ограниченными возможностями
  final Isolate rIsolate = Isolate(originalIsolate.controlPort);
  return (isolate: rIsolate, port: receivePort);
}

void main() async {
  var (:isolate, :port) = await createIsolate();

  // Подписываемся на прослушивание ошибок, возникающих в рабочем изоляте
  final errorPort = ReceivePort();
  isolate.addErrorListener(errorPort.sendPort);
  final errorSub = errorPort.listen((dynamic error) {
    print('[isolate.errors]: $error');
  });

  // Обрабатываем сообщения, поступающие от порожденного изолята
  int counter = 0;
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
    counter++;
    print('[Main isolate]: $message');
    if (counter == 7) {
      // Попытка завершить изолят с помощью метода kill()
      // не должна иметь никакого эффекта
      isolate.kill(priority: Isolate.immediate);
    }
    if (counter == 3) {
      // Попытка приостановить/возобновить изолят
      // не должна иметь никакого эффекта
      final pauseCapability = isolate.pause();
      Future.delayed(const Duration(seconds: 5), () {
        isolate.resume(pauseCapability);
      });
    }
  });

  await completer.future;
  print('App finished working');
  // Завершаем подписки на события и закрываем порты
  await portSub.cancel();
  await exitSub.cancel();
  await errorSub.cancel();
  port.close();
  errorPort.close();
  exitPort.close();
}
