import 'dart:async';

var _countCreated = 0;

Stream<int> counterStream([int max = 5]) => Stream<int>.multi((mc) {
  _countCreated++;
  if (_countCreated > 1) { // поток с единичной подпиской
    throw StateError('Only one counter allowed');
  }
  var current = 0;
  Timer? timer;
  // создаем таймер
  timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
    mc.add(current++);
    if (current > max) { // если достигнут максимум
      timer?.cancel(); // останавливаем таймер
      mc.close(); // закрываем поток
    }
  });
  // закрываем таймер при отмене потока
  mc.onCancel = () => timer?.cancel();    
});

void main() {
  var stream = counterStream();
  stream.listen((v) => print('A → $v'));
  // stream.listen((v) => print('B → $v'));
}
