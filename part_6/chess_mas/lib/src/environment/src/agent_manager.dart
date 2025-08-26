import 'dart:isolate';

import 'isolate_injector.dart';
import 'isolates_message.dart';
import 'isolate_entity.dart';

import '../../utils/types.dart';
import '../../agent/message.dart';
import '../../board/board.dart';

class AgentManager {
  // Список всех активных сущностей изолятов
  final List<IsolateEntity> _isolates = [];

  // Создаем и запускаем нового агента для
  // шахматной фигуры в отдельном изоляте
  //
  // [board] - начальное состояние доски
  // [pieceId] - идентификатор фигуры, которой будет управлять агент.
  // Метод возвращает [Future], который завершается [IsolateEntity],
  // представляющим обертку над созданным изолятом
  Future<IsolateEntity> createChessPieceAgent(
    Board board,
    String pieceId, {
    bool enabled = true,
  }) {
    final signature = createIsolateSignature();
    final createIsolateAgentFututre = _createIsolateAgent(
      // Функция, которая будет точкой входа для нового изолята
      signature: signature,
      // Начальное сообщение, отправляемое в изолят
      // для инициализации агента
      message: AgentInitiateRequest(
        board: board,
        pieceId: pieceId,
      ),
      // Уникальный идентификатор для нового изолята (обычно ID фигуры)
      idIsolate: pieceId,
      // Флаг, указывающий, активен ли агент
      // (в данной реализации не используется, но потребуется
      // для реализации механизма включения/выключения агентов в
      // в одном из заданий)
      enabled: enabled,
    );

    return createIsolateAgentFututre;
  }

  // Приватный метод для создания и настройки изолята агента
  Future<IsolateEntity> _createIsolateAgent({
    required IsolateSignature signature,
    required AgentInitiateRequest message,
    required String idIsolate,
    required bool enabled,
  }) async {
    // Создаем канал для общения с изолятом
    final receivePort = ReceivePort();
    // Запускаем изолят и передаем ему
    // инициализирующее сообщение
    final isolate = await Isolate.spawn(
      signature,
      IsolatesMessage<AgentInitiateRequest>(
        sender: receivePort.sendPort,
        message: message,
      ),
      debugName: 'Agent $idIsolate',
    );
    // Получаем SendPort изолята
    final isolateSendPort = await receivePort.first;
    // Создаем объект-обертку над изолятом
    final isolateEntity = IsolateEntity(
      idIsolate,
      isolate,
      isolateSendPort,
    );
    // Добавляем isolateEntity в список активных изолятов
    _isolates.add(isolateEntity);

    return isolateEntity;
  }

  // Отправляем сообщение конкретному агенту
  //
  // [item] - изолят, в котором находится агент,
  // которому отправляется сообщение
  // [agentBaseMessage] - сообщение для отправки
  // Метод возвращает [Future] с ответом от агента
  Future<AgentMessageResponse> sendMessage(
    IsolateEntity item,
    AgentMessageRequest agentBaseMessage,
  ) {
    return item.send(agentBaseMessage);
  }

  // Отправляем одно и то же сообщение всем активным агентам
  //
  // [agentMessage] - сообщение для отправки
  // Метод возвращает список [Future], каждый из
  // которых будет содержать ответ от соответствующего агента
  List<Future<AgentMessageResponse>> sendAll(
    AgentMessageRequest agentMessage,
  ) {
    final List<Future<AgentMessageResponse>> agentResponses = [];

    for (final agent in _isolates) {
      agentResponses.add(
        agent.send(agentMessage).then(
              (message) => message,
            ),
      );
    }

    return agentResponses;
  }

  // Вызываем у всех агентов команду на завершение
  void killAllAgents() async {
    // Сначала отправляем всем агентам команду на завершение,
    // чтобы они могли корректно завершить свою работу
    await Future.wait(sendAll(const AgentKillRequest()));
    // Затем принудительно убиваем все изоляты
    for (final item in _isolates) {
      item.kill();
    }
  }
}
