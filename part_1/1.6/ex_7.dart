import 'dart:async';

Future<void> main() async {
  print('Start');
  List<int> nums = [3, 2, 6, 1];

  var count = 0;
  try {
    await Future.forEach<int>(nums, (n) {
      final res = n * n;
      if (n >= 6) throw ArgumentError('Error');
      print('Processed ${++count} -> $res');
    });
  } catch (e) {
    print('Error: $e');
  }

  print('Finish');
}
