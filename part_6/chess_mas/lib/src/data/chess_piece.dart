import 'package:equatable/equatable.dart';

import 'move.dart';
import 'position.dart';
import '../utils/types.dart';

base class ChessPiece extends Equatable {
  // Уникальный идентификатор фигуры
  final String id;

  // Имя фигуры, обычно представленное одной буквой
  // (например, 'P' для пешки)
  final String name;

  // Список стандартных ходов, которые может совершать фигура
  final List<Move> moves;

  // Список дополнительных атак.
  // (например, для пешки это диагональный захват)
  final List<Move> additionalAttacks;

  // Текущая позиция фигуры на доске
  final Position position;

  // Базовый конструктор для создания нового экземпляра ChessPiece,
  // который по умолчанию инициализирует фигуру с
  // идентификатором '0', позицией (0, 0) и
  // пустым списком ходов
  ChessPiece({
    required this.name,
    required this.moves,
    required this.position,
    this.additionalAttacks = const [],
  }) : id = '0';

  // Создаем новый экземпляр ChessPiece с указанным id
  ChessPiece.withId({
    required this.id,
    required this.name,
    required this.moves,
    required this.position,
    this.additionalAttacks = const [],
  });

  // Фабричный конструктор для создания ChessPiece из JSON-объекта
  factory ChessPiece.fromJson(Json json) {
    return ChessPiece(
      name: json['name'],
      moves: (json['moves'] as List<dynamic>)
          .map((e) => Move.fromJson(e))
          .toList(),
      additionalAttacks: json['additionalAttacks'] != null
          ? (json['additionalAttacks'] as List<dynamic>)
              .map((e) => Move.fromJson(e))
              .toList()
          : [],
      position: Position.fromJson(json['position']),
    );
  }

  // Свойства, используемые для сравнения экземпляров ChessPiece
  @override
  List<Object?> get props => [id, name, moves, additionalAttacks, position];

  // Преобразуем ChessPiece в JSON-объект
  Json toJson() {
    return {
      'id': id,
      'name': name,
      'moves': moves.map((e) => e.toJson()).toList(),
      'additionalAttacks': additionalAttacks.map((e) => e.toJson()).toList(),
      'position': position.toJson(),
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }

  // Создаем копию ChessPiece с обновленными полями. 
  // Если какое-либо поле не предоставлено, то 
  // используется значение из текущего объекта.
  ChessPiece copyWith({
    String? id,
    String? name,
    List<Move>? moves,
    List<Move>? additionalAttacks,
    Position? position,
  }) {
    return ChessPiece.withId(
      id: id ?? this.id,
      name: name ?? this.name,
      moves: moves ?? this.moves,
      position: position ?? this.position,
      additionalAttacks: additionalAttacks ?? this.additionalAttacks,
    );
  }

  // Создаем полную (глубокую) копию ChessPiece.
  // В отличие от copyWith, этот метод также создает глубокие копии
  // списка moves.
  ChessPiece fullCopy() {
    return ChessPiece.withId(
      id: id,
      name: name,
      moves: moves.map((Move e) => e.fullCopy()).toList(),
      position: position,
    );
  }
}
