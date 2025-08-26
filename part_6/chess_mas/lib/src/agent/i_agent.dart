import 'message.dart';

abstract interface class IAgent {
  // Выполняем один шаг агента.
  // message - запрос, содержащий информацию,
  // необходимую для выполнения агентом шага моделирования
  Future<AgentMessageResponse> step(
    AgentMessageRequest message,
  );
}
