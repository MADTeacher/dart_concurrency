import 'dart:async';

Stream<int> fetchNumbers() async* {
  for (int i = 1; i <= 3; i++) {
    yield i;
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// c Stream.empty
Stream<int> loadData({required bool available}) {
  return available ? fetchNumbers() : const Stream.empty();
}

// c null (у потока не вызовется onDone)
// Stream<int>? loadData({required bool available}) {
//   return available ? fetchNumbers() : null;
// }

void foo(bool available){
  final stream = loadData(available: available);
  stream.listen((data) {
    print(data);
  }, onError: (error) {
    print('Error: $error');
  }, onDone: () {
    print('Stream completed');
  });
}

void main() async {
  foo(false);
  foo(true);  
}
