import 'dart:async';

void main() {
  print('Start');
  
  // StreamController упрощает управление потоками, 
  // автоматически создавая поток и приемник (слушателя), 
  // а также предоставляя методы для управления поведением потока
  final asyncSC = StreamController(); // async по умолчанию
  // Создаем синхронный контроллер потока, реализующий интерфейс
  // абстрактного класса SynchronousStreamController
  final syncSC = StreamController(sync: true);

  asyncSC.stream.listen((e) => print('stream microtask $e'));
  syncSC.stream.listen((e) => print('stream sync $e'));

  asyncSC.add(1); // Добавляем данные в Stream (очередь микрозадач)

  // Доставляем напрямую, не дожидаясь завершения функции main
  syncSC.add(1); 
  syncSC.add(2);

  Future(() => print('event-queue Future'));
  scheduleMicrotask(() => print('scheduleMicrotask'));

  asyncSC.add(2);

  print('End');
}
