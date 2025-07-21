import 'dart:async';
import 'dart:io';

Future<void> main() async {
  final stream = Stream.fromIterable([1, 2, 3, 4,5,6,7,8]);

  // skip принимает на вход число, которое показывает 
  // сколько элементов нужно пропустить
  final myWrapperStream = stream.skip(3);
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

  // skipWhile пропускает элементы, пока анонимная 
  // функция, передаваемая аргументу test, не вернет true
  final myWrapperStream2 = stream.skipWhile((value) => value < 5);
  await for (final value in myWrapperStream2) {
    stdout.write('$value ');
  }
}
