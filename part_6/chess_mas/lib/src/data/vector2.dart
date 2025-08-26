import 'package:equatable/equatable.dart';

import '../utils/types.dart';

class Vector2 extends Equatable {
  // Компонент вектора по вертикали (ось Y)
  final int vertical;

  // Компонент вектора по горизонтали (ось X)
  final int horizontal;

  const Vector2({
    required this.vertical,
    required this.horizontal,
  });

  // Фабричный конструктор для создания [Vector2] из JSON-объекта
  factory Vector2.fromJson(Json json) {
    return Vector2(vertical: json['vertical'], horizontal: json['horizontal']);
  }

  // Преобразует [Vector2] в JSON-объект
  Json toJson() {
    return {
      'vertical': vertical,
      'horizontal': horizontal,
    };
  }

  // Перегрузка оператора сложения для векторов, 
  // позволяющая складывать два вектора, получая 
  // новый вектор, компоненты которого являются 
  // суммами соответствующих компонентов исходных векторов
  Vector2 operator +(covariant Vector2 other) {
    return Vector2(
      vertical: vertical + other.vertical,
      horizontal: horizontal + other.horizontal,
    );
  }

  // Создаем полную копию экземпляра класса
  Vector2 fullCopy() {
    return Vector2(
      vertical: vertical,
      horizontal: horizontal,
    );
  }

  // Свойства, используемые для сравнения экземпляров Vector2
  @override
  List<Object?> get props => [vertical, horizontal];
}
