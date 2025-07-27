import 'dart:async';

// Интерцептора для отслеживания пользовательских
// асинхронных callback-функций
class CallbackInterceptor {
  final Set<Function> _userCallbacks = {};
  int _callbackCounter = 0;

  // Регистрируем пользовательский callback и возвращаем его обернутую
  // в логирующую функцию версию
  T registerUnaryUserCallback<T extends Function>(T callback, String type) {
    _callbackCounter++;
    print('✅ Зарегестрирован user callback #$_callbackCounter: $type');

    // Проверяем тип функции и создаем соответствующую обертку
    T wrappedCallback;
    
    if (callback is void Function(dynamic)) {
      // Обработка void функций с одним аргументом
      wrappedCallback = ((dynamic arg) {
        print('🎯 Выполняется $type с аргументом: $arg');
        callback(arg);
      }) as T;
    } else if (callback is dynamic Function(dynamic)) {
      // Обработка функций с возвращаемым значением
      wrappedCallback = ((dynamic arg) {
        print('🎯 Выполняется $type с аргументом: $arg');
        return callback(arg);
      }) as T;
    } else {
      throw ArgumentError('Неподдерживаемый тип callback-функции');
    }

    // Регистрируем обернутый callback как пользовательский
    _userCallbacks.add(wrappedCallback);

    return wrappedCallback;
  }

  // Проверяем, является ли callback пользовательским
  bool isUserCallback(Function callback) {
    return _userCallbacks.contains(callback);
  }

  // Получаем статистику по количеству
  // пользовательских callback-функций
  int get userCallbackCount => _callbackCounter;
}

void main() {
  final interceptor = CallbackInterceptor();

  // Создаем ZoneSpecification с перехватом всех типов callback-функций
  final zoneSpec = ZoneSpecification(
    // Данный обработчик перехватывает запуск асинхронных
    // callback-функций с одним аргументом
    runUnary:
        <R, T>(
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          R Function(T) f,
          T arg,
        ) {
          // Проверяем, является ли перехваченная функция пользовательской
          // и если да, то замеряем время ее выполнения
          if (interceptor.isUserCallback(f)) {
            print('\n🔍 Перехвачен user callback $f');
            final stopwatch = Stopwatch()..start();
            final result = parent.runUnary(zone, f, arg);
            stopwatch.stop();
            print('⏰ Время выполнения: ${stopwatch.elapsed}\n');
            return result;
          }
          // Остальные callback-функции передаем дальше без изменений
          return parent.runUnary(zone, f, arg);
        },
  );

  runZoned(() async {
    // Регистрируем пользовательский callback
    final futureCallback = interceptor.registerUnaryUserCallback((data) {
      print('⏰ Future выполнен c аргументом: $data');
    }, 'Future.then');
    // Передаем пользовательскую callback-функцию в Future.then
    Future.value('^_^').then(futureCallback);

    // Регистрируем пользовательский callback для Stream
    final streamCallback = interceptor.registerUnaryUserCallback((data) {
      print('⏰ В stream поступили данные: $data');
    }, 'Stream.listen(onData)');

    final controller = StreamController<int>();
    // Передаем пользовательскую callback-функцию в Stream.listen
    controller.stream.listen(streamCallback);

    controller.add(36);
    controller.add(90);
    await controller.close();

    print('');
    print(
      'Зарегистрировано ${interceptor.userCallbackCount}'
      ' callback-функций',
    );
  }, zoneSpecification: zoneSpec);
}
