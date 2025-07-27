import 'dart:async';

void main() async {
  await runZonedGuarded( // можно и без await
    () async {
      Future.error('^_^');
    },
    (Object error, StackTrace stackTrace) {
      print('error: $error');
    }
  );
  print('Завершение программы');
}
