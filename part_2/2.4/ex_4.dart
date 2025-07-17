Stream<int> safeDivide(int a, int b) => b == 0
    ? Stream.error(
       ArgumentError.value(b, 'b', 'must be non‑zero'),
      )
    : Stream.value(a ~/ b);

void foo(int a, int b) {
  safeDivide(a, b)
      .handleError( // перехват и обработка исключений
        (e) => print(e),
        // перехватить только ArgumentError
        test: (e) => e is ArgumentError,
      ) // поглотили
      .listen(print, onDone: () => print('done'));
}

void main() {
  foo(5, 0);
  foo(5, 1);
}
