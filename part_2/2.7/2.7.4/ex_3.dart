import 'dart:async';

Future<void> main() async {
  final slowStream = Stream<String>.periodic(Duration(seconds: 3), (i) => '$i');

  slowStream
      .timeout(
        const Duration(seconds: 2),
        onTimeout: (sink) {
          sink.add('WTF???'); // добавляем заглушку
          sink.close(); // и закрываем поток
        },
      )
      .listen(print, onDone: () => print('done'));
}
