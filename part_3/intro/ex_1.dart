import 'dart:async';

void main() async{
  print('start');
  try {
    // ошибка выброшенная в цикле событий
    // не перехватится, т.к. на Future не повесили
    // обработчик onError
    Future.error(ArgumentError('^_^'));
  } catch (e) {
    // не выполнится
    print(e);
  }
  await Future.delayed(Duration(seconds: 1));
  print('end'); // не выполнится
}
