void main() {
  final stream = Stream.error(FormatException('bad header'));

  stream.listen(
    (_) => {},
    onError: (e, st) => print('catch → $e'),
    onDone: () => print('done'),
  );
}
