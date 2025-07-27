import 'dart:isolate';
import 'dart:async';

void main() async {
  print('Старт');

  await runZonedGuarded(
    () async {
      // Ошибка в текущем изоляте - зона её перехватит
      Timer(Duration(milliseconds: 100), () {
        throw Exception('Ошибка в главном изоляте');
      });

      // Создаем новый изолят
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        isolateFunction,
        receivePort.sendPort,
      );

      // Добавляем обработчик ошибок изолята (НЕ через зону!)
      final errorPort = ReceivePort();
      isolate.addErrorListener(errorPort.sendPort);
      errorPort.listen((errorData) {
        print('❌ IsolateErrorListener: ${errorData[0]}');
      });

      await Future.delayed(Duration(seconds: 1));
      isolate.kill();
      receivePort.close();
      errorPort.close();
    },
    (error, stackTrace) {
      print('✅ Зона перехватила ошибку: $error');
    },
  );
  print('Успешное завершение работы');
}

void isolateFunction(SendPort sendPort) {
  // Генерируем ошибку в изоляте
  Timer(Duration(milliseconds: 500), () {
    throw Exception('Пафос и превозмогание!');
  });
}
