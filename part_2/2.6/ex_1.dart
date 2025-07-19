import 'dart:async';
import 'dart:io';

void main() async {
  final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
  final iterator = StreamIterator(stream);

  while (await iterator.moveNext()) {
    stdout.write('${iterator.current} ');
    // Моделируем обработку данных
    await Future.delayed(const Duration(seconds: 1));
  }

  await iterator.cancel(); // отменяем подписку
}
