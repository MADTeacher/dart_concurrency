import '../data/chess_piece.dart';
import '../data/pieces/bishop.dart';
import '../data/pieces/king.dart';
import '../data/pieces/knight.dart';
import '../data/pieces/queen.dart';
import '../data/pieces/rook.dart';
import '../data/pieces/pawn.dart';
import '../data/position.dart';
import '../data/vector2.dart';


class PieceStorage {
  // Список доступных прототипов фигур
  final List<ChessPiece> pieces;

  PieceStorage(this.pieces);

  // Создаем хранилище со стандартным набором шахматных фигур.
  // Каждая фигура инициализируется в позиции (0, 0) и служит прототипом
  // для создания новых экземпляров
  PieceStorage.standard()
      : pieces = [
          Knight(
            position: Position(
              position: Vector2(vertical: 0, horizontal: 0),
            ),
          ),
          Rook(
            position: Position(
              position: Vector2(vertical: 0, horizontal: 0),
            ),
          ),
          Queen(
            position: Position(
              position: Vector2(vertical: 0, horizontal: 0),
            ),
          ),
          Bishop(
            position: Position(
              position: Vector2(vertical: 0, horizontal: 0),
            ),
          ),
          King(
            position: Position(
              position: Vector2(vertical: 0, horizontal: 0),
            ),
          ),
          Pawn(
            position: Position(
              position: Vector2(vertical: 0, horizontal: 0),
            ),
          ),
        ];

  // Возвращаем функцию-фабрику для создания фигуры по ее имени
  // name, представляющим собой короткое имя фигуры 
  // (например, 'K' для короля,'Q' для ферзя).
  // Возвращаемая функция принимает [Position] и создает новый 
  // экземпляр фигуры указанного типа на этой позиции
  ChessPiece Function(Position position) get(String name) {
    return (Position position) {
      return pieces
          .firstWhere((element) => element.name == name)
          .copyWith(position: position);
    };
  }
}
