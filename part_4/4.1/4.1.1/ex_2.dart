import 'dart:isolate';

void main() async {
  var (a, b) = (1, 1);
  var list = [1, 2, 3];

  final result = await Isolate.run(() {
    a = 20;
    print('[new isolate] a = $a');

    list[0] = 101;
    print('[new isolate] list = $list');

    return a + b;
  });
  print('\n[main isolate] a = $a');
  print('[main isolate] list = $list');
  print('[main isolate] result = $result');
}
