import 'dart:async';

Stream<int> createNumberStream() {
  var count = 0;
  return Stream
    .periodic(Duration(milliseconds: 1), (_) => count++)
    .take(4);
}

void main() async {
  // Cоздаем исходный поток
  final sourceStream = createNumberStream();

  // Cоздаем StreamController. Т.к. у него есть методы
  // addStream и close, он может выступать StreamConsumer'ом,
  // т.е. принимать данные из другого потока
  final controller = StreamController<int>();

  // Подписываемся на поток контроллера, 
  // чтобы видеть, что в него попадает, когда 
  // pipe перенаправит события исходного потока в контроллер
  controller.stream.listen(
    (number) {
      print('(Приемник) Получил число: $number');
    },
    onDone: () {
      print('(Приемник) Поток завершен');
    },
  );

  print('\n--- Запускаем pipe ---\n');
  await sourceStream.pipe(controller);
  print('\n--- Pipe завершил работу ---\n');
}
