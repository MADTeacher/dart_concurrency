import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:dart_isolate_plugins_example/ansi_cli_helper.dart';

import 'message.dart';

/// Точка входа в приложение.
void main(List<String> arguments) async {
  // Создание и запуск главного меню.
  MainMenu(helper: AnsiCliHelper()).run();
}

/// Перечисление для состояний приложения (конечный автомат).
enum AppState {
  none, // Начальное состояние, отображение главного меню.
  loadPlugin, // Состояние загрузки плагина (изолята).
  prosessing, // Состояние обработки данных плагином.
  exit, // Состояние выхода из приложения.
}

/// Класс, реализующий логику главного меню и взаимодействия с изолятами.
class MainMenu {
  // Список доступных для загрузки файлов плагинов (AOT-скомпилированных изолятов).
  List<FileSystemEntity> _filesForLoad = [];
  // Утилита для работы с цветным выводом в консоли.
  final AnsiCliHelper _helper;
  // Файл плагина, который был загружен.
  FileSystemEntity? _loadedFile;
  // Текущее состояние приложения.
  var state = AppState.none;
  // Флаг, указывающий, начался ли процесс обработки.
  bool _startProcessing = false;
  // Порт для получения сообщений от изолята.
  ReceivePort? _receivePort;
  // Порт для отправки сообщений в изолят.
  SendPort? _sendPort;
  // Экземпляр запущенного изолята.
  Isolate? _plugin;

  /// Конструктор класса MainMenu.
  MainMenu({
    required AnsiCliHelper helper,
  }) : _helper = helper {
    // Сброс стилей консоли при инициализации.
    _helper.reset();
  }

  /// Обновляет состояние приложения и выполняет необходимые действия при смене состояния.
  void _updateAppState(AppState newState) async {
    if (newState == AppState.loadPlugin) {
      _loadedFile = null;
      // Формирование пути к директории с плагинами.
      var currentPath = path.join(
        Directory.current.path,
        'bin',
        'isolate_groups',
      );

      // Получение списка только aot-файлов (AOT-скомпилированных снапшотов).
      _filesForLoad = Directory(currentPath)
          .listSync()
          .where((element) => element.path.endsWith('.aot'))
          .toList();
    }
    state = newState;
  }

  /// Обработчик для меню выбора и загрузки плагина.
  void _loadHandler() {
    do {
      _helper.clear();
      _helper.setTextColor(AnsiTextColors.yellow);
      _helper.writeLine('========================');
      _helper.writeLine('~~~   Select file    ~~~');
      _helper.writeLine('========================');
      // Вывод списка доступных плагинов.
      for (var i = 0; i < _filesForLoad.length; i++) {
        _helper.writeLine('$i. ${_filesForLoad[i].path}');
      }
      _helper.setTextColor(AnsiTextColors.red);
      _helper.writeLine('${_filesForLoad.length}. Back');
      _helper.setTextColor(AnsiTextColors.yellow);
      _helper.writeLine('========================');
      _helper.write('Select: ');
      var val = int.tryParse(stdin.readLineSync()!);
      if (val != null) {
        if (val >= _filesForLoad.length) {
          // Возврат в главное меню.
          _updateAppState(AppState.none);
          return;
        } else if (val < _filesForLoad.length && val >= 0) {
          // Выбор плагина и переход в состояние обработки.
          _loadedFile = _filesForLoad[val];
          _updateAppState(AppState.prosessing);
          return;
        }
      }
    } while (true);
  }

  /// Пункты главного меню.
  static const List<String> _menu = [
    '1. Load plugin',
    '2. Processing',
    '3. Exit',
  ];

  /// Отображает главное меню и обрабатывает выбор пользователя.
  void printMenu() {
    do {
      _helper.clear();
      _helper.setTextColor(AnsiTextColors.yellow);
      _helper.writeLine('========================');
      _helper.writeLine('~~~   Mobius Conf    ~~~');
      _helper.writeLine('========================');
      for (var i = 0; i < _menu.length; i++) {
        _helper.writeLine(_menu[i]);
      }
      _helper.setTextColor(AnsiTextColors.yellow);
      _helper.writeLine('========================');
      _helper.write('Select: ');
      _helper.setTextColor(AnsiTextColors.white);
      var val = int.tryParse(stdin.readLineSync()!);
      if (val != null) {
        if (val <= _menu.length && val >= 0) {
          // Обновление состояния приложения в соответствии с выбором.
          _updateAppState(AppState.values[val]);
          return;
        }
      }
    } while (true);
  }

  /// Основной цикл приложения, управляющий состояниями.
  void run() async {
    while (state != AppState.exit) {
      switch (state) {
        case AppState.none:
          // В начальном состоянии отображаем главное меню.
          printMenu();
        case AppState.loadPlugin:
          // В состоянии загрузки плагина отображаем меню выбора плагина.
          _loadHandler();
          if (_loadedFile != null) {
            // Если плагин выбран, создаем ReceivePort для общения.
            _receivePort = ReceivePort();
            // Запускаем новый изолят из AOT-снапшота.
            _plugin = await Isolate.spawnUri(
              Uri.file(_loadedFile!.path),
              [], // Аргументы для изолята (здесь не используются).
              _receivePort!
                  .sendPort, // Порт для отправки сообщений в главный изолят.
            );

            // Слушаем сообщения от дочернего изолята.
            _receivePort!.listen((data) async {
              var message = Message.fromJson(data);
              switch (message) {
                // Сообщение об остановке от изолята.
                case StopMessage():
                  print('Isolate group closed');
                  _receivePort!.close();
                  _receivePort = null;
                  _sendPort = null;
                  _plugin!.kill();
                  _plugin = null;
                  _startProcessing = false;
                // Сообщение с результатом вычислений.
                case ResponseMessage(
                    result: int a,
                  ):
                  print('Result $a');
                  await Future.delayed(const Duration(milliseconds: 5000));
                  // Отправляем сообщение об остановке в изолят.
                  _sendPort?.send(StopMessage().toJson());

                // Начальное сообщение от изолята для установки связи.
                case StartMessage(sender: var sender, hello: var hello):
                  _sendPort = sender; // Сохраняем SendPort дочернего изолята.
                  print(hello);
                // Неподдерживаемый тип сообщения.
                case RequestMessage():
                  print('Message is not supported');
              }
            });
            _updateAppState(AppState.prosessing);
          }
        case AppState.prosessing:
          // Состояние обработки данных.
          if (_plugin == null) {
            print('Plugin is not loaded');
            await Future.delayed(const Duration(milliseconds: 3000));
            _updateAppState(AppState.loadPlugin);
            continue;
          }

          if (!_startProcessing) {
            _helper.clear();
            print('Input two numbers: ');
            var a = int.tryParse(stdin.readLineSync() ?? '0');
            var b = int.tryParse(stdin.readLineSync() ?? '0');
            if (a == null || b == null) {
              _helper.clear();
              continue;
            }
            // Отправка данных на обработку в изолят.
            _sendPort?.send(RequestMessage(a, b).toJson());
            _startProcessing = true;
          }

        default:
          break;
      }
      // Небольшая задержка для предотвращения загрузки ЦП.
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
