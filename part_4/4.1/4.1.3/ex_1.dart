import 'dart:isolate';

void topLevelFunc(Object? _) {
  print('[Isolate] основное тело изолята');
  Future.delayed(const Duration(seconds: 1), () {
    print('[Isolate] работаем с event loop');
  });
  print('[Isolate] завершение тела изолята');
}

void main() async {
  print('[Main] запуск приложения');
  final exitPort = ReceivePort();
  await Isolate.spawn(
    topLevelFunc,
    null,
    onExit: exitPort.sendPort,
  );
  await exitPort.first;
  print('[Main] завершение приложения');
}
