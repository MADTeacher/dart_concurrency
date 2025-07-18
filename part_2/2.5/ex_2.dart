import 'dart:async';
import 'dart:io';

void main() async {
  late StreamController<int> controller; // контроллер
  final stream = Stream.periodic(const Duration(milliseconds: 200), (count) {
    return count;
  }).take(10);

  controller = StreamController<int>(
    onListen: () => print('onListen'),
    onCancel: () => print('onCancel'),
    onPause: () => print('onPause'),
    onResume: () => print('onResume'),
  );

  print('Is closed: ${controller.isClosed}');
  // перенаправляем события потока в поток контроллера
  controller.addStream(stream);

  print('Has listeners: ${controller.hasListener}');

  final sub = controller.stream.listen(
    // подключаем слушателя
    (v) => stdout.write('$v '),
    onDone: () => print('\n✓Stream completed'),
    onError: (e) => print('\n⚠ error: $e'),
  );

  print('Has listeners: ${controller.hasListener}');
  print('Is paused: ${controller.isPaused}');

  await Future.delayed(const Duration(seconds: 1));
  print('\n⏸ пауза');
  sub.pause(); // останавливаем прослушивание
  print('Is paused: ${controller.isPaused}');
  await Future.delayed(const Duration(seconds: 1));
  print('▶ продолжили');
  sub.resume(); // возобновляем прослушивание

  await Future.delayed(const Duration(seconds: 2));
  print('\n⏹ отменили подписку');
  await sub.cancel(); // отменяем подписку на поток

  await controller.close(); // Закрываем контроллер
  print('Is closed: ${controller.isClosed}');
}
