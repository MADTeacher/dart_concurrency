import 'dart:isolate';

void main() async {
  var (a, b) = (1, 1);

  final result = await Isolate.run(() {
    // Замыкание, т.к. мы захватываем
    // переменные объемлющей области видимости, которые неявно
    // сереализуются и передаются в порождаемый изолят
    return a + b;
  });
  print(result); // 2

  final result2 = await Isolate.run(() {
    // Не замыкание, т.к. работаем только
    // с переменными своей области видимости
    return 1 + 1;
  });
  print(result2); // 2
}
