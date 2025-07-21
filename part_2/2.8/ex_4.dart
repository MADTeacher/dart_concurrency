import 'dart:async';

typedef Json = Map<String, dynamic>;

class Pizza {
  final String name;
  final double price;
  final String? sauce;
  final List<String>? toppings;

  Pizza({required this.name, required this.price, this.sauce, this.toppings});

  @override
  String toString() {
    var strBuf = StringBuffer();
    strBuf.write('Pizza(name: $name, price: $price,');
    strBuf.write('sauce: $sauce, toppings: $toppings)');
    return strBuf.toString();
  }
}

// Кастомный EventSink
class _MyPizzaSink implements EventSink<Json> {
  final EventSink<Pizza> _out;

  _MyPizzaSink(this._out);

  @override
  void add(Map<String, dynamic> data) {
    // Обрабатываем входное событие data
    try {
      String name = data['name'] ?? 'Unknown Pizza';
      double price = (data['price'] as num?)?.toDouble() ?? 0.0;
      String? sauce = data['sauce'];
      List<String>? toppings = (data['toppings'] as List?)?.cast<String>();

      _out.add(
        Pizza(name: name, price: price, sauce: sauce, toppings: toppings),
      );
    } catch (e) {
      _out.addError('Error creating Pizza: $e');
    }
  }

  @override
  void addError(Object e, [StackTrace? st]) {
    // Обрабатываем входное событие error
    // перенавравляя его в выходной поток
    _out.addError(e, st);
  }

  @override
  void close() => _out.close();
  // перенаправляем событие close в выходной поток
}

class MyTransformer implements StreamTransformer<Json, Pizza> {
  @override
  Stream<Pizza> bind(Stream<Json> stream) {
    return Stream<Pizza>.eventTransformed(
      stream,
      (EventSink<Pizza> sink) => _MyPizzaSink(sink),
    );
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}

void main() {
  final jsonStream = Stream<Json>.fromIterable([
    {
      'name': 'Margherita',
      'price': 8.99,
      'sauce': 'Tomato',
      'toppings': ['Cheese'],
    },
    {
      'name': 'Pepperoni',
      'price': 10.99,
      'toppings': ['Pepperoni', 'Cheese'],
    },
    {'price': 9.99, 'sauce': 'Barbecue'},
    {},
  ]);

  final pizzaStream = jsonStream.transform(
    MyTransformer(),
  );

  pizzaStream.listen((pizza) => print(pizza), onError: (error) => print(error));

  print('Подписка на поток создана. Ожидаем объекты Pizza...');
}
