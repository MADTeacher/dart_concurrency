import 'dart:async';

Future<void> main() async {
  var stream = Stream.fromIterable([1, 2, 3]);

  try {
    await stream.single; 
  } catch (e) {
    print(e);
  }

  stream = Stream.fromIterable([1]);
  print(await stream.single);
}
