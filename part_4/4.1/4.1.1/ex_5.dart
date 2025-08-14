import 'dart:isolate';

void main() async {
  var (a, b) = (1, 1);
  var port = ReceivePort();

  final result = await Isolate.run(() {
    // вот тут будет runtime exception
    return a + b;
  });
  print(result); // 2

  await Isolate.run(() {
    // Замыкание, приводящее к runtime exception в первом изоляте
    // приложения. Это связано с тем, что
    // мы захватываем переменную объемлющей области
    // видимости, которую нельзя передавать между изолятами
    print(port.isEmpty);
  });
  port.close();
}
