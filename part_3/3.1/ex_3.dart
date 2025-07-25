import 'dart:async';

void main() {
  print('start');
  Future(() {
    print('[${Zone.current}] future1 run and finished');
  });

  final future = Future(() {
    print('[${Zone.current}] future2 run');
  });

  runZoned(() {
    // создаем дочернюю зону
    print('run zone: ${Zone.current}');
    future.then((value) {
      print('[${Zone.current}] future2 finished');
    });
    // Выполним синхронный код вне дочерней зоны
    // перекинув его в корневую
    Zone.root.run(() {
      // запускаем код в зоне
      print('run in root zone: ${Zone.current}');
    });
  });
  print('end');
}
