import 'dart:async';

void main() async{
  final stream = Stream.periodic(
    const Duration(milliseconds: 200), 
    (count) {
      if (count % 3 == 0) {
        throw Exception('Произошла ошибка!');
      }
      return count;
  }).take(10);

  // Создаем подписку с начальными обработчиками
  final subscription = stream.listen(
    (data) {
      print('Обработчик сигнала data: $data');
    },
    onError: (e) {
      print('Обработчик ошибки: $e');
    },
    onDone: () {
      print('Обработчик завершения потока');
    },
  );

  await Future.delayed(const Duration(seconds: 1));

  // Подменяем обработчики после подписки на поток
  subscription.onData((data) {
    print('Новый обработчик сигнала data: ${data * 10}');
  });

  subscription.onError((e, _) {
    print('Новый обработчик ошибки: $e');
  });
  subscription.onDone(() {
    print('Новый обработчик завершения потока');
  });

  // Через некоторое время отменяем подписку
  Future.delayed(const Duration(seconds: 2), () {
    subscription.cancel();
  });
}
