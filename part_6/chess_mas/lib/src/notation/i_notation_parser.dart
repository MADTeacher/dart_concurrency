import '../board/board.dart';
import '../utils/piece_storage.dart';

abstract interface class NotationParser {
  // Разбираем (парсим) строку с нотацией и возвращаем объект [Board].
  // [input] - строка в определенной нотации (например, FEN).
  // [storage] - хранилище фигур для создания их экземпляров.
  Board parse(String input, PieceStorage storage);

  // Сериализуем объект [Board] в строку с нотацией
  String serialize(Board board);
}
