import '../../board/board.dart';

// Базовый класс для всех запросов, отправляемых агенту
sealed class AgentMessageRequest {
  const AgentMessageRequest();
}

// Запрос на инициализацию агента с определенным 
// состоянием доски и фигурой, чьи интересы на доске он будет
// представлять
class AgentInitiateRequest extends AgentMessageRequest {
  // Текущее состояние доски
  final Board board;
  // Идентификатор фигуры, которой управляет агент
  final String pieceId;

  AgentInitiateRequest({
    required this.board,
    required this.pieceId,
  });
}

// Запрос на запуск новой "эпохи" (цикла размышлений) для агента
class AgentInitiateEpochRequest extends AgentMessageRequest {
  // Текущее состояние доски, на основе которого 
  // агент будет принимать решение
  final Board board;

  AgentInitiateEpochRequest({
    required this.board,
  });
}

// Запрос на завершение работы агента
class AgentKillRequest extends AgentMessageRequest {
  const AgentKillRequest();
}