import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as path;
import 'package:dart_isolate_plugins_example/ansi_cli_helper.dart';

import 'message.dart';

void main(List<String> arguments) async {
  // Создаем и запускаем главное меню
  MainMenu(helper: AnsiCliHelper()).run();
}

// Перечисление состояний приложения
enum AppState {
  none, // Начальное состояние, отображение главного меню
  loadPlugin, // Загрузка плагина
  prosessing, // Обработка данных плагином
  exit, // Выход из приложения
}

// Класс, реализующий логику главного меню и
// взаимодействия с динамическими изоляционными группами
class MainMenu {
  // Список доступных для загрузки файлов плагинов
  // (AOT-скомпилированных изолятов)
  List<FileSystemEntity> _filesForLoad = [];
  // Утилита для работы с цветным выводом в консоли
  final AnsiCliHelper _helper;
  // Файл плагина, который был загружен
  FileSystemEntity? _loadedFile;
  // Текущее состояние приложения
  var state = AppState.none;
  // Флаг, указывающий, начался ли процесс обработки данных плагином
  bool _startProcessing = false;
  // Порт для получения сообщений от плагина
  ReceivePort? _receivePort;
  // Порт для отправки сообщений в плагин
  SendPort? _sendPort;
  // Экземпляр запущенного плагина
  Isolate? _plugin;

  // Конструктор класса
  MainMenu({
    required AnsiCliHelper helper,
  }) : _helper = helper {
    _helper.reset(); // Настройки по умолчанию
  }

  // Метод для обновления состояния приложения
  void _updateAppState(AppState newState) async {
    // Если пришло состояние "Загрузка плагина"
    if (newState == AppState.loadPlugin) {
      _loadedFile = null;
      // Формирование пути к директории с плагинами
      var currentPath = path.join(
        Directory.current.path,
        'bin',
        'isolate_groups',
      );

      // Получение списка aot-файлов
      _filesForLoad = Directory(currentPath)
          .listSync()
          .where((element) => element.path.endsWith('.aot'))
          .toList();
    }
    state = newState; // Обновление состояния
  }

  //Метод для обработки меню выбора плагина и его загрузки
  void _loadHandler() {
    do {
      _helper.clear();
      _helper.setTextColor(AnsiTextColors.yellow);
      _helper.writeLine('========================');
      _helper.writeLine('~~~   Select file    ~~~');
      _helper.writeLine('========================');
      // Вывод списка доступных плагинов
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
          // Возврат в главное меню
          _updateAppState(AppState.none);
          return;
        } else if (val < _filesForLoad.length && val >= 0) {
          // Выбор плагина и переход в состояние обработки
          _loadedFile = _filesForLoad[val];
          _updateAppState(AppState.prosessing);
          return;
        }
      }
    } while (true);
  }

  // Пункты главного меню
  static const List<String> _menu = [
    '1. Load plugin',
    '2. Processing',
    '3. Exit',
  ];

  // Метод для отображения главного меню и обработки выбора пользователя
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
          // Обновление состояния приложения в соответствии с выбором
          _updateAppState(AppState.values[val]);
          return;
        }
      }
    } while (true);
  }

  // Основной цикл приложения, управляющий состояниями
  void run() async {
    while (state != AppState.exit) {
      switch (state) {
        case AppState.none:
          // В начальном состоянии отображаем главное меню
          printMenu();
        case AppState.loadPlugin:
          // В состоянии загрузки плагина отображаем меню выбора плагина
          _loadHandler();
          if (_loadedFile != null) {
            // Если плагин выбран, создаем ReceivePort для общения
            _receivePort = ReceivePort();
            // Запускаем новую изоляционную группу из AOT-снапшота
            _plugin = await Isolate.spawnUri(
              Uri.file(_loadedFile!.path),
              [], // Аргументы для изолята
              // Порт для отправки сообщений в главный изолят
              _receivePort!.sendPort,
            );

            // Слушаем сообщения от плагина
            _receivePort!.listen((data) async {
              var message = Message.fromJson(data);
              switch (message) {
                // Сообщение об остановке от плагина
                case StopMessage():
                  print('Isolate group closed');
                  _receivePort!.close();
                  _receivePort = null;
                  _sendPort = null;
                  _plugin!.kill();
                  _plugin = null;
                  _startProcessing = false;
                // Сообщение с результатом вычислений
                case ResponseMessage(
                    result: int a,
                  ):
                  print('Result $a');
                  await Future.delayed(const Duration(milliseconds: 5000));
                  // Отправляем сообщение об остановке
                  _sendPort?.send(StopMessage().toJson());

                // Начальное сообщение от плагина для установки связи
                case StartMessage(sender: var sender, hello: var hello):
                  _sendPort = sender; // Сохраняем SendPort плагина
                  print(hello);
                // Не поддерживаемый тип сообщения
                case RequestMessage():
                  print('Message is not supported');
              }
            });
            _updateAppState(AppState.prosessing);
          }
        case AppState.prosessing: // Состояние обработки данных
          // Проверка того загружен плагин или нет
          if (_plugin == null) {
            print('Plugin is not loaded');
            await Future.delayed(const Duration(milliseconds: 3000));
            _updateAppState(AppState.loadPlugin);
            continue;
          }
          // Если плагин загружен, но не запущен
          if (!_startProcessing) {
            _helper.clear();
            // Запрос ввода данных
            print('Input two numbers: ');
            var a = int.tryParse(stdin.readLineSync() ?? '0');
            var b = int.tryParse(stdin.readLineSync() ?? '0');
            if (a == null || b == null) {
              _helper.clear();
              continue;
            }
            // Отправка данных на обработку плагину
            _sendPort?.send(RequestMessage(a, b).toJson());
            _startProcessing = true;
          }

        default:
          break;
      }
      // Небольшая задержка для предотвращения загрузки ЦП
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
