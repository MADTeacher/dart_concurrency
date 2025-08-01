import 'dart:async';
import 'dart:io';

// Класс для хранения событий трассировки
class TraceEvent {
  final String type; // Тип события
  final String operation; // Имя операции
  final String? data; // Дополнительные данные
  final int depth; // Глубина вложенности
  final int timestampMs; // Время события

  TraceEvent({
    required this.type,
    required this.operation,
    this.data,
    required this.depth,
    required this.timestampMs,
  });
}

class SimpleTracer {
  // Список событий трассировки
  final List<TraceEvent> _events = [];
  // Таймер для измерения времени выполнения
  final Stopwatch _stopwatch = Stopwatch();
  // Текущая глубина вложенности
  int _depth = 0;

  // Метод трассировки операции
  Future<T> trace<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    _stopwatch.start(); // Запускаем таймер
    // Добавляем событие о начале трассировки
    _addEvent('START', operationName);

    try {
      // Запускаем зону с перехватом системных операций
      final result = await runZoned(
        operation,
        zoneSpecification: _getZoneSpecification(),
      );

      // Добавляем событие об успешном завершении
      _addEvent('SUCCESS', operationName);
      return result;
    } catch (error) {
      // Добавляем событие о завершении трассировки ошибкой
      _addEvent('ERROR', operationName, data: error.toString());
      rethrow;
    } finally {
      _stopwatch.stop(); // Останавливаем таймер
      _printReport(operationName); // Выводим отчет по трассировке
    }
  }

  // Метод для получения спецификации зоны
  ZoneSpecification _getZoneSpecification() {
    return ZoneSpecification(
      run: _traceRun,
      scheduleMicrotask: _traceMicrotask,
      createTimer: _traceTimer,
      print: _tracePrint,
    );
  }

  // Метод для добавления события трассировки
  // Принимает на вход тип события, имя операции и дополнительные данные
  void _addEvent(String type, String operation, {String? data}) {
    _events.add(
      TraceEvent(
        type: type,
        operation: operation,
        data: data,
        depth: _depth,
        timestampMs: _stopwatch.elapsedMilliseconds,
      ),
    );
  }

  // Метод для трассировки функции
  // Принимает на вход функцию и возвращает ее результат
  R _traceRun<R>(Zone self, ZoneDelegate parent, Zone zone, R Function() f) {
    _depth++;
    _addEvent('FUNCTION', f.runtimeType.toString());

    try {
      return parent.run(zone, f);
    } finally {
      _depth--;
    }
  }

  // Метод для трассировки микрозадач
  void _traceMicrotask(
    Zone self,
    ZoneDelegate parent,
    Zone zone,
    void Function() f,
  ) {
    _addEvent('MICROTASK', f.runtimeType.toString());
    parent.scheduleMicrotask(zone, f);
  }

  // Метод для трассировки таймера
  Timer _traceTimer(
    Zone self,
    ZoneDelegate parent,
    Zone zone,
    Duration duration,
    void Function() f,
  ) {
    _addEvent('TIMER', '${duration.inMilliseconds}ms');
    return parent.createTimer(zone, duration, f);
  }

  // Метод для трассировки обращения к print
  void _tracePrint(Zone self, ZoneDelegate parent, Zone zone, String line) {
    _addEvent('PRINT', line);
    parent.print(zone, line);
  }

  // Метод для вывода отчета трассировки
  void _printReport(String operationName) {
    stdout.writeln('\n🔍 Отчет трассировки: $operationName');
    stdout.writeln('=' * 50);
    stdout.writeln('Общее время: ${_stopwatch.elapsedMilliseconds}ms');
    stdout.writeln('Всего событий: ${_events.length}');

    for (final event in _events) {
      final indent = '  ' * event.depth;
      final timeStr = '[${event.timestampMs.toString().padLeft(4)}ms]';
      final typeStr = event.type.padRight(9);
      final dataStr = event.data != null ? ' (${event.data})' : '';

      stdout.writeln('$timeStr $indent$typeStr ${event.operation}$dataStr');
    }
  }

  // Геттер для доступа к событиям трассировки
  List<TraceEvent> get events => List.unmodifiable(_events);

  // Метод для очистки событий трассировки
  void clear() => _events.clear();
}

// Моделирование сложной асинхронной операции
Future<String> simulateComplexOperation() async {
  print('Начало сложной операции');

  await Future.delayed(Duration(milliseconds: 100));
  print('Инициализация');

  scheduleMicrotask(() {
    print('Микрозадача: Очистка кэша');
  });

  Timer(Duration(milliseconds: 50), () {
    print('Таймер: Периодическая проверка');
  });

  await Future.delayed(Duration(milliseconds: 150));
  print('Обработка данных');

  return 'Операция завершена успешно';
}

// Моделирование сетевого запроса
Future<void> simulateNetworkCall() async {
  print('Выполнение сетевого запроса');
  await Future.delayed(Duration(milliseconds: 200));

  if (DateTime.now().millisecond % 3 == 0) {
    throw Exception('Сетевая ошибка');
  }

  print('Сетевой запрос выполнен');
}

void main() async {
  final tracer = SimpleTracer();

  print('👀 Трассировка сложной операции:');

  await tracer.trace('complex_operation', () async {
    return await simulateComplexOperation();
  });

  await Future.delayed(Duration(milliseconds: 300));

  print('\n👀 Трассировка сетевого запроса:');

  try {
    await tracer.trace('network_call', () async {
      await simulateNetworkCall();
    });
  } catch (e) {
    // Ошибка уже залогирована трассировщиком
  }
}
