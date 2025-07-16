import 'dart:async';

// Функция возвращает трансформер, пропускающий события
// не чаще, чем в заданное время  gap
Stream<T> throttle<T>(Stream<T> src, Duration gap) {
  return Stream.eventTransformed(src, (sink) {
    return _ThrottleSink<T>(sink, gap);
  });
}

class _ThrottleSink<T> implements EventSink<T> {
  final EventSink<T> _out;
  final Duration _gap; // минимальная задержка между событиями
  // время последнего события
  var _last = DateTime.fromMillisecondsSinceEpoch(0);

  _ThrottleSink(this._out, this._gap);

  @override
  void add(T data) {
    final now = DateTime.now();
    if (now.difference(_last) >= _gap) {
      _last = now;
      _out.add(data);
    }
  }

  @override
  void addError(Object e, [StackTrace? st]) {
    _out.addError(e, st);
  }

  @override
  void close() => _out.close();
}

void main() async {
  // Каждые 100 мс приходит запрос 
  final requests = Stream.periodic(
    const Duration(milliseconds: 100),
    (i) => 'req #$i',
  ).take(30);

  // но пропускаем только раз в 1000 мс
  throttle(
    requests,
    const Duration(milliseconds: 1000),
  ).listen(print, onDone: () => print('done'));
}
