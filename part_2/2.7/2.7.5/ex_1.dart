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
    Student('g901', 'Marina'),
    Student('h234', 'Alex'),
    Student('i567', 'Stepan'),
    Student('a123', 'Alice'),
    Student('b456', 'Bob'),
    Student('c789', 'Charlie'),
  ]);
  
  students.where((student){
    // Пропускаем только тех студентов, чье
    // имя начинается на 'A'
    return student.name.startsWith('A');
  }).listen(print);
}
