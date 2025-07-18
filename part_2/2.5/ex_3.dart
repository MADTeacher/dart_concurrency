import 'dart:async';
import 'dart:io';

Future<void> main() async {
  // Создаем контроллер потока
  final controller = StreamController<int>();
  int counter = 0;

  // Функция для отправки данных в поток
  void sendData() {
    if (counter < 10) { // специально допущенная ошибка
                        // стоит 10 заменить на, скажем – 12
                        // и блок с ProcessSignal не понадобится
      controller.add(counter++);
      if (counter <= 10) {
        Timer(const Duration(milliseconds: 300), sendData);
      } else {
        print('\nВсе данные отправлены');
        // Когда данные закончились – закрываем контроллер, 
        controller.close(); 
      }
    }
  }

  // Подписываемся на поток
  final subscription = controller.stream.listen(
    (data) => stdout.write('$data '),
    onDone: () => print('\nПоток завершен'),
  );

  // Обработка сигналов завершения программы
  void cleanup() {
    print('Запуск очистки ресурсов...');

    // Отменяем подписку, если она активна
    if (!subscription.isPaused && !subscription.isPaused) {
      print('Отменяем подписку');
      subscription.cancel();
    }

    // Закрываем контроллер, если он еще не закрыт
    if (!controller.isClosed) {
      print('Закрываем контроллер потока');
      controller.close();
    }

    print('Ресурсы успешно освобождены');
  }

  // Обработка сигналов завершения (Ctrl+C)
  ProcessSignal.sigint.watch().listen((_) {
    print('\nПолучен сигнал завершения (Ctrl+C)');
    cleanup();
    exit(0);
  });

  sendData();
  await subscription.asFuture();

  // Данный участок кода никогда не будет выполнен!!!
  cleanup();
  print('Программа завершена');
}
