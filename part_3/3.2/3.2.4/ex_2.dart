import 'dart:async';

// Интерцептора для отслеживания пользовательских 
// асинхронных callback-функций
class CallbackInterceptor {
  final Set<Function> _userCallbacks = {};
  int _callbackCounter = 0;

  // Регистрируем пользовательский callback и возвращаем его обернутую
  // в логирующую функцию версию
  T registerUserCallback<T extends Function>(T callback, String type) {
    _callbackCounter++;
    print('✅ Зарегестрирован user callback #$_callbackCounter: $type');

    // Создаем обертку для логирования выполнения callback
    dynamic wrappedCallback;
    // если callback-функция не принимает параметры
    if (callback is void Function()) {
      wrappedCallback = () {
        print('🎯 Выполняется пользовательский $type');
        callback();
      };
    } else {
      throw ArgumentError('Неподдерживаемый тип callback-функции');
    }

    // Регистрируем обернутый callback как пользовательский
    _userCallbacks.add(wrappedCallback);

    return wrappedCallback as T;
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
    // Данный обработчик перехватывает регистрацию асинхронных
    // callback-функций без параметров (например, () => void)
    registerCallback:
        <R>(Zone self, ZoneDelegate parent, Zone zone, R Function() f) {
          // Проверяем, является ли перехваченая регистрируемая
          // асинхронная callback-функция пользовательской
          if (interceptor.isUserCallback(f)) {
            print('🔍 Перехвачен user callback');
          }

          // Все колбэки передаем дальше без изменений
          return parent.registerCallback(zone, f);
        },
  );

  runZoned(() async {
    // Регистрируем пользовательский callback
    final timerCallback = interceptor.registerUserCallback(() {
      print('⏰ Timer сработал!');
    }, 'Timer');
    // Запускаем таймер c пользовательской callback-функцией
    Timer(Duration(milliseconds: 10), timerCallback);

    final microtaskCallback = interceptor.registerUserCallback(() {
      print('⚡ Microtask выполнен!');
    }, 'Microtask');
    scheduleMicrotask(microtaskCallback);

    final futureCallback = interceptor.registerUserCallback(() {
      print('⏰ Future выполнен!');
    }, 'Future.delayed');
    Future.delayed(Duration(milliseconds: 15), futureCallback);

    print('');
    print(
      'Зарегистрировано ${interceptor.userCallbackCount}'
      ' callback-функций',
    );
  }, zoneSpecification: zoneSpec);
}
