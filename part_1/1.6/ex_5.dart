void main() async{
  print('Запуск main');

  var count = 0;
  Future.doWhile(() async {
    print('count = $count');
    count++;
    await Future.delayed(Duration(milliseconds: 500));
    return count <= 4;
  });
  print('Завершение main');
} 
