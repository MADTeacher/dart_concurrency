import 'dart:async';

void main(List<String> arguments) {
  var future1 = Future.delayed(
    Duration(seconds: 2), // добавится в очередь событий через 2 сек.
    () => 'Future 1',
  );
  var future2 = Future.delayed(
    Duration(seconds: 4),
    () => 'Future 2', // добавится в очередь событий через 4 сек.
  );
  future1
      .timeout(
        Duration(seconds: 3), // лимит на задачу – 3 сек.
        onTimeout: () => 'Timeout for Future 1',
      )
      .then((value) => print(value));

  future2
      .timeout( // без генерации исключений
        Duration(seconds: 3), // лимит на задачу – 3 сек.
        onTimeout: () => 'Timeout for Future 2',
      )
      .then((value) => print(value));

  future2
      .timeout( // сгенерирует исключение
        Duration(seconds: 3),
      )
      .then((value) => print(value))
      .catchError(
        (e) => print(e),
      );
}
