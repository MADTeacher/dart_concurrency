import 'dart:async';

void main() async {
  print('start');
  runZonedGuarded(
    () {
      // создаем пользовательскую зону
      try {
        print('[${Zone.current}] throw error');
        Future.error(ArgumentError('^_^'));
      } catch (e) {
        // не выполнится
        print(e);
      }
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
