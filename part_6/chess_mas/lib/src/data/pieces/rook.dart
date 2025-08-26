import '../chess_piece.dart';
import '../move.dart';
import '../position.dart';
import '../vector2.dart';

final class Rook extends ChessPiece {
  Rook({
    required Position position,
  }) : super(name: _name, moves: _moves, position: position);

  Rook.withId({
    required Position position,
    required String id,
  }) : super.withId(
          name: _name,
          moves: _moves,
          position: position,
          id: id,
        );

  // Имя фигуры, используемое для идентификации
  static final String _name = 'R';

  // Список ходов, которые может совершать ладья,
  // двигаясь на любое количество клеток
  // по вертикали или горизонтали
  static final List<Move> _moves = const [
    // Движение вверх
    Move(
      change: Vector2(vertical: 1, horizontal: 0),
      isDirection: true,
    ),
    // Движение вправо
    Move(
      change: Vector2(vertical: 0, horizontal: 1),
      isDirection: true,
    ),
    // Движение вниз
    Move(
      change: Vector2(vertical: -1, horizontal: 0),
      isDirection: true,
    ),
    // Движение влево
    Move(
      change: Vector2(vertical: 0, horizontal: -1),
      isDirection: true,
    ),
  ];
}
