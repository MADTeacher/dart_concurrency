import 'dart:math' as math;

Stream<double> simulatedSensor({
  Duration period = const Duration(milliseconds: 500),
}) {
  // Подписка ограничена 20 событиями в потоке 
  return Stream<double>.periodic(period, (tick) {
    // Рассчитываем следующее значение «температуры»
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
    return 37.0 + 5.0 * math.sin(t);
  }).take(20);
}

void main() async {
  final sub = simulatedSensor().listen(
    (v) => print('T = ${v.toStringAsFixed(2)} °C'),
    onDone: () => print('Stream completed'),
  );
  // При необходимости можно отменить раньше:
  // await Future.delayed(Duration(seconds:3));
  // await sub.cancel();
}
