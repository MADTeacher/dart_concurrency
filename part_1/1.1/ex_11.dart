import 'dart:async';

void main(List<String> arguments) {
  var future = Future.delayed(Duration(seconds: 1), () => 5);
  future.asStream().map((a) => a * a).listen(print); // 25
}
