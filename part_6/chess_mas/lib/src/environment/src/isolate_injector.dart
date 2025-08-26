import 'dart:isolate';

import '../../agent/message.dart';
import '../../agent/i_agent.dart';
import '../../agent/chess_piece_agent.dart';
import 'isolates_message.dart';
import '../../utils/types.dart';

IsolateSignature createIsolateSignature() {
  // Возвращаемая функция, которая будет запущена в новом изоляте
  return (IsolatesMessage<AgentMessageRequest> message) {
    // Создаем новый ReceivePort для получения сообщений в этом изоляте
    final receivePort = ReceivePort();
    // Отправляем SendPort этого порта обратно главному изоляту,
    // чтобы он знал, куда слать сообщения
    message.sender.send(receivePort.sendPort);

    final initMessage = message.message;
    // Проверяем, что первое сообщение - это запрос на инициализацию
    if (initMessage is AgentInitiateRequest) {
      // Создаем экземпляр агента, инициализируя его
      // данными, полученными из сообщения
      final IAgent agent = ChessPieceAgent(
        board: initMessage.board,
        pieceId: initMessage.pieceId,
      );

      // Начинаем слушать входящие сообщения из
      // виртуальной среды (главного изолята)
      receivePort.listen((data) async {
        final isolateMessage = data as IsolatesMessage<AgentMessageRequest>;
        // Обрабатываем сообщение на завершение работы
        if (isolateMessage.message is AgentKillRequest) {
          isolateMessage.sender.send(const AgentKilledResponse());
          receivePort.close();
          Isolate.exit();
        } else {
          // Остальные типы сообщений передаем на обработку агенту
          final feedback = await agent.step(isolateMessage.message);
          // Отправляем ответ агента обратно в виртуальную среду
          isolateMessage.sender.send(feedback);
        }
      });
    } else {
      // Если первое сообщение не является запросом на инициализацию,
      // то выбрасываем исключение
      throw ArgumentError('Expected initiate agent message');
    }
  };
}
