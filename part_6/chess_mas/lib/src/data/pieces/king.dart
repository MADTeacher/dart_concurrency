import '../chess_piece.dart';
import '../move.dart';
import '../position.dart';
import '../vector2.dart';

final class King extends ChessPiece {
  // Создаем нового короля на указанной позиции
  King({
    required Position position,
  }) : super(name: _name, moves: _moves, position: position);

  // Создаем нового короля с указанным id на указанной позиции
  King.withId({
    required Position position,
    required String id,
  }) : super.withId(
          name: _name,
          moves: _moves,
          position: position,
          id: id,
        );

  // Имя фигуры, используемое для идентификации
  static final String _name = 'K';

  // Список ходов, которые может совершать король, двигаясь
  // на одну клетку в любом направлении
  static final List<Move> _moves = const [
    // Движение по диагонали вверх-вправо
    Move(
      change: Vector2(vertical: 1, horizontal: 1),
      isDirection: false,
    ),
    // Движение вверх
    Move(
      change: Vector2(vertical: 1, horizontal: 0),
      isDirection: false,
    ),
    // Движение по диагонали вверх-влево
    Move(
      change: Vector2(vertical: 1, horizontal: -1),
      isDirection: false,
    ),
    // Движение вправо
    Move(
      change: Vector2(vertical: 0, horizontal: 1),
      isDirection: false,
    ),
    // Движение влево
    Move(
      change: Vector2(vertical: 0, horizontal: -1),
      isDirection: false,
    ),
    // Движение по диагонали вниз-влево
    Move(
      change: Vector2(vertical: -1, horizontal: -1),
      isDirection: false,
    ),
    // Движение вниз
    Move(
      change: Vector2(vertical: -1, horizontal: 0),
      isDirection: false,
    ),
    // Движение по диагонали вниз-вправо
    Move(
      change: Vector2(vertical: -1, horizontal: 1),
      isDirection: false,
    ),
  ];
}
