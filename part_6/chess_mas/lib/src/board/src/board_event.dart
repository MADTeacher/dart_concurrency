import '../../data/position.dart';

// Базовый класс для всех событий, происходящих на доске.
// Использование модификатора sealed гарантирует,
// что все подклассы событий определены
// в этом же файле. Это обеспечивает полноту обработки событий.
sealed class BoardEvent {
  const BoardEvent();
}

// Событие, которое возникает при перемещении фигуры на доске
class BoardPieceMoved extends BoardEvent {
  // Идентификатор перемещенной фигуры
  final String pieceId;
  // Исходная позиция фигуры
  final Position position;
  // Новая позиция фигуры
  final Position newPosition;

  BoardPieceMoved({
    required this.pieceId,
    required this.position,
    required this.newPosition,
  });

  @override
  String toString() {
    return 'BoardPieceMoved(pieceId: $pieceId, position:'
        ' $position, newPosition: $newPosition)';
  }
}

// Событие, которое возникает, когда на доске 
// не происходит никаких действий. Это может означать,
// что решение найдено или система зашла в тупик
class BoardInactivity extends BoardEvent {
  const BoardInactivity();

  @override
  String toString() {
    return 'BoardInactivity()';
  }
}
