import 'dart:isolate';

Future<int> div(int a, int b) {
  return Isolate.run(() {
    if (b == 0) {
      throw ArgumentError('b == 0');
    }
    return a ~/ b;
  });
}

void main() async {
  // оборачиваем функцию, запускающую новый изолят
  // в блок try-catch
  try {
    final x = await div(4, 0);
    print('Результат: $x');
  } catch (e, st) {
    // Перехватываем исключение
    print('[${e.runtimeType}] $e');
    print('StackTrace:\n$st');
  }
}
