void main() async{
  final stream = Stream.value('^_^');

  stream.listen(
    (data) => print(data),
    onError: (e, st) => print('catch → $e'),
    onDone: () => print('done'),
  );
}