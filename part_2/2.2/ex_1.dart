import 'dart:async';

Stream<int> rawNumbers() => Stream.fromIterable([5, 2, 0, 4, 1]);

void main() async {
  // формируем поток, в котором все элементы исходного потока
  // делятся на 0
  rawNumbers().map((n) => 10 ~/ n).listen(
    (v) => print('data: $v'),
    onError: (e) => print('error: $e'),
    onDone: () => print('done (no auto-cancel)'),
    // cancelOnError  -> false
  );
}