import 'dart:async';
import 'dart:io';

Stream<int> createStream() {
  final controller = StreamController<int>();
  final stream = controller.stream;

  // Добавляем данные в поток и закрываем его
  controller.add(1);
  controller.add(2);
  controller.add(3);

  // Важно закрыть поток, иначе .last будет ждать вечно
  controller.close();

  return stream;
}

Future<void> main() async {
  print('Пример работы first');
  var stream = createStream();
  // Получаем первый элемент, из-за  чего
  // поток автоматически закрывается
  final first = await stream.first;

  print('Первый элемент потока: $first');

  try {
    // повторно слушаем поток
    await for (final value in stream) {
      // этот код не будет выполнен
      stdout.write('$value ');
    }
  } catch (e) {
    print(e);
  }

  print('\nПример работы last');
  stream = createStream();
  // Получаем последний элемент, из-за  чего
  // поток автоматически закрывается
  final last = await stream.last;
  print('Последний элемент потока: $last');

    try {
    // повторно слушаем поток
    await for (final value in stream) {
      // этот код не будет выполнен
      stdout.write('$value ');
    }
  } catch (e) {
    print(e);
  }
}
