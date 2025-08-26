import '../chess_piece.dart';
import '../move.dart';
import '../position.dart';
import '../vector2.dart';

final class Queen extends ChessPiece {
  Queen({
    required Position position,
  }) : super(name: _name, moves: _moves, position: position);

  Queen.withId({
    required Position position,
    required String id,
  }) : super.withId(
          name: _name,
          moves: _moves,
          position: position,
          id: id,
        );

  // Имя фигуры, используемое для идентификации
  static final String _name = 'Q';

  // Список ходов, которые может совершать Королева,
  // сочетая в себе возможности ладьи и слона. Т.е. она может двигаться
  // на любое количество клеток по вертикали, горизонтали и диагоналям
  static final List<Move> _moves = const [
    // Движение по диагонали вверх-вправо
    Move(
      change: Vector2(vertical: 1, horizontal: 1),
      isDirection: true,
    ),
    // Движение вверх
    Move(
      change: Vector2(vertical: 1, horizontal: 0),
      isDirection: true,
    ),
    // Движение по диагонали вверх-влево
    Move(
      change: Vector2(vertical: 1, horizontal: -1),
      isDirection: true,
    ),
    // Движение вправо
    Move(
      change: Vector2(vertical: 0, horizontal: 1),
      isDirection: true,
    ),
    // Движение влево
    Move(
      change: Vector2(vertical: 0, horizontal: -1),
      isDirection: true,
    ),
    // Движение по диагонали вниз-влево
    Move(
      change: Vector2(vertical: -1, horizontal: -1),
      isDirection: true,
    ),
    // Движение вниз
    Move(
      change: Vector2(vertical: -1, horizontal: 0),
      isDirection: true,
    ),
    // Движение по диагонали вниз-вправо
    Move(
      change: Vector2(vertical: -1, horizontal: 1),
      isDirection: true,
    ),
  ];
}
