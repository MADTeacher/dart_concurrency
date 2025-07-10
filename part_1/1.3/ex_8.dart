import 'dart:async';

void main(List<String> arguments) async {
  scheduleMicrotask(() => print('Microtask #1'));
  final future = Future.value('WTF');
  future.then((v) => print('Future then: $v'));
  scheduleMicrotask(() => print('Microtask #2'));
}
