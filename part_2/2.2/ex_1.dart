import 'dart:async';

Stream<int> rawNumbers() => Stream.fromIterable([5, 2, 0, 4, 1]);

void main() async {
  // формируем поток, происходит целочисленное деление 10 с
  // каждым элементом потока
  rawNumbers().map((n) => 10 ~/ n).listen(
    (v) => print('data: $v'),
    onError: (e) => print('error: $e'),
    onDone: () => print('done (no auto-cancel)'),
    // cancelOnError  -> false
  );
}