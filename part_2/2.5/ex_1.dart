import 'dart:async';
import 'dart:io';

void main() async {
  late Timer timer; // таймер для отправки данных в поток
  late StreamController<int> controller; // контроллер
  var count = 0; // счетчик, чьи данные будут транслироваться в потоке
  var isPause = false; // флаг паузы

  controller = StreamController<int>(
    onListen: () {
      // появился подписчик
      print('onListen');
      // создаем таймер и начинаем раз в 100 мс отправлять
      // данные в поток
      timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        // если подписчик не поставил прослушивание на паузу
        if (!isPause) {
          // отправляем значение счетчика в поток
          if (count % 3 == 0 && count != 0) {
            controller.addError(ArgumentError('count % 3 == 0'));
          } else {
            controller.add(count);
          }
          count++;
        }
      });
    },
    onCancel: () {
      // подписчик отписался от потока
      print('onCancel');
      timer.cancel();
    },
    onPause: () {
      // подписчик поставил прослушивание на паузу
      print('onPause');
      isPause = true;
    },
    onResume: () {
      // подписчик возобновил прослушивание
      print('onResume');
      isPause = false;
    },
  );

  final sub = controller.stream.listen(
    (v) => stdout.write('$v '),
    onDone: () => print('\n✓Stream completed'),
    onError: (e) => print('\n⚠ error: $e'),
  );

  await Future.delayed(const Duration(seconds: 1));
  print('\n⏸ пауза');
  sub.pause(); // останавливаем прослушивание
  await Future.delayed(const Duration(seconds: 1));
  print('▶ продолжили');
  sub.resume(); // возобновляем прослушивание

  await Future.delayed(const Duration(seconds: 2));
  print('\n⏹ отменили подписку');
  await sub.cancel(); // отменяем подписку на поток

  await controller.close(); // Закрываем контроллер
}
