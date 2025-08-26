import 'dart:async';
import 'dart:math';

import 'isolate_entity.dart';
import 'agent_manager.dart';
import 'environment_state.dart';
import '../../board/board.dart';
import '../../data/conflict.dart';
import '../../data/epoch_info.dart';
import '../../data/move_suggestion.dart';
import '../../agent/message.dart';

// Псевдоним для функции обратного вызова,
// которая передает состояние среды в консоль
typedef ConsoleCallback = void Function(EnvironmentState event);

class Environment {
  // Основная шахматная доска, участвующая в моделировании
  final Board board;

  // Функция обратного вызова для уведомления внешних слушателей
  // (например, консоли) об изменениях состояния
  ConsoleCallback consoleCallback;

  // Менеджер, управляющий созданием, связью и уничтожением агентов
  AgentManager agentManager;

  // Счетчик шагов без уменьшения количества конфликтов.
  // Используется для определения стагнации и остановки моделирования
  int stepsWithoutProgress = 0;

  // Максимальное количество шагов без уменьшения количества конфликтов,
  // при достижении которого моделирование будет остановлено
  int maxStepsWithoutProgress;

  // История количества конфликтов для каждой эпохи
  List<EpochInfo> epochInfo = [];

  // Флаг, указывающий, запущено в данный момент моделирование
  bool isRun = true;

  Environment({
    required this.board,
    required this.agentManager,
    required this.consoleCallback,
    this.maxStepsWithoutProgress = 100,
  });

  // Инициализируем виртуальную среду, создавая по одному
  // агенту для каждой фигуры на доске
  Future<void> initialize() async {
    final List<Future<IsolateEntity>> agents = [];

    for (final piece in board.pieces) {
      final agentCreateFuture = agentManager
          .createChessPieceAgent(
        board,
        piece.id,
      )
          .then((value) {
        return value;
      });
      agents.add(agentCreateFuture);
    }

    // Ожидаем завершения создания всех агентов
    await Future.wait(agents);
    // Уведомляем консоль, что среда перешла в состояние выполнения
    consoleCallback(RunningEnvState(board: board.fullCopy()));
  }

  // Выполняем один шаг (команда 'step') моделирования
  Future<void> step() async {
    final result = await _step();
    // Уведомляем консоль, что среда готова к следующему шагу
    // и передаем результат завершения эпохи моделирования
    consoleCallback(
      ReadyEnvState(board: board.fullCopy(), event: result),
    );
  }

  // Останавливаем симуляцию и уничтожаем всех агентов (команда 'stop')
  Future<void> stop() async {
    agentManager.killAllAgents();
    isRun = false;
    // Уведомляем консоль о завершении работы
    consoleCallback(
      FinishEnvState(
        board: board,
        epochNumber: epochInfo.length,
      ),
    );
  }

  // Запускаем цикл моделирования (команда 'auto') до
  // достижения агентами их целей или стагнации системы,
  // когда 100 эпох моделирования завершились без прогресса,
  // то есть количество конфликтов на доске не уменьшилось.
  Future<void> run() async {
    isRun = true;
    // Цикл продолжается, пока не будет достигнут
    // лимит шагов без прогресса
    while (stepsWithoutProgress < maxStepsWithoutProgress) {
      if (!isRun) {
        break;
      }
      // Выполняем один шаг моделирования (запускаем эпоху)
      await _step();

      // Если количество конфликтов на доске стало равно 0,
      // то останавливаем моделирование
      if (epochInfo.isNotEmpty && epochInfo.last.numberOfConflicts == 0) {
        break;
      }

      // Если количество конфликтов на доске стало меньше,
      // то сбрасываем счетчик стагнации.
      // TODO: подумайте, как оптимизировать эту проверку,
      // т.к. она выполняется на каждом шаге и копит объекты в памяти
      if (epochInfo.length >= 2 &&
          epochInfo[epochInfo.length - 1].numberOfConflicts <
              epochInfo[epochInfo.length - 2].numberOfConflicts) {
        stepsWithoutProgress = 0;
      } else {
        stepsWithoutProgress++;
      }
    }
    // Если моделирование еще не остановлено,
    // то делаем это автоматически
    if (isRun) {
      await stop();
    }
  }

  // Внутренняя логика одного шага моделирования (эпохи размышлений агентов)
  Future<BoardEvent?> _step() async {
    BoardEvent? result;
    // 1. Отправляем всем агентам запрос на
    // начало новой эпохи, содержащий текущее состояние доски
    final List<Future<AgentMessageResponse>> responsesFutures =
        agentManager.sendAll(
      AgentInitiateEpochRequest(board: board),
    );

    // 2. Ожидаем ответы от всех агентов
    final List<AgentMessageResponse> responses =
        await Future.wait(responsesFutures);

    // 3. Фильтруем ответы, оставляя только предложения о ходах
    final List<AgentSuggestMoveResponse> suggestedMovesFromEachAgent =
        responses.map((e) => e).whereType<AgentSuggestMoveResponse>().toList();

    final List<MoveSuggestion> suggestedMoves = [];

    // 4. Собираем все предложенные ходы в один список
    for (final agentSuggestion in suggestedMovesFromEachAgent) {
      suggestedMoves.addAll(agentSuggestion.moveSuggestion);
    }

    // 5. Сортируем ходы по количеству конфликтов (от меньшего к большему)
    suggestedMoves.sort(((a, b) {
      return a.numberOfConflicts.compareTo(b.numberOfConflicts);
    }));

    // 6. Выбираем один из лучших ходов случайным образом
    // и применяем его к доске
    if (suggestedMoves.isNotEmpty) {
      // TODO: Подумайте, как выбрать "лучший ход", а не случайный
      // Здесь следует отметить, что в рамках МАС лучший ход сейчас
      // не всегда приведет к уменьшению количества конфликтов
      // на доске в будущем, поэтому здесь можно применить
      // разные стратегии выбора "лучшего хода".
      final random = Random.secure();
      final moveIndex = random.nextInt(suggestedMoves.length);
      final move = suggestedMoves[moveIndex];
      result = board.apply(move);
      // 7. Обновляем информацию об эпохе
      final List<Conflict> conflicts = board.getConflicts();
      epochInfo.add(EpochInfo(conflicts.length));
    }
    return result;
  }
}
