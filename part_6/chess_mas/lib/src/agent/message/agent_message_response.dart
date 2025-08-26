import '../../data/move_suggestion.dart';

// Базовый класс для всех ответов, отправляемых агентом
sealed class AgentMessageResponse {
  const AgentMessageResponse();
}

// Ответ от агента, содержащий список предложенных им ходов
// для уменьшения конфликтных ситуаций на доске
class AgentSuggestMoveResponse extends AgentMessageResponse {
  // Список предложений по ходам
  final List<MoveSuggestion> moveSuggestion;

  AgentSuggestMoveResponse({
    required this.moveSuggestion,
  });
}

// Ответ, сообщающий об ошибке, произошедшей в агенте
class AgentErrorResponse extends AgentMessageResponse {
  // Идентификатор фигуры, в агенте которой произошла ошибка
  final String pieceId;
  // Сообщение об ошибке
  final String message;

  AgentErrorResponse({
    required this.pieceId,
    required this.message,
  });
}

// Ответ, сообщающий о том, что агент не может предложить ход
class AgentInactivityResponse extends AgentMessageResponse {
  // Идентификатор фигуры, агент которой неактивен
  final String pieceId;

  AgentInactivityResponse({
    required this.pieceId,
  });
}

// Ответ, подтверждающий, что агент был успешно
// завершил свою работу и высвободил изолят
class AgentKilledResponse extends AgentMessageResponse {
  const AgentKilledResponse();
}
