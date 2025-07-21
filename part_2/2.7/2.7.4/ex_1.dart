Stream<int> safeDivide(int a, int b) => b == 0
    ? Stream.error(ArgumentError.value(b, 'b', 'must be non‑zero'))
    : Stream.value(a ~/ b);

void main() async {
  print('Перехват исключений на уровне потока');
  safeDivide(5, 0)
      // перехват и обработка исключений на уровне потока
      .handleError(
        (e) => print('Stream: $e'),
        // test - опциональный аргумент, куда передаем
        // анонимную функцию для указания того, какой
        // тип исключения следует перехватить и обработать
        // на уровне потока
        test: (e) => e is ArgumentError,
      )
      .listen(
        (data) {
          print(data);
        },
        onDone: () => print('done'),
        // т.к. ArgumentError перехвачено потоком, то до
        // подписчика оно не доберется
        onError: (e) => print('Subscriber: $e'),
      );

  await Future.delayed(Duration.zero);
  print('\nБез перехвата на уровне потока');
  safeDivide(5, 0).listen(
    (data) {
      print(data);
    },
    onDone: () => print('done'),
    // т.к. ArgumentError не перехвачено потоком, то оно
    // доберется до подписчика 
    onError: (e) => print('Subscriber: $e'),
  );
}
