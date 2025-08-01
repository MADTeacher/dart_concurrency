import 'dart:async';

class ZoneProfiler {
  // Таблица для сбора статистики
  final Map<String, List<Duration>> _metrics = {};
  int _timerCount = 0; // счетчик таймеров
  int _microtaskCount = 0; // счетчик микрозадач

  // Метод для профилирования операций, который
  // создает зону с перехватом системных операций
  Future<T> profile<T>(String name, Future<T> Function() callback) async {
    // Стартуем таймер профилирования
    final stopwatch = Stopwatch()..start();

    // Стартуем зону профилирования
    return await runZoned<Future<T>>(
      () async {
        try {
          // Пытаемся выполнить операцию
          print('🚀 Начало операции: $name');
          final result = await callback();

          stopwatch.stop(); // Останавливаем таймер
          // Записываем результат в таблицу
          _recordMetric(name, stopwatch.elapsed);
          // Выводим результат профилирования в терминал
          _logMetric(name, stopwatch.elapsed, success: true);

          return result; // Возвращаем результат
        } catch (error) {
          // Если произошла ошибка - останавливаем таймер
          stopwatch.stop();
          _recordMetric(name, stopwatch.elapsed);
          _logMetric(name, stopwatch.elapsed, success: false, error: error);
          rethrow; // Передаем ошибку на уровень выше
        }
      },
      // Конфигурируем перехват системных операции
      zoneSpecification: _getZoneSpecification(),
    );
  }

  // Метод для получения спецификации зоны профилирования
  ZoneSpecification _getZoneSpecification() {
    return ZoneSpecification(
      // Перехватываем создание таймеров
      createTimer:
          (
            Zone self,
            ZoneDelegate parent,
            Zone zone,
            Duration duration,
            void Function() callback,
          ) {
            _timerCount++;
            print(
              '  ⏰ Создан таймер #$_timerCount: ${duration.inMilliseconds}ms',
            );
            return parent.createTimer(zone, duration, callback);
          },
      // Перехватываем создание периодических таймеров
      createPeriodicTimer:
          (
            Zone self,
            ZoneDelegate parent,
            Zone zone,
            Duration period,
            void Function(Timer) callback,
          ) {
            print(
              '  🔄 Создан периодический таймер: ${period.inMilliseconds}ms',
            );
            return parent.createPeriodicTimer(zone, period, callback);
          },
      // Перехватываем планирование микрозадач
      scheduleMicrotask:
          (
            Zone self,
            ZoneDelegate parent,
            Zone zone,
            void Function() callback,
          ) {
            _microtaskCount++;
            print('  ⚡ Запланирована микрозадача #$_microtaskCount');
            return parent.scheduleMicrotask(zone, callback);
          },
      // Перехватываем print для логирования
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        // Рассчитываем текущее время
        final timestamp = DateTime.now().toIso8601String().substring(11, 23);
        // Выводим в терминал
        parent.print(zone, '[$timestamp] ZONE_PRINT: $line');
      },
    );
  }

  // Метод для записи результатов в таблицу
  void _recordMetric(String name, Duration duration) {
    _metrics.putIfAbsent(name, () => []).add(duration);
  }

  // Метод для вывода результатов операции в терминал
  void _logMetric(
    String name,
    Duration duration, {
    bool success = true,
    Object? error,
  }) {
    final ms = duration.inMicroseconds / 1000;
    final status = success ? '✅' : '❌';
    final errorInfo = error != null ? ' ($error)' : '';
    print('$status [$name] завершено за ${ms.toStringAsFixed(2)}ms$errorInfo');
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
  final profiler = ZoneProfiler();

  // несколько раз вызываем профилирование для
  // операции user_login
  await profiler.profile('user_login', () async {
    print('Начинаем аутентификацию'); // print перехватится
    await Future.delayed(Duration(milliseconds: 150));
    scheduleMicrotask(() => print('Микрозадача выполнена'));
    return await simulateApiCall('/auth/login', delayMs: 100);
  });

  await profiler.profile('user_login', () async {
    await Future.delayed(Duration(milliseconds: 50));
    return await simulateApiCall('/auth/login', delayMs: 150);
  });

  // один раз вызываем профилирование для
  // операции load_profile
  await profiler.profile('load_profile', () async {
    print('Начинаем загрузку профиля'); // print перехватится
    await Future.delayed(Duration(milliseconds: 100));
    return await simulateApiCall('/user/profile', delayMs: 100);
  });

  // профилирование с генерацией ошибок
  print('\n Профилирование с генерацией ошибок');
  try {
    await profiler.profile('error_operation', () async {
      print('Пытаемся выполнить операцию с ошибкой');
      await Future.delayed(Duration(milliseconds: 50));
      return await simulateApiCall('error', delayMs: 25);
    });
    print('Операция завершилась успешно (не должно печататься)');
  } catch (e) {
    // Ошибка уже залогирована профилировщиком
  }

  profiler.printSummary();
}
