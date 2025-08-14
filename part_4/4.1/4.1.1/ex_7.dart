import 'dart:isolate';

Future<int> div(int a, int b) {
  return Isolate.run(() async {
    int result = 0;
    if (b == 0) {
      Future.error(ArgumentError('b == 0'));
    }
    result = a ~/ b;

    // Держим computation, чтобы Future.error успел выполниться
    await Future.delayed(Duration.zero);
    return result; // При b == 0 код не будет выполнен
  });
}

void main() async {
  try {
    final x = await div(4, 0);
    print('Результат: $x');
  } catch (e, st) {
    if (e is RemoteError) {
      // RemoteError содержит текст исходного исключения и
      // "удаленный" стек трейс из изолята
      print('[${e.runtimeType}] $e');
      print('StackTrace:\n $st');
    }
  }
}
