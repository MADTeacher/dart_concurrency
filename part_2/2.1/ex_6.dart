import 'dart:async';

// Mock-класс, имитирующий ресурс, который можно открывать
// и закрывать. Например, файл или сетевое соединение.
class MockFileResource {
  final String name;
  bool _isOpen = false;

  MockFileResource(this.name);

  Future<void> open() async {
    print('[Resource] Файл "$name" открывается...');
    // Имитация I/O-операции
    await Future.delayed(const Duration(milliseconds: 50));
    _isOpen = true;
    print('[Resource] Файл "$name" открыт');
  }

  Future<void> write(String data) async {
    if (!_isOpen) {
      // Это исключение, которое мы ожидаем получить
      throw StateError('Попытка записи в уже закрытый файл "$name"');
    }
    print('[Resource] Запись в "$name": "$data"');
    // Имитация I/O-операции
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> close() async {
    print('[Resource] Файл "$name" закрывается...');
    // Имитация I/O-операции
    await Future.delayed(const Duration(milliseconds: 50));
    _isOpen = false;
    print('[Resource] Файл "$name" закрыт');
  }
}

Future<void> main() async {
  // Создаем ресурс (мок-файл)
  final resource = MockFileResource('data.txt');
  final controller = StreamController<String>();
  final done = Completer<void>();

  // Открываем ресурс
  await resource.open();

  // Начинаем слушать поток используя асинхронный обработчик
  // async означает, что функция немедленно вернет Future,
  // а ее тело выполнится позже в цикле событий
  controller.stream.listen(
    (data) async {
      print('>>> Получено событие: "$data". Начинаем обработку...');
      // Имитируем асинхронную работу 
      // (например, сложную обработку данных)
      await Future.delayed(const Duration(milliseconds: 500));

      // ПРОБЛЕМА: К моменту выполнения этой строки, ресурс 
      // в main() уже будет закрыт!
      print('>>> Пытаемся записать "$data" в ресурс...');
      await resource.write(data);
      print('>>> Успешно обработали "$data"');
    },
    onDone: () {
      print('--- Поток завершен ---');
      if (!done.isCompleted) done.complete();
    },
  );

  // Добавляем записи в поток в очередь микрозадач
  print('\n--- Добавляем записи в поток ---');
  controller.add('Первая запись');
  controller.add('Вторая запись');

  // Закрываем поток, чтобы инициировать onDone,
  // то есть НЕ дожидаемся, пока асинхронные обработчики в listen()
  // завершат свою работу. Поток закроется в цикле событий
  await controller.close();

  print('[Resource] Заврываем доступ к ресурсу');
  await resource.close();

  // Ждем завершения потока (onDone)
  await done.future;
} 
