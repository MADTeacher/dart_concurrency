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
  final errs = ReceivePort();
  final exit = ReceivePort();

  print('Приложение запущено');
  print('Запускаем изолят и ожидаем его завершения');
  await Isolate.spawn(
    asyncError,
    msgs.sendPort,
    onError: errs.sendPort,
    onExit: exit.sendPort,
    debugName: 'async_error',
  );

  final subMsgs = msgs.listen((m) => print('MSG: $m'));
  final subErrs = errs.listen((e) {
    final list = e as List;
    print('ERR: ${list[0]}');
    print('STACK: ${list[1]}');
  });

  await exit.first; // Ожидаем завершения изолата

  await Future.wait([subMsgs.cancel(), subErrs.cancel()]);
  msgs.close();
  errs.close();
  print('Приложение завершено');
}
