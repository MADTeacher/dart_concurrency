import 'dart:async';
import 'dart:io';

Future<void> main() async {
  final stream = Stream.fromIterable([1, 2, 3, 4,5,6,7,8]);

  // take принимает на вход число, которое показывает 
  // сколько элементов из исходного потока
  // доберется до пользователя
  final myWrapperStream = stream.take(3);
  await for (final value in myWrapperStream) {
    stdout.write('$value ');
  }
  // или
  // myWrapperStream.listen(
  //   (data) => stdout.write('$data '),
  //   onError: (e) => print(e),
  //   onDone: () => print('Stream completed'),
  // );

  print('');

  // takeWhile пропускает элементы, пока анонимная 
  // функция, передаваемая аргументу test, не вернет false
  // (после чего поток автоматически закрывается)
  // или не будет достигнут конец исходного потока
  final myWrapperStream2 = stream.takeWhile((value) => value < 5);
  await for (final value in myWrapperStream2) {
    stdout.write('$value ');
  }
}
