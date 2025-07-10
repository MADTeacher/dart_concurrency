import 'dart:async';

/// Исключение, которое будем выбрасывать при отмене задачи
class TaskCancelledException implements Exception {
  final String message;
  const TaskCancelledException([this.message = 'Задача отменена']);
  
  @override
  String toString() => message;
}

/// Обертка для задачи, которая должна выполниться 
/// с задержкой и может быть отменена
/// [T] - тип результата, возвращаемого задачей
class CancellableDelayedTask<T> {
  final Duration delay; // время до запуска задачи
  // функция, которая будет выполнена c задержкой
  final FutureOr<T> Function() _task;
  final _completer = Completer<T>();
  Timer? _timer;

  CancellableDelayedTask(this.delay, this._task);

  /// Future, который завершится, 
  /// когда задача будет выполнена или отменена
  Future<T> get future => _completer.future;

  /// Возвращаем true, если задача была отменена
  bool get isCancelled => _completer.isCompleted;

  /// Запускаем таймер
  void run() {
    if (isCancelled) return;

    _timer = Timer(delay, () async {
      if (isCancelled) return;
      try {
        final result = await _task(); // Выполняем задачу

        // Завершаем, только если еще не было отмены
        if (!isCancelled) {
          _completer.complete(result);
        }
      } catch (e, s) { // перехватываем ошибку
        // Если не было отмены - завершаем с ошибкой
        if (!isCancelled) {
          _completer.completeError(e, s);
        }
      }
    });
  }

  /// Отменяем выполнение задачи
  void cancel([String? message]) { // message - опционально
    _timer?.cancel();
    if (!isCancelled) {
      _completer.completeError(
        TaskCancelledException(
          message ?? 'Отложенная задача отменена',
        ),
      );
    }
  }
}

Future<void> main() async {
  // Задача: через 5 секунд вернуть строку
  final delayedTask = CancellableDelayedTask<String>(
    const Duration(seconds: 5),
    () => 'Результат получен после 5 секунд ожидания.',
  );

  delayedTask.run();

  // Отменяем задачу через 2 секунды
  Future.delayed(const Duration(seconds: 2), () {
    print('🛑 Отменяем задачу...');
    delayedTask.cancel();
  });

  try {
    final result = await delayedTask.future;
    print('✅ $result');
  } on TaskCancelledException catch (e) {
    print('❌ $e');
  }
}
