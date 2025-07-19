import 'dart:async';
import 'dart:io';

void main() async {
  final stream = Stream.fromIterable([1, 2, 3, 4, 5]).map((value) {
    if (value == 3) {
      return value ~/ 0;
    }
    return value * 2;
  });
  final iterator = StreamIterator(stream);

  try {
    while (await iterator.moveNext()) {
      stdout.write('${iterator.current} ');
      // Моделируем обработку данных
      await Future.delayed(const Duration(seconds: 1));
    }
  } catch (e) {
    await iterator.moveNext();
    print(iterator.current);
    print(e);
  } finally {
    // при любом исходе отменяем подписку
    await iterator.cancel();
  }
}
