import 'dart:async';

Stream<int> counterStream([int max = 5]) => Stream<int>.multi((mc) {
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

void main() async{
  var stream = counterStream();
  stream.listen((v) => print('A → $v'));
  Future.delayed(Duration(milliseconds: 500),(){
    stream.listen((v) => print('B → $v'));
  });
}
