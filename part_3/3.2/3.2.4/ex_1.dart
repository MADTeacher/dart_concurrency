import 'dart:async';

void main() {
  // Создаем ZoneSpecification с перехватом всех типов callback-функций
  final zoneSpec = ZoneSpecification(
    // Данный обработчик перехватывает регистрацию асинхронных
    // callback-функций без параметров (например, () => void)
    registerCallback:
      <R>(Zone self, ZoneDelegate parent, Zone zone, R Function() f) {
          print('📝 registerCallback');
          // Оборачиваем оригинальный callback в логирующую
          // функцию-замыкание wrappedCallback
          R wrappedCallback() {
            print('🔄 Выполняется callback без параметров');
            return f();
          }

          // Передаем wrappedCallback на обработку в родительскую зону
          // и возвращаем результат
          return parent.registerCallback(zone, wrappedCallback);
        },
  );

  runZoned(() async {
    Timer(Duration(milliseconds: 5), () {
      print('⏰ Timer сработал!\n');
    });

    scheduleMicrotask(() {
      print('⚡ Microtask выполнен!\n');
    });

    Future.delayed(Duration(milliseconds: 5), () {
      print('⏰ Future выполнен!\n');
    });
    
    print('');
  }, zoneSpecification: zoneSpec);
}
