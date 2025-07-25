import 'dart:async';

void main() async {
  print('start');
  runZonedGuarded(
    () {
      print('[${Zone.current}] throw error');
      throw ArgumentError('^_^');
    },
    (e, st) {
      // обрабатываем ошибки в родительской зоне
      if (e is ArgumentError) {
        print('[${Zone.current}] Catch error: ${e.message}');
      }
    },
  );

  await Future.delayed(Duration(seconds: 1));
  print('end'); // теперь выполнится
}
