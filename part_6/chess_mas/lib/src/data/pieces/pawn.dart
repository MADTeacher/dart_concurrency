import '../chess_piece.dart';
import '../move.dart';
import '../position.dart';
import '../vector2.dart';

final class Pawn extends ChessPiece {
  Pawn({
    required Position position,
  }) : super(name: _name, moves: _moves, position: position);

  Pawn.withId({
    required Position position,
    required String id,
  }) : super.withId(
          name: _name,
          moves: _moves,
          position: position,
          id: id,
          additionalAttacks: _additionalAttacks,
        );

  // Имя фигуры, используемое для идентификации
  static final String _name = 'P';

  // Список обычных ходов, которые может совершать пешка
  static final List<Move> _moves = const [
    // Движение вперед на одну клетку
    Move(
      change: Vector2(vertical: 1, horizontal: 0),
      isDirection: false,
    ),
  ];

  // Список атак, которые может совершать пешка
  static final List<Move> _additionalAttacks = const [
    // Атака по диагонали вверх-вправо
    Move(
      change: Vector2(vertical: 1, horizontal: 1),
      isDirection: false,
    ),
    // Атака по диагонали вверх-влево
    Move(
      change: Vector2(vertical: 1, horizontal: -1),
      isDirection: false,
    ),
  ];
}
