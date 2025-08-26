import '../agent/message.dart';
import '../environment/src/isolates_message.dart';

// Псевдоним для функции, которая будет 
// выполняться в отдельном изоляте
//
// [port] - это объект, используемый для связи между 
// главным изолятом и изолятом агента
typedef IsolateSignature = void Function(
  IsolatesMessage<AgentMessageRequest> port,
);

// Псевдоним для типа JSON-объекта
typedef Json = Map<String, dynamic>;
