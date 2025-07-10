int counter = 0;

Future<void> incrementCounter() async {
  int temp = counter; 
  counter = temp + 1;
}

void main() async {
  await Future.wait([ // запускаем 3 операции
    incrementCounter(),
    incrementCounter(),
    incrementCounter(),
  ]);

  print(counter); // 3
}
