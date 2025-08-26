import '../chess_piece.dart';
import '../move.dart';
import '../position.dart';
import '../vector2.dart';

final class Bishop extends ChessPiece {
  // Создаем нового слона на указанной позиции
  Bishop({
    required Position position,
  }) : super(name: _name, moves: _moves, position: position);

  // Создаем нового слона с указанным id на указанной позиции
  Bishop.withId({
    required Position position,
    required String id,
  }) : super.withId(
          name: _name,
          moves: _moves,
          position: position,
          id: id,
        );

  // Имя фигуры, используемое для идентификации
  static final String _name = 'B';

  // Список ходов, которые может совершать слон, двигаясь
  // на любое количество клеток по диагонали
  static final List<Move> _moves = const [
    // Движение по диагонали вверх-влево
    Move(
      change: Vector2(vertical: 1, horizontal: -1),
      isDirection: true,
    ),
    // Движение по диагонали вверх-вправо
    Move(
      change: Vector2(vertical: 1, horizontal: 1),
      isDirection: true,
    ),
    // Движение по диагонали вниз-вправо
    Move(
      change: Vector2(vertical: -1, horizontal: 1),
      isDirection: true,
    ),
    // Движение по диагонали вниз-влево
    Move(
      change: Vector2(vertical: -1, horizontal: -1),
      isDirection: true,
    ),
  ];
}
