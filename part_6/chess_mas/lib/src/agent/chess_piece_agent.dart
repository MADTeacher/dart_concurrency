import 'i_agent.dart';
import 'message.dart';

import '../board/board.dart';
import '../data/chess_piece.dart';
import '../data/conflict.dart';
import '../data/move_suggestion.dart';

class ChessPieceAgent implements IAgent {
  // Текущее состояние шахматной доски, известное агенту
  Board board;
  // Идентификатор фигуры, которой управляет этот агент
  String pieceId;

  // Создаем агента для указанной фигуры на доске
  ChessPieceAgent({required this.board, required this.pieceId});

  // Обрабатываем входящие запросы и выполняем соответствующий шаг
  @override
  Future<AgentMessageResponse> step(
    AgentMessageRequest message,
  ) async {
    switch (message) {
      // Инициализация агента
      case AgentInitiateRequest():
        return initiate(message);
      // Запуск новой эпохи размышлений агента
      case AgentInitiateEpochRequest():
        return initiateEpoch(message);
      case _:
        // Обработка неизвестных типов сообщений
        break;
    }
    return AgentInactivityResponse(pieceId: pieceId);
  }

  // Обрабатываем запрос на инициализацию, обновляя состояние агента
  AgentMessageResponse initiate(AgentInitiateRequest message) {
    board = message.board;
    pieceId = message.pieceId;
    return AgentInactivityResponse(pieceId: pieceId);
  }

  // Запускаем новую "эпоху" размышлений для поиска лучших ходов,
  // в которой агент анализирует все возможные ходы для своей фигуры.
  // Ход считается приемлемым, если он не увеличивает 
  // количество конфликтов на доске
  AgentMessageResponse initiateEpoch(
    AgentInitiateEpochRequest message,
  ) {
    board = message.board;

    ChessPiece? piece = board.findPieceById(pieceId);

    if (piece is! ChessPiece) {
      return AgentErrorResponse(
        pieceId: pieceId,
        message: 'Не удается найти шахматную фигуру с этим id',
      );
    }

    List<Conflict> conflicts = board.getConflicts();

    List<MoveSuggestion> possibleMoves = [];

    // Перебираем все возможные позиции, куда может сходить фигура
    for (var newPosition in board.getMovablePositions(piece)) {
      Board newBoard = board.fullCopy();

      ChessPiece? newPiece = newBoard.findPieceById(pieceId);

      if (newPiece is! ChessPiece) {
        return AgentErrorResponse(
          pieceId: pieceId,
          message: 'Не удается найти фигуру после копирования доски',
        );
      }

      // Моделируем ход на новой доске
      newBoard.move(newPiece, newPosition);

      List<Conflict> newConflicts = newBoard.getConflicts();

      // Если количество конфликтов не увеличилось,
      // добавляем ход в список предложений
      if (newConflicts.length <= conflicts.length) {
        possibleMoves.add(
          MoveSuggestion(
            pieceId: pieceId,
            newPosition: newPosition,
            numberOfConflicts: newConflicts.length,
          ),
        );
      }
    }

    // Если список предложений пуст,
    // возвращаем ответ об отсутствии ходов
    if (possibleMoves.isEmpty) {
      return AgentInactivityResponse(pieceId: pieceId);
    }

    // Возвращаем список предложенных агентом ходов
    return AgentSuggestMoveResponse(moveSuggestion: possibleMoves);
  }
}
