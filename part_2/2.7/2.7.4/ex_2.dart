import 'dart:async';

Future<void> main() async {
  // Создаем поток, который будет отправлять
  // одно число каждые 3 секунды
  final slowStream = Stream.periodic(Duration(seconds: 3), (i) => i);

  // Устанавливаем таймаут в 2 секунды
  final streamWrapper = slowStream.timeout(const Duration(seconds: 2));
  try {
    await for (final value in streamWrapper) {
      print(value);
    }
  } catch (e) {
    print(e);
  }
  // Будет генерировать исключения для подписчика
  // каждые 2 секунды. Чтобы завершить приложение
  // придется нажать в терминале Ctrl+C
  // streamWrapper.listen(
  //   (_) => {},
  //   onDone: () => print('Stream completed'),
  //   onError: (e) => print(e),
  // );
}
