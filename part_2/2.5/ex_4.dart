import 'dart:async';
import 'dart:io';

Future<void> main() async {
  final controller = StreamController<int>.broadcast();
  final timer = Timer.periodic(
    const Duration(milliseconds: 500),
    (t) => controller.add(t.tick),
  );

  // Замыкание для создания подписчиков с собственными
  // файлами логов мониторинга
  Future<void> makeSubscriber(String name, Duration drainTime) {
    final logFile = File('$name.log').openWrite();
    final completer = Completer<void>();
    
    controller.stream.listen(
      (v) => logFile.writeln('$v'), // пишем в лог-файл
      onDone: () async { // обрабатываем завершение потока
        stdout.writeln('[$name] flushing file...');
        // имитация длительной финализации
        await Future.delayed(drainTime);
        await logFile.close(); // закрываем лог-файл
        stdout.writeln('[$name] file closed');
        completer.complete(); // сигнализируем о завершении onDone
      },
      onError: (error) {
        logFile.close();
        completer.completeError(error);
      },
    );
    
    return completer.future; // возвращаем Future, который завершится после onDone
  }

  final l1Done = makeSubscriber('cpu', Duration(milliseconds: 500));
  final l2Done = makeSubscriber('mem', Duration(seconds: 1));

  // Отлавливаем Ctrl‑C и корректно завершаем работу приложения
  ProcessSignal.sigint.watch().listen((_) async {
    stdout.writeln('\nSIGINT received! Start shutdown...');

    // Сначала останавливаем таймер, чтобы не генерировать новые события
    timer.cancel();
    stdout.writeln('Timer canceled');

    // Завершаем работу контроллера и потока,
    await controller.close(); // посылаем слушателям событие "done"
    stdout.writeln('Controller closed, waiting for subscribers...');
    
    // Ждем завершение работы подписчиков (их onDone callbacks)
    await Future.wait([l1Done, l2Done]); 
    stdout.writeln('All subscribers finished');

    // Ждем корректное завершение работы контроллера
    await controller.done;
    stdout.writeln('controller.done → все ресурсы освобождены');
    
    exit(0); // Выходим из приложения
  });

  stdout.writeln('Monitoring…  Press Ctrl+C to stop.');
}
