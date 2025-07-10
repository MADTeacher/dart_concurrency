import 'dart:async';

void main() {
  var compliter = Completer<int>();
  compliter.complete(3);
  compliter.completeError(ArgumentError()); // сгенерирует exception
}
