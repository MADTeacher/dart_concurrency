import 'dart:async';

Future<void> main() async {
  // Создаем broadcast контроллер, 
  // который позволяет иметь несколько подписчиков
  final controller = StreamController<int>.broadcast();

  // Асинхронно и с задержками добавляем данные. 
  // Это гарантирует, что у нас будет время подписаться на
  // поток снова, прежде чем придет следующее событие.
  Future(() async {    
    await Future.delayed(const Duration(milliseconds: 10));
    controller.add(1);
    
    await Future.delayed(const Duration(milliseconds: 10));
    controller.add(2);
    
    await Future.delayed(const Duration(milliseconds: 10));
    controller.add(3);
    
    await Future.delayed(const Duration(milliseconds: 10));

    controller.close();
  });

  final stream = controller.stream;

  // Теперь можно вызывать first несколько раз.
  // Каждый вызов создает нового подписчика, который получает 
  // следующее доступное событие в потоке, после чего сразу отписывается

  final first = await stream.first;
  print('Первый вызов first: $first');

  final second = await stream.first;
  print('Второй вызов first: $second');

  final third = await stream.first;
  print('Третий вызов first: $third');
}
