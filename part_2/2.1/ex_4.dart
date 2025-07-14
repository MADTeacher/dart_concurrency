import 'dart:async';
import 'dart:math';

Future<void> main() async {
  // Создаем широковещательный поток
  final controller = StreamController<int>.broadcast();

  // Создаем Completer для ожидания завершения всех задач
  final slowCompleter = Completer<void>();
  final fastCompleter = Completer<void>();

  final random = Random();

  // Создаем "медленного" подписчика БЕЗ pause/resume. То есть
  // подписка при получении события не приостанавливается
  controller.stream.listen(
    (event) async {
      // расчитываем случайную задержку от 500 до 2000 мс
      final delay = 500 + random.nextInt(1501);
      print(
        '(Медленный) Получил событие: $event. Обработка займет $delay мс...',
      );

      // ВАЖНО: listen НЕ ждет завершения этого Future!!!
      await Future.delayed(Duration(milliseconds: delay));

      print('(Медленный) Закончил обработку: $event');
    },
    onDone: () {
      print('(Медленный) Поток завершен');
      if (!slowCompleter.isCompleted) slowCompleter.complete();
    },
  );

  // Объявляем "быстрого" подписчика
  controller.stream.listen(
    (event) {
      print('(Быстрый) Получил и обработал событие: $event');
    },
    onDone: () {
      print('(Быстрый) Поток завершен');
      if (!fastCompleter.isCompleted) fastCompleter.complete();
    },
  );

  print('--- Начинаем генерацию событий ---\n');

  // Генерируем события в поток
  for (int i = 0; i < 10; i++) {
    if (!controller.isClosed) {
      print('>>> Генерируем событие: $i');
      controller.add(i);
      // Небольшая пауза между событиями, чтобы было нагляднее
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  // Закрываем контроллер, что вызовет onDone у подписчиков
  await controller.close();

  // Ждем, пока оба подписчика не сообщат о своем завершении
  await Future.wait([slowCompleter.future, fastCompleter.future]);
}
