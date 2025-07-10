import 'dart:async';

void main(List<String> arguments) async{
  print('Start');
  Future.sync(() => print('Sync'));
  print('End');
}
