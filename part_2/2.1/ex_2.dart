import 'dart:async';

Future<void> main() async {
  var sharedCounter = 0; // Общий счетчик

  // Создаем широковещательный поток
  final controller = StreamController<int>.broadcast();

  // Создаем Completer для ожидания завершения всех задач
  final completer = Completer<void>();

  const tasksCount = 1000; // Количество событий в потоке
  var tasksCompleted = 0; // Счетчик завершенных задач

  void onTaskDone() {
    tasksCompleted++;
    if (tasksCompleted == tasksCount * 2) { // У нас 2 подписчика
      completer.complete();
    }
  }

  // Создаем двух подписчиков (слушателей потока)
  for (int i = 1; i <= 2; i++) {
    controller.stream.listen((task) async {
      print('Подписчик #$i: получил задачу $task, начинаю работу...');

      // --- НАЧАЛО КРИТИЧЕСКОЙ СЕКЦИИ ---
      // Читаем текущее значение счетчика
      final currentValue = sharedCounter;

      // Имитируем небольшую асинхронную работу 
      // (например, запрос к сети). В этот момент другой 
      // подписчик может начать свою работу
      await Future.delayed(const Duration(microseconds: 10));

      // Увеличиваем значение и записываем обратно. Если другой
      // подписчик уже успел прочитать старое значение,
      // его изменение будет потеряно
      sharedCounter = currentValue + 1;
      // --- КОНЕЦ КРИТИЧЕСКОЙ СЕКЦИИ ---

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
