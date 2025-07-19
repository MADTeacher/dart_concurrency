import 'dart:async';
import 'dart:io';

Future<void> main() async {
  final stream = Stream.fromIterable([1, 2, 3]);

  final count = await stream.length; // слушаем поток до конца
  print('Длина потока: $count'); // 3

  try {
    // повторно слушаем поток
    await for (final value in stream) {
      stdout.write('$value ');
    }
  } catch (e) {
    print(e);
  }
}
