import 'dart:async';
import 'dart:io';

// Уровни логирования
enum LogLevel { debug, info, warning, error }

class SimpleLogger {
  final LogLevel minLevel;
  // Флаг для включения цветных логов
  final bool enableColors;
  // Список логов
  final List<String> _logs = [];

  // Назначаем ANSI-цвета для уровней логирования
  static const Map<LogLevel, String> _colors = {
    LogLevel.debug: '\x1B[36m',
    LogLevel.info: '\x1B[32m',
    LogLevel.warning: '\x1B[33m',
    LogLevel.error: '\x1B[31m',
  };
  // Сброс цветов
  static const String _reset = '\x1B[0m';

  SimpleLogger({this.minLevel = LogLevel.info, this.enableColors = true});

  // Метод для логирования
  void log(LogLevel level, String message) {
    if (level.index < minLevel.index) return;

    // Формируем строку лога, добавляя время и уровень
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final levelName = level.name.toUpperCase().padRight(7);
    final logEntry = '[$timestamp] [$levelName] $message';

    // Добавляем лог в список
    _logs.add(logEntry);

    if (enableColors) {
      final color = _colors[level] ?? '';
      // Сначала окрашиваем строку лога в соответствующий цвет
      // далее идет само логируемое сообщение,
      // после чего сбрасываем цвет
      final output = '$color$logEntry$_reset';

      // Если уровень ошибки, выводим в ее в stderr
      if (level == LogLevel.error) {
        stderr.writeln(output);
      } else {
        stdout.writeln(output);
      }
    } else {
      if (level == LogLevel.error) {
        stderr.writeln(logEntry);
      } else {
        stdout.writeln(logEntry);
      }
    }
  }

  // Упрощенные методы для логирования
  void debug(String message) => log(LogLevel.debug, message);
  void info(String message) => log(LogLevel.info, message);
  void warning(String message) => log(LogLevel.warning, message);
  void error(String message) => log(LogLevel.error, message);

  // Получение списка логов
  List<String> get logs => List.unmodifiable(_logs);

  // Очистка списка логов
  void clear() => _logs.clear();

  // Создаем Zone specification для перехвата print
  ZoneSpecification createZoneSpec() {
    return ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        // Перехватываем вызов print
        // и перенаправляем его в info
        info('PRINT: $line');
      },
    );
  }
}

// Функция моделирующая выполнение операции
// с логированием результатов
Future<T> runWithLogging<T>(
  SimpleLogger logger,
  Future<T> Function() operation,
) async {
  return runZoned(() async {
    logger.info('Начало операции с логированием');

    try {
      final result = await operation();
      logger.info('Операция успешно завершена');
      return result;
    } catch (error) {
      logger.error('Ошибка при выполнении операции: $error');
      rethrow;
    }
  }, zoneSpecification: logger.createZoneSpec());
}

void main() async {
  final logger = SimpleLogger(minLevel: LogLevel.debug);

  print('\n❌ Логирование исключений ❌\n');

  try {
    await runWithLogging(logger, () async {
      logger.info('Выполнение операции с ошибкой');
      await Future.delayed(Duration(milliseconds: 50));
      throw Exception('Тестовая ошибка');
    });
  } catch (e) {
    // Ошибка уже залогирована
  }

  print('\n✅ Штатное логирование ✅\n');
  await runWithLogging(logger, () async {
    logger.debug('Инициализация бизнес-логики');
    logger.info('Подключение к базе данных');

    await Future.delayed(Duration(milliseconds: 100));

    logger.info('Загрузка конфигурации');
    logger.warning('Версия используемого API устарела!!!');

    await Future.delayed(Duration(milliseconds: 50));

    // Использование print будет перехвачено
    print('Взываем к print()');

    logger.info('Бизнес-логика выполнена');
  });

  print('\n📊 Сводка логов:');
  print('Всего записей: ${logger.logs.length}');

  final errorCount = logger.logs.where((log) => log.contains('[ERROR')).length;
  final warningCount = logger.logs
      .where((log) => log.contains('[WARNING'))
      .length;

  print('Ошибок: $errorCount, Предупреждений: $warningCount');
}
