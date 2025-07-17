import 'dart:async';
import 'dart:math';

extension RepeatLatest<T extends Object> on Stream<T> {
  Stream<T> repeatLatest() {
    T? latest;
    var done = false;
    final listeners = <MultiStreamController<T>>{};

    // "Слушаем" исходный поток и рассылаем данные текущим слушателям
    // посредством синхронных методов addSync(), addErrorSync() и closeSync().
    // При использовании асинхронных методов add(), addError() и close()
    // события будут доставлены с задержкой в следующем цикле событий,
    // при обработке очереди микрозадач
    listen(
      (e) {
        latest = e;
        for (final l in [...listeners]) {
          l.addSync(e);
        }
      },
      onError: (e, st) {
        for (final l in [...listeners]) {
          l.addErrorSync(e, st);
        }
      },
      onDone: () {
        done = true;
        for (final l in [...listeners]) {
          l.closeSync();
        }
        listeners.clear();
      },
    );

    return Stream.multi((mc) {
      if (done) {
        mc.closeSync(); // закрываем поток
      } else {
        listeners.add(mc); // добавляем слушателя
        if (latest != null) {
          mc.addSync(latest!); // мгновенно отдаем кеш
        }
        // закрываем поток при отмене подписки
        mc.onCancel = () => listeners.remove(mc);
      }
    }, isBroadcast: true);
  }
}

// Возвращаем поток, регулирующий количество свободных мест на курсе
Stream<int> seatAvailability({
  required int capacity, // максимальное количество мест
  Duration period = const Duration(milliseconds: 200),
  int updates = 10, // количество обновлений
}) {
  final rng = Random(42);
  return Stream<int>.periodic(period, (tick) {
    // Количество свободных мест плавно колеблется:
    final delta = rng.nextInt(3) - 1; // −1, 0, +1
    return (capacity - tick + delta).clamp(0, capacity);
  }).take(updates).repeatLatest(); // ← подключаем расширение
}

Future<void> main() async {
  final seats = seatAvailability(capacity: 30);

  // Подписка #1: деканат видит поток сразу
  seats.listen((v) => print('Деканат: свободно $v мест'));

  // Подписка #2: студент подключается через 1 с
  // и первым делом получает кеш
  Future.delayed(const Duration(milliseconds: 1000), () {
    seats.listen((v) {
      print('Студент1: свободно $v мест (обновл.)');
    });
  });

  // Подписка #2: студент подключается через 1.5 с
  Future.delayed(
    const Duration(milliseconds: 1500),
    () => seats.listen((v) {
      print('Студент2: свободно $v мест (обновл.)');
    }),
  );
}
