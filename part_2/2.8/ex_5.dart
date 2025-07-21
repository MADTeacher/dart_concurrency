import 'dart:async';

Stream<int> foo() async* {
  yield 1;
  yield 2;
  throw Exception('^_^');
  yield 3; // не выполнится
}

void main() async {
  final repaired = foo().transform(
    StreamTransformer.fromHandlers(
      handleError: (e, st, sink) {
        // перехватываем событие error
        // и отправляем вместо него событие-заглушку
        sink.add(-1);
      },
    ),
  );

  // Подписываемся к потоку, который преобразует
  // ошибку в заглушку
  print('Работа пользовательского потока');
  repaired.listen(
    (v) => print('fixed: $v'),
    onDone: () => print('fixed done'),
  );

  await Future.delayed(Duration(seconds: 1));
  print('\nРабота исходного потока');
  // Для сравнения подписываемся к исходному потоку,
  // который пропустит ошибку
  foo().listen(
    (v) => print('raw: $v'),
    onError: (e) => print('raw error: $e'),
    onDone:   () => print('raw done'),
  );
}
