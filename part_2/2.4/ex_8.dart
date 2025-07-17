import 'dart:async';

void main(List<String> arguments) async {
  final squares = Stream<int>.periodic(
    const Duration(seconds: 1),
    (n) => n * n,
  ).take(5); // Создаем поток, содержащий первые 5 событий исходного потока
  squares.listen(print); // 0, 1, 4, 9, 16
}
