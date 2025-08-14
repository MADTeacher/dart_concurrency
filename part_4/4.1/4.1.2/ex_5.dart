import 'dart:isolate';
import 'dart:async';

void syncError(SendPort? main) {
  // Выбрасываем неперехватываемую синхронную ошибку
  throw StateError('[Isolate]: sync error');
  print('[Isolate]: after error');
}

void asyncError(SendPort main) {
  // Выводим сообщение перед ошибкой
  Timer(const Duration(milliseconds: 10), () {
    main.send('[Isolate]: before error');
  });

  // Выбрасываем неперехватываемую асинхронную ошибку
  Timer(const Duration(milliseconds: 20), () {
    throw StateError('[Isolate]: async error');
  });

  // Этот таймер не выполнится, т.к. изолят экстренно
  // завершит работу на предыдущем таймере
  Timer(const Duration(milliseconds: 30), () {
    main.send('[Isolate]: after error');
  });
}

void main() async {
  final msgs = ReceivePort();
  final exitSyncPort = ReceivePort();
  final exitAsyncPort = ReceivePort();
  final completer = Completer<void>();
  print('Приложение запущено');

  print('Запускаем изолят и ожидаем его завершения');
  await Isolate.spawn(
    syncError,
    null,
    debugName: 'sync_error',
    onExit: exitSyncPort.sendPort,
  );

  exitSyncPort.listen((_) {
    print('[syncError] завершил работу');
  });

  print('Продолжаем работу');
  print('Запускаем другой изолят и ожидаем его завершения');
  await Isolate.spawn(
    asyncError,
    msgs.sendPort,
    debugName: 'async_error',
    onExit: exitAsyncPort.sendPort,
  );

  final subMsgs = msgs.listen((m) => print('MSG: $m'));

  exitAsyncPort.listen((_) {
    print('[asyncError] завершил работу');
    completer.complete();
  });

  await completer.future; // ожидаем завершения изолята
  // Завершаем подписку на сообщения и закрываем порты
  await subMsgs.cancel();
  msgs.close();
  exitSyncPort.close();
  exitAsyncPort.close();
  print('Приложение завершено');
}
