import 'dart:async';

Future<void> main() async {
  final stream = Stream.fromIterable([1, 2, 3]);

  final first = await stream.first;
  print('Первый элемент потока: $first'); // 1

  final last = await stream.last;
  print('Первый элемент потока: $last'); // 3
}
