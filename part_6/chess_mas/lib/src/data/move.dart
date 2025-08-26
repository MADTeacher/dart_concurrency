import 'package:equatable/equatable.dart';

import '../utils/types.dart';
import 'vector2.dart';

class Move extends Equatable {
  // Вектор изменения позиции. Указывает, на 
  // сколько клеток и в каком направлении
  // смещается фигура (по вертикали и горизонтали)
  final Vector2 change;

  // Флаг isDirection указывает, является ли ход направлением.
  // Если `true`, фигура может двигаться в этом 
  // направлении на любое количество свободных клеток
  // (например, как ладья или слон).
  // Если `false`, ход ограничен только вектором `change` 
  // (например, как у коня или короля).
  final bool isDirection;

  const Move({
    required this.change,
    this.isDirection = false,
  });

  // Фабричный конструктор для создания Move из JSON-объекта
  factory Move.fromJson(Json json) {
    return Move(
      change: Vector2.fromJson(json['change']),
      isDirection: json['isDirection'],
    );
  }

  // Преобразуем Move в JSON-объект
  Json toJson() {
    return {
      'change': change.toJson(),
      'isDirection': isDirection,
    };
  }

  // Создаем полную (глубокую) копию экземпляра класса
  Move fullCopy() {
    return Move(
      change: change,
      isDirection: isDirection,
    );
  }

  // Свойства, используемые для сравнения экземпляров Move
  @override
  List<Object?> get props => [change, isDirection];
}
