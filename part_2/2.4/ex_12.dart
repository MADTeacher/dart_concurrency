import 'dart:async';

Stream<int> counterStream([int max = 5]) {
  // Список всех активных MultiStreamController, 
  // а по сути — подписчиков на поток
  final listeners = <MultiStreamController<int>>[];
  int current = 0;
  Timer? timer;

  // tick вызывается по таймеру, рассылает значение всем подписчикам
  void tick(_) {
    print('tick: $current');
    // Копируем список, чтобы избежать ошибок при удалении 
    // из listeners во время обхода
    for (final mc in List<MultiStreamController<int>>.from(listeners)) {
      mc.add(current);
    }
    current++;
    // Когда достигнут максимум — закрываем поток для всех
    if (current > max) {
      timer?.cancel();
      for (final mc in List<MultiStreamController<int>>.from(listeners)) {
        mc.close();
      }
      listeners.clear();
    }
  }

  // Каждый новый слушатель добавляется в список listeners
  // Таймер запускается только при подключении первого слушателя
  return Stream<int>.multi((mc) {
    listeners.add(mc);
    if (listeners.length == 1) {
      timer = Timer.periodic(const Duration(milliseconds: 300), tick);
    }
    // При отмене подписки удаляем слушателя из списка
    mc.onCancel = () {
      listeners.remove(mc);
      if (listeners.isEmpty) {
        timer?.cancel();
        timer = null;
      }
    };
  }, isBroadcast: true);
}

void main() async{
  var stream = counterStream();
  stream.listen((v) => print('A → $v'));
  Future.delayed(Duration(seconds: 1),(){
    stream.listen((v) => print('B → $v'));
  });
} 




