import 'dart:async';

void main(List<String> arguments) {
  var future2 = Future.delayed(
    Duration(seconds: 4),
    () => 'Future 2', // добавится в очередь событий через 4 сек.
  );

  future2
      .timeout( // сгенерирует исключение
        Duration(seconds: 3),
      )
      .then((value) => print(value))
      .ignore(); // исключение игнорируется
}
