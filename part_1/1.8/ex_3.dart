int counter = 0;

Future<void> incrementCounter() async {
  int temp = counter; 
  await Future.delayed(Duration.zero);
  counter = temp + 1;
}

void main() async {
  await  incrementCounter();
  await  incrementCounter();
  await  incrementCounter();

  print(counter); // 3
}
