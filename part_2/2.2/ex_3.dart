import 'dart:async';
import 'dart:io';

void main() async {
  final sub = Stream.periodic(const Duration(milliseconds: 300), (i) => i)
      .take(10)                         // ограничим 10-ю событиями
      .listen((v) => stdout.write('$v '));

  await Future.delayed(const Duration(seconds: 1));
  print('\n⏸ пауза');
  sub.pause(); // останавливаем прослушивание
  await Future.delayed(const Duration(seconds: 1));
  print('▶ продолжили');
  sub.resume();   // возобновляем прослушивание
  await sub.asFuture();  // дожидаемся завершения потока
}
