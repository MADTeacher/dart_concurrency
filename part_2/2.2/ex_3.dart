import 'dart:async';
import 'dart:io';

Future<void> single() async {
  final sub = Stream.periodic(
        const Duration(milliseconds: 300), (i) => i
      )
      .take(10) // ограничим поток 10-ю событиями
      .listen((v) => stdout.write('$v '));

  await Future.delayed(const Duration(seconds: 1));
  print('\n⏸ пауза');
  sub.pause(); // останавливаем прослушивание
  await Future.delayed(const Duration(seconds: 1));
  print('▶ продолжили');
  sub.resume();   // возобновляем прослушивание
  await sub.asFuture();  // дожидаемся завершения потока
}

Future<void> broadcast() async {
  final stream = Stream.periodic(
        const Duration(milliseconds: 300), (i) => i
      )
      .take(10) // ограничим поток 10-ю событиями
      .asBroadcastStream();
  final sub1 = stream.listen((v) => stdout.write('Sub1: $v '));
  stream.listen((v) => stdout.write('Sub2: $v '));

  await Future.delayed(const Duration(seconds: 1));
  print('\n⏸ пауза Sub1');
  sub1.pause(); // останавливаем прослушивание
  await Future.delayed(const Duration(seconds: 1));
  print('▶ продолжили Sub1');
  sub1.resume();   // возобновляем прослушивание
  await sub1.asFuture();  // дожидаемся завершения потока
}

void main() async {
  print('=== single ===');
  await single();
  print('\n=== broadcast ===');
  await broadcast();
}
