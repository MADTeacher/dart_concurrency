import 'dart:async';

Future<int> add(int a, int b) async {
  if (a == 0) {
    return Future.error(ArgumentError());
  } else {
    return a + b;
  }
}

void main(List<String> arguments) async{
  var future = add(0, 2);
  // обрабатываем ошибку с помощью Future API
  future
      .then((result) => print('Result: $result'))
      .catchError(
        (error) => print('Future API catch error: $error'),
        test: (error) => error is ArgumentError,
      );
      // Future API catch error: Invalid argument(s)

  // Обрабатываем ошибку с помощью try-catch
  try {
    var result = await future;
    print('Result: $result');
  } on ArgumentError catch (error) {
    print('Try-catch error: $error'); 
  }

  // не обрабатываем ошибку – экстренное завершение работы приложения
  var result = await future;
  print('Result: $result');
}
