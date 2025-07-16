import 'dart:async';

class Student {
  final String name;
  final int id;
  Student(this.name, this.id);
}

void processStudentStream(Stream<Student> stream) async {
  await for (final student in stream) {
    print('Студент: ${student.name}, ID: ${student.id}');
  }
}

void main() {
  // API ожидает Stream<Student>, а у нас только один студент
  final studentStream = Stream.value(Student('Иван Иванов', 12345));
  processStudentStream(studentStream);
}
