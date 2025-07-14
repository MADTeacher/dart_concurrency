import 'dart:async';

class Mutex {
  Future<void> _last = Future.value();
  Future<T> synchronized<T>(FutureOr<T> Function() func) {
    final previous = _last;
    final completer = Completer<void>();
    _last = completer.future;

    return previous.then((_) async {
      try {
        return await func();
      } finally {
        completer.complete();
      }
    });
  }
}

final mutex = Mutex();

Future<void> main() async {
  var sharedCounter = 0; // Общий счетчик

  // Создаем широковещательный поток
  final controller = StreamController<int>.broadcast();

  // Создаем Completer для ожидания завершения всех задач
  final completer = Completer<void>();

  const tasksCount = 1000; // Количество задач
  var tasksCompleted = 0; // Счетчик завершенных задач

  void onTaskDone() {
    tasksCompleted++;
    if (tasksCompleted == tasksCount * 2) {
      // У нас 2 подписчика
      completer.complete();
    }
  }

  // Создаем двух подписчиков (слушателей потока)
  for (int i = 1; i <= 2; i++) {
    controller.stream.listen((task) async {
      print('Подписчик #$i: получил задачу $task, начинаю работу...');

      await mutex.synchronized(() async {
        final currentValue = sharedCounter;
        await Future.delayed(const Duration(microseconds: 10));
        sharedCounter = currentValue + 1;
      });

      print('Подписчик #$i: закончил задачу $task, счетчик = $sharedCounter');
      onTaskDone();
    });
  }

  // Генерируем события в поток
  print('--- Генерируем $tasksCount задач для 2 подписчиков ---');
  for (int i = 0; i < tasksCount; i++) {
    controller.add(i);
  }

  // Ждем завершения всех задач
  await completer.future.timeout(const Duration(seconds: 10));
  await controller.close(); // Закрываем поток

  print('\n--- Результаты ---\n');
  print('Ожидаемое значение счетчика: ${tasksCount * 2}');
  print('Фактическое значение счетчика: $sharedCounter');
}
