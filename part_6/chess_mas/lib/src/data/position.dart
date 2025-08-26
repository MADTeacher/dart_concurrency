import 'package:equatable/equatable.dart';

import '../utils/types.dart';
import 'vector2.dart';

class Position extends Equatable {
  // Вектор, определяющий координаты 
  // позиции (вертикаль и горизонталь)
  final Vector2 position;

  Position({required this.position});

  // Фабричный конструктор для создания Position из JSON-объекта
  factory Position.fromJson(Json json) {
    return Position(position: Vector2.fromJson(json['position']));
  }

  // Преобразуем Position в JSON-объект
  Json toJson() {
    return {
      'position': position.toJson(),
    };
  }

  @override
  String toString() {
    return 'Position(${position.vertical}, ${position.horizontal})';
  }

  // Создаем копию экземпляра класса 
  // с возможностью обновить позицию
  Position copyWith({Vector2? position}) {
    return Position(position: position ?? this.position);
  }

  // Создаем полную (глубокую) копию экземпляра класса
  Position fullCopy() {
    return Position(position: position.fullCopy());
  }

  // Свойства, используемые для сравнения экземпляров Position
  @override
  List<Object?> get props => [position];
}
