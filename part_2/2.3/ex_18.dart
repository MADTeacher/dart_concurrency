Future<String> foo1() async {
  await Future.delayed(Duration(seconds: 2));
  return '-_-';
}

Future<String> foo2() async {
  await Future.delayed(Duration(seconds: 1));
  return ':_:';
}

Future<String> foo3() async {
  await Future.delayed(Duration(seconds: 2));
  return '^_^';
}

void main(List<String> arguments) {
  final stream = Stream.fromFutures([foo1(), foo2(), foo3()]);
  stream.listen(print, onDone: () => print('done'), onError: print);
}
