import 'dart:async';
import 'dart:io';

void main() async {
  final sub = Stream.periodic(const Duration(milliseconds: 300), (i) => i)
      .take(10) // ограничим 10-ю событиями
      .listen((v) => stdout.write('$v '));

  await Future.delayed(const Duration(seconds: 1));
  // Ставим на паузу, но сразу передаем Future.delayed
  // с задержкой на 1 сек. Поток возобновится автоматом,
  // поэтому ручной вызов resume() больше не нужен.
  print('\n⏸ пауза на 1 c');
  sub.pause(Future.delayed(const Duration(seconds: 1)));

  sub.resume();   // возобновляем прослушивание
  await sub.asFuture();  // дожидаемся завершения потока
}

