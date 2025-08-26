import 'board.dart';

class BoardVisualizer {
  // Преобразуем объект Board в многострочное строковое представление.
  // Пустые клетки обозначаются как "[-]", а клетки с фигурами —
  // по имени фигуры (например, "[Q]" для королевы).
  // Доска отображается с точки зрения белых, где ряд 1 находится внизу
  String convertToString(Board board) {
    List<List<String>> stringBoard = [];

    // Инициализируем доску пустыми клетками "[-]"
    for (int row = 0; row < board.size.vertical; row++) {
      stringBoard.add(List.generate(board.size.horizontal, (index) => '[-]'));
    }

    // Расставляем фигуры на их позиции
    for (var piece in board.pieces) {
      var position = piece.position.position;

      // Координаты в Position начинаются с 1, а индексы в списке — с 0
      stringBoard[position.vertical - 1][position.horizontal - 1] =
          '[${piece.name}]';
    }

    // Переворачиваем доску, чтобы ряд 1 был внизу,
    // и объединяем все в одну строку
    return stringBoard.reversed.map((e) => e.join(' ')).join('\n');
  }
}
