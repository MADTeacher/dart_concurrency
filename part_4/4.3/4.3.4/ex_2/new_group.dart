import 'dart:isolate';
import 'dart:math';

import 'main_isolate.dart';

void main(List<String> args, dynamic message) {
  var a = const ['22'];
  var cat = const Cat('Max');
  var b = ['45'];
  var c = 1;
  var d = 'hi!';
  var e = 2;
  print('[IG] cat: ${identityHashCode(cat)}');
  print('[IG] a : ${identityHashCode(a)}');
  print('[IG] b : ${identityHashCode(b)}');
  print('[IG] c : ${identityHashCode(c)}');
  print('[IG] d: ${identityHashCode(d)}');
  print('[IG] e: ${identityHashCode(e)}');

  final SendPort mainSendPort = message as SendPort;

  final int rn = Random().nextInt(4);

  print('[IG] random[$rn]: ${identityHashCode(rn)}');
  mainSendPort.send(rn);
}
