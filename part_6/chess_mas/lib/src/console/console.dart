import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import '../notation/i_notation_parser.dart';
import '../utils/piece_storage.dart';
import '../board/board.dart';
import '../environment/environment.dart';

class CLIConsole {
  // Экземпляр среды выполнения агентов
  Environment? environment;

  // Парсер для разбора нотации
  NotationParser notationParser;

  // Визуализатор для отображения состояния шахматной доски в консоли
  final boardVisualizer = BoardVisualizer();

  // Подписка на поток стандартного ввода
  // (stdin) для чтения команд пользователя
  StreamSubscription? stdinStreamSub;

  CLIConsole({required this.notationParser});

  // Запускаем основной цикл прослушивания команд из консоли
  Future<void> run() async {
    print('Welcome to Chess MAS!');
    print('Type "help" to see available commands');
    final parser = _makeParser();
    stdinStreamSub = stdin
        .transform(utf8.decoder) // Декодируем байты в строку UTF-8
        .transform(const LineSplitter()) // Разбиваем поток на строки
        .listen((event) async {
      // Задаем функцию обратного вызова
      // для обработки каждой строки, пришедшей от пользователя
      final eventSplitted = event.split(' ');

      try {
        // Пытаемся разобрать команду
        final results = parser.parse(eventSplitted);
        final command = results.command;
        // Если команда найдена
        if (command != null) {
          switch (command.name) {
            case 'init': // Инициализация МАС
              final pieceStorage = PieceStorage.standard();
              String? fen = command['notation'];
              // Если на вход не поступили данные о расположении фигур,
              // то по умолчанию используем расстановку
              // из задачи о 8 ферзях
              fen ??= 'Q6Q/8/8/3QQ3/3QQ3/8/8/Q6Q';
              final board = notationParser.parse(fen, pieceStorage);
              environment = Environment(
                board: board,
                agentManager: AgentManager(),
                // Передаем функцию обратного вызова
                // для обработки изменений состояния среды
                // и вывода информации в консоль
                consoleCallback: _environmentChangeState,
              );
              // Запускаем инициализацию среды
              await environment?.initialize();
            case 'step': // Запускаем эпоху моделирования
              await environment?.step();
            case 'stop': // Остановка МАС
              await environment?.stop();
            case 'auto': // Автоматический запуск эпох моделирования
              await environment?.run();
            case 'help': // Показать подсказку по командам
              print('init --notation fenString');
              print('step - run next epoch');
              print('stop - stop MAS');
              print('auto - run until finish');
          }
        }
      } on FormatException catch (e) {
        print(e.message);
        print(parser.usage);
      }
    });
  }

  // Обрабатываем изменения состояния среды и выводим информацию в консоль
  void _environmentChangeState(EnvironmentState event) {
    switch (event) {
      // Состояние, указывающее, что МАС запущена,
      // все агенты созданы, готовы к выполнению, а на
      // доске есть определенное количество конфликтов
      case RunningEnvState(board: final board):
        print('Environment running');
        print(boardVisualizer.convertToString(board));
        print('Start conflicts: ${board.getConflicts().length}');

      // Состояние, содержащее результат текущей эпохи
      // моделирования
      case ReadyEnvState(board: final board, event: final event):
        print('Board current state');
        print('Event: $event');
        print(boardVisualizer.convertToString(board));
        print('Conflicts: ${board.getConflicts().length}');

      // Состояние, указывающее, что МАС завершила работу.
      // Содержит номер эпохи, на которой завершилось
      // моделирование и финальное состояние доски
      case FinishEnvState(
          board: final board,
          epochNumber: final epochNumber,
        ):
        print('Environment finished');
        print('Epoch number: $epochNumber');
        print(boardVisualizer.convertToString(board));
        print('Finish conflicts: ${board.getConflicts().length}');
        // Завершаем прослушивание команд из консоли
        stdinStreamSub?.cancel();
    }
  }

  // Создаем и настраиваем парсер аргументов командной строки
  ArgParser _makeParser() {
    final parser = ArgParser();

    // Команда 'init' для инициализации доски.
    // Принимает опциональный флаг '-n' или '--notation'
    // для строки нотации, c помощью которой будет
    // инициализирована шахматная доска
    final initCommand = parser.addCommand('init');
    initCommand.addOption('notation', abbr: 'n');

    // Команда 'step' для выполнения одного шага моделирования
    parser.addCommand('step');
    // Команда 'stop' для остановки моделирования
    parser.addCommand('stop');
    // Команда 'auto' для автоматического
    // выполнения моделирования до его логического завершения
    parser.addCommand('auto');
    // Команда 'help' для вывода списка доступных команд
    parser.addCommand('help');

    return parser;
  }
}
