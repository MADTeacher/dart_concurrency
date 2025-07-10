int add(int a, int b) => a + b;

Future<int> getData(int a, int b) => Future.value(add(a, b));

void main(List<String> arguments) {
  getData(1, 2).then((value) => print(value)); // 3
}
