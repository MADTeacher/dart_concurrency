import 'dart:async';

Future<void> main() async {
  print('Start');
  List<int> nums = [3, 2, 6, 1];

  var count = 0;
  await Future.forEach<int>(nums, (n) {
    final res = n * n;
    print('Processed ${++count} -> $res');
  });

  print('Finish');
}
