import 'package:equatable/equatable.dart';
import 'chess_piece.dart';


class Conflict extends Equatable {
  // Фигура, которая инициирует атаку
  final ChessPiece source;

  // Фигура, которая находится под атакой
  final ChessPiece victim;

  Conflict({
    required this.source,
    required this.victim,
  });

  // Свойства, используемые для сравнения экземпляров Conflict
  @override
  List<Object?> get props => [source, victim];
}
