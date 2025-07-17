import 'dart:async';
import 'dart:io';

void main() async {
  // Создаем поток с периодическими событиями
  final sub = Stream.periodic(const Duration(milliseconds: 300), (i) => i)
      .take(20) // ограничим 10-ю событиями
      .listen((v) => stdout.write('$v '));

  // Ждем немного перед паузой
  await Future.delayed(const Duration(seconds: 2));

  print('\n🛑 Подписчик отменил подписку');
  await sub.cancel();
}
