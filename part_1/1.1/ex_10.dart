import 'dart:async';

Stream<T> combineStreamAndFuture<T>(
  Stream<T> stream, 
  Stream<T> future,
) async* {
  yield* stream;
  yield* future;
}

void main(List<String> arguments) {
  var future = Future.delayed(Duration(seconds: 1), () => 5);
  combineStreamAndFuture(
    Stream.fromIterable([1, 2]),
    future.asStream(),
  ).listen(print);
}
