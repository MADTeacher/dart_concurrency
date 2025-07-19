import 'dart:async';
import 'dart:io';

Future<void> main() async {
  final controller = StreamController<int>();
  final stream = controller.stream;

  // Добавляем данные в поток и закрываем его
  controller.add(1);
  controller.add(2);
  controller.add(3);

  // Важно закрыть поток, иначе .length будет ждать вечно
  controller.close();

  // Вычисление длины потока. Эта операция полностью
  // потребляет поток, так как для подсчета всех элементов
  // необходимо дождаться его завершения.
  final streamLength = await stream.length;

  print('Длина потока: $streamLength');

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
