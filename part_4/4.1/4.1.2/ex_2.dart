import 'dart:isolate';

void entryFunction(Object? _) {
  final sum = 2 + 3;
  print('[Isolate] sum: $sum');
}

Future<void> main() async {
  // Запускаем изолят, ничего не передаем
  await Isolate.spawn(entryFunction, null);
  // Добавляем задержку, чтобы изолят успел запуститься
  await Future.delayed(Duration(seconds: 1));
}
