import 'dart:async';

/// Кастомное исключение для демонстрации
final class WtfError implements Exception {
  const WtfError();
}

/// Функция, возвращающая Future, 
/// который завершится с ошибкой после задержки
Future<void> foo() async {
  final completer = Completer<void>();
  
  completer.future.onError<WtfError>((_, _) {
    print('Обработано исключение WtfError!');
  });

  completer.completeError(const WtfError());

  // Имитируем задержку
  await Future<void>.delayed(const Duration(seconds: 1));

  // Ожидаем результат completer'а
  return await completer.future;
}

void main() {
  runZonedGuarded(() async {
    try {
      await foo();
      print('Все хорошо!');
    } on WtfError {
      print('Поймано ожидаемое исключение WtfError');
    } catch (e, s) {
      print('Произошло неожиданное исключение: $e');
    }
  }, (error, stackTrace) {
    print('Необработанная ошибка: $error');
  });
}
