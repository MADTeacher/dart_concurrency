import 'dart:async';

void main(List<String> arguments) {
  // Откладываем размещение задачи в очереди событий на 5 секунд
  Future.delayed(Duration(seconds: 5), (){
    print('O_O');
  });

  // Равносильно Future(() => print('O_O'));
  // т.к. Future сразу встанет в очередь событий
  Future.delayed(Duration.zero, (){
    print('^_^');
  });
}
