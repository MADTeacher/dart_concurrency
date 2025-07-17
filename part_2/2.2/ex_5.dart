import 'dart:async';
import 'dart:io';

void main() async {
  // Создаем поток с периодическими событиями
  final sub = Stream.periodic(const Duration(milliseconds: 300), (i) => i)
      .take(10) // ограничим 10-ю событиями
      .listen((v) => stdout.write('$v '));
  
  // Ждем немного перед паузой
  await Future.delayed(const Duration(seconds: 1));
  
  // Создаем Completer для управления паузой
  final pauseCompleter = Completer<void>();
  
  print('\n⏸ Подписчик поставлен на паузу');
  
  // Ставим подписчика на паузу, передавая Future из Completer
  sub.pause(pauseCompleter.future);
  
  // Обращаемся к полю isPaused, для проверки
  // состояния подписчика
  print('Subscriber paused: ${sub.isPaused}');

  // Имитируем некоторую работу во время паузы
  print('Выполняем работу во время паузы...');
  await Future.delayed(const Duration(seconds: 2));
  
  // Завершаем паузу, что возобновит подписчика
  print('▶️ Возобновляем подписчика');
  pauseCompleter.complete();
  
  // Дожидаемся завершения потока
  await sub.asFuture();
  print('\nЗавершение работы потока');

  // Закоментируйте предыдущий вызов метода и print,
  // после чего раскомментируйте код ниже и получите
  // свой первый (или не первый) deadlock. При котором
  // поток не завершится, т.к. подписчик не восстановил
  // прослушивание. В результате программа завершится раньше,
  // чем ожидается.
  
  // Вывод в терминал:
  // 0 1 2 
  // ⏸ Подписчик поставлен на паузу
  //  Выполняем работу во время паузы...

  // deadlock
  // print('▶️ Возобновляем подписчика');
  // pauseCompleter.complete();
}