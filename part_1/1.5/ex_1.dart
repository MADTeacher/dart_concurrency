import 'dart:async';

/// Исключение, которое будем выбрасывать при отмене задачи
class CancelledException implements Exception {
  const CancelledException([this.message = 'Задача была отменена']);
  final String message;

  @override
  String toString() => message;
}

/// Обертка над асинхронной задачей, позволяющая ее отменить
/// [T] - тип результата, возвращаемого задачей
class CancellableTask<T> {
  // Асинхронная функция на выполнение
  final Future<T> Function() _task; 
  final _completer = Completer<T>();

  CancellableTask(this._task);

  /// Future, который завершится, 
  /// когда задача будет выполнена или отменена
  Future<T> get future => _completer.future;

  /// Возвращаем true, если задача была отменена
  bool get isCancelled => _completer.isCompleted;

  /// Запускаем выполнение задачи
  void run() {
    // Не запускаем, если уже отменено
    if (isCancelled) return;

    // Выполняем переданную задачу
    _task()
        .then((result) {
          // Завершаем, только если еще не было отмены
          if (!isCancelled) {
            _completer.complete(result);
          }
        })
        .catchError((error, stackTrace) { // перехватываем ошибку
          // сли не было отмены - завершаем с ошибкой
          if (!isCancelled) {
            _completer.completeError(error, stackTrace);
          }
        });
  }

  /// Отменяем задачу
  void cancel([String? message]) { // message - опционально
    if (!isCancelled) {
      _completer.completeError(
        CancelledException(message ?? 'Задача отменена'),
      );
    }
  }
}

/// Функция, имитирующая долгую загрузку данных 
/// и возвращающая строку
Future<String> fetchData() async {
  print('Начинаем загрузку данных...');
  await Future.delayed(const Duration(seconds: 5));
  print('Данные загружены!');
  return 'Это результат из сети';
}

Future<void> main() async {
  // Создаем обертку над задачей fetchData
  final cancellableFetch = CancellableTask<String>(fetchData);

  // Запускаем задачу
  cancellableFetch.run();

  // Отменяем ее через 2 секунды
  Future.delayed(const Duration(seconds: 2), () {
    print('→ Отменяем загрузку данных...');
    cancellableFetch.cancel();
  });

  try {
    final result = await cancellableFetch.future;
    print('✅ Результат: $result');
  } on CancelledException catch (e) {
    print('❌ Перехвачена отмена: $e');
  }
}
