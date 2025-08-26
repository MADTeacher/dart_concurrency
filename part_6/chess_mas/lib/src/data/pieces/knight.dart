import '../chess_piece.dart';
import '../move.dart';
import '../position.dart';
import '../vector2.dart';

final class Knight extends ChessPiece {
  Knight({
    required Position position,
  }) : super(name: _name, moves: _moves, position: position);

  Knight.withId({
    required Position position,
    required String id,
  }) : super.withId(
          name: _name,
          moves: _moves,
          position: position,
          id: id,
        );

  // Имя фигуры, используемое для идентификации
  static final String _name = 'N';

  // Список ходов, которые может совершать конь,
  // двигаясь буквой "Г": на две клетки в одном
  // направлении (по вертикали или горизонтали)
  // и затем на одну клетку в перпендикулярном направлении
  static final List<Move> _moves = const [
    // Вверх-влево
    Move(
      change: Vector2(vertical: 2, horizontal: -1),
      isDirection: false,
    ),
    // Вверх-вправо
    Move(
      change: Vector2(vertical: 2, horizontal: 1),
      isDirection: false,
    ),
    // Вправо-вверх
    Move(
      change: Vector2(vertical: 1, horizontal: 2),
      isDirection: false,
    ),
    // Вправо-вниз
    Move(
      change: Vector2(vertical: -1, horizontal: 2),
      isDirection: false,
    ),
    // Вниз-вправо
    Move(
      change: Vector2(vertical: -2, horizontal: 1),
      isDirection: false,
    ),
    // Вниз-влево
    Move(
      change: Vector2(vertical: -2, horizontal: -1),
      isDirection: false,
    ),
    // Влево-вниз
    Move(
      change: Vector2(vertical: -1, horizontal: -2),
      isDirection: false,
    ),
    // Влево-вверх
    Move(
      change: Vector2(vertical: 1, horizontal: -2),
      isDirection: false,
    ),
  ];
}
