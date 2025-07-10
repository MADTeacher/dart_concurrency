int counter = 0;

Future<void> incrementCounter() async {
  // записываем значение счетчика во временную переменную
  int temp = counter; 
  // ожидаем завершения асинхронной операции
  await Future.delayed(Duration.zero);
  counter = temp + 1; // увеличиваем счетчик
}

void main() async {
  await Future.wait([ // запускаем 3 задачи
    incrementCounter(),
    incrementCounter(),
    incrementCounter(),
  ]);

  print(counter); // 1
}
