import 'dart:isolate';

int add(int a, int b) => a + b;

void main() async {
  var (a, b) = (1, 1);
  // Запускаем изолят для суммы a и b
  // и ждем завершение работы
  final result = await Isolate.run(() {
    // Значение переменных a и b
    // захватывается из пространства
    // главного (порождающего) изолята
    return a + b;
  });
  print(result); // 2

  // Вызываем функцию add в callback-функции
  // порождаемого изолята и ждем завершение работы
  final result2 = await Isolate.run(() => add(a, b));
  print(result2); // 2

  func() => a + b; // объявляем вложенную функцию и
  // передаем ее в качестве callback-функции на
  // вход Isolate.run
  final result3 = await Isolate.run(func);
  print(result3); // 2

  // Так как у каждого изолята свой цикл событий,
  // мы можем внутри передаваемой callback-функции
  // вызывать асинхронный код
  final result4 = await Isolate.run(() async {
    final c = await Future(() => a + b);
    print('[${Isolate.current.debugName}] result =  $c');
    // [^_^]    result =  2

    return c;
  }, debugName: '^_^');
  print(result4); // 2
}
