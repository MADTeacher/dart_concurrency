import 'dart:async';

void caller(Function() callback) {}

FutureOr<void> oops() {
  throw Exception('^_^'); // ← синхронно выбрасываем исключение
}

void main() async {
  try {
    oops(); // ← никакого `await`
  } catch (e) { // ошибка будет поймана
    print('❌ Ошибка поймана в caller'); 
  }
}
