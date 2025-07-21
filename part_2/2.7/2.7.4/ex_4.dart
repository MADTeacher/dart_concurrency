import 'dart:async';

// Функция, которая возвращает поток
// переключающийся между основным потоком и резервным
// по таймауту
Stream<T> timeoutWithFallback<T>(
  Stream<T> stream, // исходный поток
  Duration timeout, // таймаут
  Stream<T> fallback, // резервный поток
) {
  final controller = StreamController<T>();
  StreamSubscription<T>? subscription;
  Timer? timer;

  controller.onListen = () {
    subscription = stream.listen(
      (data) {
        timer?.cancel();
        controller.add(data);
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    timer = Timer(timeout, () {
      print('Switch to cache');
      subscription?.cancel();
      controller.addStream(fallback).whenComplete(controller.close);
    });

    controller.onCancel = () {
      timer?.cancel();
      return subscription?.cancel();
    };
  };

  return controller.stream;
}

Future<void> main() async {
  // Основной поток, который имитирует медленный сетевой ответ
  final controller = StreamController<String>();
  final primaryStream = controller.stream;

  // Резервный поток, который вернет данные из кэша
  final fallbackStream = Stream.fromIterable([
    'Данные из кэша 1',
    'Данные из кэша 2',
  ]);

  final streamWithTimeout = timeoutWithFallback(
    primaryStream,
    const Duration(seconds: 2),
    fallbackStream,
  );

  await for (final value in streamWithTimeout) {
    print('Получено значение: $value');
  }

  await controller.close();
  print('Программа завершена');
}
