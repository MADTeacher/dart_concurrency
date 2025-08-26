import 'position.dart';

class MoveSuggestion {
  // Идентификатор фигуры, для которой предлагается ход
  final String pieceId;

  // Новая позиция, на которую предлагается переместить фигуру
  final Position newPosition;

  // Количество конфликтов, которое будет иметь фигура 
  // на новой позиции. Чем меньше это число, тем лучше ход
  final int numberOfConflicts;

  const MoveSuggestion({
    required this.pieceId,
    required this.newPosition,
    required this.numberOfConflicts,
  });
}
