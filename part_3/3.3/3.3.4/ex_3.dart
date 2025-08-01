import 'dart:async';
import 'dart:io';

class SimpleProfiler {
  // Таблица для сбора статистики
  final Map<String, List<Duration>> _metrics = {};

  // Метод профилирования операций
  // Принимает на вход название и функцию-операции,
  // чей результат будет возвращен
  Future<T> profile<T>(String name, Future<T> Function() operation) async {
    // Стартуем таймер профилирования
    final stopwatch = Stopwatch()..start();

    try {
      // Пытаемся выполнить операцию
      final result = await operation();
      stopwatch.stop(); // Останавливаем таймер

      // Записываем результат в таблицу
      _recordMetric(name, stopwatch.elapsed);
      // Выводим результат профилирования в терминал
      _logMetric(name, stopwatch.elapsed, success: true);

      return result; // Возвращаем результат
    } catch (error) {
      // Если произошла ошибка - останавливаем таймер
      stopwatch.stop();

      _recordMetric(name, stopwatch.elapsed);
      _logMetric(name, stopwatch.elapsed, success: false, error: error);

      rethrow; // Передаем ошибку на уровень выше
    }
  }

  // Метод для записи результатов в таблицу
  void _recordMetric(String name, Duration duration) {
    _metrics.putIfAbsent(name, () => []).add(duration);
  }

  // Метод для вывода результатов операции в терминал
  void _logMetric(
    String name, // Название операции
    Duration duration, { // Время выполнения
    bool success = true, // Успешно ли выполнена?
    Object? error, // Данные об ошибке
  }) {
    final ms = duration.inMicroseconds / 1000;
    final status = success ? '✅' : '❌';
    final errorInfo = error != null ? ' (Error: $error)' : '';

    stdout.writeln(
      '$status $name: ${ms.toStringAsFixed(2)}'
      'ms$errorInfo',
    );
  }

  // Метод для вывода результатов профилирования
  void printSummary() {
    if (_metrics.isEmpty) {
      print('Нет данных для отображения');
      return;
    }

    print('\n📊 Сводка производительности:');
    print('=' * 40);

    for (final entry in _metrics.entries) {
      final name = entry.key;
      final durations = entry.value;
      // Среднее время выполнения
      final avgMs =
          durations
              .map((d) => d.inMicroseconds / 1000)
              .reduce((a, b) => a + b) /
          durations.length;
      // Минимальное время выполнения
      final minMs = durations
          .map((d) => d.inMicroseconds / 1000)
          .reduce((a, b) => a < b ? a : b);
      // Максимальное время выполнения
      final maxMs = durations
          .map((d) => d.inMicroseconds / 1000)
          .reduce((a, b) => a > b ? a : b);

      print('🔹 $name:');
      print('   Выполнений: ${durations.length}');
      print('   Среднее: ${avgMs.toStringAsFixed(2)}ms');
      print(
        '   Мин/Макс: ${minMs.toStringAsFixed(2)}ms /'
        ' ${maxMs.toStringAsFixed(2)}ms',
      );
    }
  }

  // Метод для очистки результатов профилирования
  void clear() => _metrics.clear();
}

// Функция для моделирования различных обращений к серверу
Future<String> simulateApiCall(String endpoint, {int delayMs = 200}) async {
  await Future.delayed(Duration(milliseconds: delayMs));
  if (endpoint == 'error') {
    throw Exception('API Error');
  }
  return 'Response from $endpoint';
}

void main() async {
  final profiler = SimpleProfiler();

  await profiler.profile('stasko_operation', () async {
    await profiler.profile('step_1', () async {
      return await simulateApiCall('/step1', delayMs: 60);
    });

    await profiler.profile('step_2', () async {
      return await simulateApiCall('/step2', delayMs: 40);
    });

    await profiler.profile('step_2', () async {
      return await simulateApiCall('/step2', delayMs: 100);
    });

    return 'Stasko operation completed';
  });

  profiler.printSummary();
}
