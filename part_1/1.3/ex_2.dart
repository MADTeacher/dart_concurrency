import 'dart:async';
import 'dart:io';

void bad(int count) {
  Future.delayed(Duration(milliseconds: 500), () {
   // вызов функции, запрос на бэк и т.д.
    stdout.write('|');
    if (count >= 10) {
      return;
    }
    bad(count + 1); // рекурсивно запускаем снова
  });
}

void good() {
  var count = 0;
  Timer.periodic(Duration(milliseconds: 500), (Timer timer) {
    // вызов функции, запрос на бэк и т.д.
    stdout.write('*');
    count++;
    if (count >= 10) {
      timer.cancel();
    }
  });
}

void main(List<String> arguments) async {
  bad(0);
  good();
}
