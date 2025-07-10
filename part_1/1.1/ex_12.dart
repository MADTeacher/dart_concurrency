import 'dart:async';

typedef IntTransformer = StreamTransformer<int, int>;
typedef StringTransformer = StreamTransformer<int, String>;

// преобразование данных
IntTransformer transformer = StreamTransformer.fromHandlers(
  handleData: (data, sink) {
    sink.add(data * 10);
  },
);

// преобразование типа данных
StringTransformer strTransformer = StreamTransformer.fromHandlers(
  handleData: (data, sink) {
    sink.add("Result: $data");
  },
);

void main(List<String> arguments) {
  var future = Future.delayed(Duration(seconds: 1), () => 5);

  future
      .asStream()
      .transform(transformer)
      .listen((result) => print('Transformed: $result')); 

  future
      .asStream()
      .transform(strTransformer)
      .listen((result) => print('Transformed: $result')); 
}
