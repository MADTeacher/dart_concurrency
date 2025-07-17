Future<String> foo1() async {
  await Future.delayed(Duration(seconds: 2));
  return '-_-';
}


void main(List<String> arguments) {
  final stream = Stream.fromFuture(foo1());
  stream.listen(print, onDone: () => print('done'), onError: print);
}
