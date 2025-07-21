import 'dart:async';

class Student {
  final String id;
  final String name;
  Student(this.id, this.name);

  @override
  String toString() => 'Student(id: $id, name: $name)';
}

void main() async {
  final students = Stream.fromIterable([
    Student('d012', 'Stas'),
    Student('e345', 'Eva'),
    Student('f678', 'Fedor'),
    Student('g901', 'Marina')
  ]);

  // Создаем контроллер с single-subscription потоком
  final controller = StreamController<Student>();
  // Оборачиваем поток контроллера в широковещательный поток-обертку
  final broadcatstStream = controller.stream.asBroadcastStream(
    onListen: (subscription) {
      print('Есть первый подписчик на поток');
    },
    onCancel: (subscription) {
      print('Все подписчики завершили работу и отписались');
    },
  );

  final sub1 = broadcatstStream.listen((data)=>print('First: $data'));
  final sub2 = broadcatstStream.listen((data)=>print('Second: $data'));

  await for (final student in students) {
    controller.add(student);
  }

  // Отменяем подписки
  await sub1.cancel();
  await sub2.cancel();

  // Освобождаем контроллер
  await controller.close();
}
