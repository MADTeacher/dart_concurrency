import 'dart:async';

class Student {
  final String id;
  final String name;
  
  Student(this.id, this.name);

  @override
  String toString() => 'Student(id: $id, name: $name)';
}

// Функция принимает Stream<Student> и возвращает Stream<Student>,
// где все id студентов будут в верхнем регистре
Stream<Student> upperCaseStudentIds(Stream<Student> rawStudents) =>
    Stream.eventTransformed(rawStudents, (sink) => _UpperSink(sink));

// Кастомный EventSink
class _UpperSink implements EventSink<Student> {
  final EventSink<Student> _out; // Выходной поток

  _UpperSink(this._out); 

  @override
  void add(Student data) {
    // Обрабатываем входное событие data 
    // Создаем нового студента с id в верхнем регистре
    // и передаем его в выходной поток
    _out.add(Student(data.id.toUpperCase(), data.name));
  }

  @override
  void addError(Object e, [StackTrace? st]) {
    // Обрабатываем входное событие error
    // перенавравляя его в выходной поток
    _out.addError(e, st);
  }

  @override
  void close() => _out.close();
  // перенавравляем событие close в выходной поток
}


void main() {
  final students = Stream.fromIterable([
    Student('a123', 'Alice'),
    Student('b456', 'Bob'),
    Student('c789', 'Charlie'),
  ]);
  upperCaseStudentIds(students).listen(
    print, onDone: () => print('done')
  );
}
