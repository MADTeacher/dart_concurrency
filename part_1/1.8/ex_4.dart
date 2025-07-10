import 'dart:async';

/// Класс Mutex гарантирует, что только одна функция, 
/// обернутая в synchronized, выполнится в один момент времени
class Mutex {
  Future<void> _last = Future.value();

  /// Возвращаем Future, который завершается результатом выполнения [func].
  /// Если [func] бросает исключение, оно передается в возвращаемый Future,
  /// а мьютекс корректно освобождается.
  Future<T> synchronized<T>(FutureOr<T> Function() func) {
    // Запоминаем последний Future
    final previous = _last;
    // Создаем новый Completer
    final completer = Completer<void>();
    // Запоминаем новый Future
    _last = completer.future;

    // Метод synchronized выполняет функцию func после того, как все 
    // предыдущие операции, вызванные через synchronized, завершатся
    return previous.then((_) async { 
      try { 
        // Запускаем func после завершения previous
        return await func();
      } finally {
        // Освобождаем мьютекс, чтобы следующая задача могла начаться
        completer.complete();
      }
    });
  }
}

int counter = 0;
final mutex = Mutex(); // Должен быть объявлен глобально

Future<void> incrementCounter() async {
  // Синхронизируем доступ к counter
  await mutex.synchronized(() async {
    int temp = counter; 
    await Future.delayed(Duration.zero);
    counter = temp + 1; 
  });
}

void main() async {
  await Future.wait([
    incrementCounter(),
    incrementCounter(),
    incrementCounter(),
  ]);

  print(counter); // 3
}
