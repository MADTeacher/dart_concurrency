import 'dart:isolate';

class Cat {
  final String name;
  const Cat(this.name);
}

void main() async {
  final ReceivePort receivePort = ReceivePort();
  final SendPort mainSendPort = receivePort.sendPort;
  await Future.wait([
    Future.delayed(Duration(seconds: 2), () {
      var a = const ['22'];
      var cat = const Cat('Max');
      var b = ['45'];
      var c = 1;
      var d = 'hi!';
      var e = 2;
      print('[Main] cat: ${identityHashCode(cat)}');
      print('[Main] a: ${identityHashCode(a)}');
      print('[Main] b: ${identityHashCode(b)}');
      print('[Main] c: ${identityHashCode(c)}');
      print('[Main] d: ${identityHashCode(d)}'); 
      print('[Main] e: ${identityHashCode(e)}');
    }),
    Isolate.spawnUri(
      Uri.file('new_isolate.dart'),
      [], 
      mainSendPort,
      debugName: 'UriIsolate',
    ),
  ]);

  final dynamic message = await receivePort.first;
  if (message is int) {
    print('[Main] recieve[$message]: ${identityHashCode(message)}');
  }

  receivePort.close();
}
